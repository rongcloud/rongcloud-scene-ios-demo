//
//  VoiceRoomListViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import UIKit
import RxDataSources
import ReactorKit
import RxViewController
import SVProgressHUD
import MJRefresh
import ViewAnimator

class VoiceRoomListViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    private let refreshHeader = RCRefreshHeader()
    private let loadFooter = RCLoadMoreFooter()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.register(cellType: RoomListTableViewCell.self)
        instance.refreshControl = refreshHeader
        instance.mj_footer = loadFooter
        instance.separatorStyle = .none
        instance.backgroundColor = .clear
        instance.contentInsetAdjustmentBehavior = .never
        return instance
    }()
    private let emptyView = VoiceRoomlistEmptyView()
    private lazy var plusButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.create_voice_room_icon(), for: .normal)
        return instance
    }()
    private lazy var infoButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.exclamation_point_icon(), for: .normal)
        instance.sizeToFit()
        return instance
    }()
    private lazy var dataSource: RxTableViewSectionedReloadDataSourceWithReloadSignal<VoiceRoomSection> = {
        return RxTableViewSectionedReloadDataSourceWithReloadSignal<VoiceRoomSection> { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: RoomListTableViewCell.self)
            cell.updateCell(room: item)
            return cell
        }
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.reactor = VoiceRoomListReactor()
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    private func buildLayout() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        view.backgroundColor = UIColor(hexInt: 0xF6F8F9)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(plusButton)
        
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(17)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-22)
        }
    }
    
    func bind(reactor: VoiceRoomListReactor) {
        rx.viewWillAppear
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshHeader.rx
            .controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        loadFooter.rx
            .refresh
            .filter { $0 == .refreshing }
            .map {_ in Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.isRefreshing)
            .bind(to: refreshHeader.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.loadMoreState)
            .bind(to: loadFooter.rx.refresh)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.section.first?.items ?? [] }
            .map { !$0.isEmpty }
            .bind(to: emptyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.error?)
            .distinctUntilChanged()
            .map(\.message)
            .bind(to: SVProgressHUD.rx.errorStatus)
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(VoiceRoom.self)
            .flatMap { [weak self] room -> Observable<(String, VoiceRoom)> in
                guard let self = self else { return .empty() }
                if room.isPrivate == 0 || room.userId == Environment.currentUserId {
                    self.navigator(.voiceRoom(roomInfo: room))
                    return .empty()
                } else {
                    if let pwvc = self.navigator(.inputPassword(type: .verify(room.password ?? "") ,delegate: nil)) as? VoiceRoomPasswordViewController {
                        return Observable.combineLatest(pwvc.rx.password, Observable.just(room))
                    }
                    return .empty()
                }
            }
            .filter { password, room in
                password == room.password
            }
            .subscribe(onNext: {
                [weak self] value in
                guard let self = self else { return }
                self.navigator(.voiceRoom(roomInfo: value.1))
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.section)
            .distinctUntilChanged()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        dataSource.dataReloaded
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                let cells = self.tableView.visibleCells
                UIView.animate(views: cells, animations: [AnimationType.vector(CGVector(dx: 0, dy: 50))])
            })
            .disposed(by: disposeBag)
        
        plusButton.rx
            .tap
            .asObservable()
            .withLatestFrom(reactor.state)
            .map(\.images)
            .flatMap { [weak self] imagelist -> Observable<CreateVoiceRoomWrapper> in
                guard let self = self else { return .empty() }
                if let vc = self.navigator(.createRoom(imagelist: imagelist)) as? CreateVoiceRoomViewController {
                    return vc.rx.createSuccess
                }
                return Observable.empty()
            }
            .subscribe(onNext: {
                [weak self] value in
                guard let self = self, let room = value.data else { return }
                if value.isCreated() {
                    self.showCreatedAlert(voiceRoom: room)
                } else {
                    self.navigator(.voiceRoom(roomInfo: room))
                }
            })
            .disposed(by: disposeBag)
        
        infoButton.rx.tap.subscribe(onNext: {
            _ in
            UIApplication.shared.open(URL(string: "https://docs.rongcloud.cn/v4/views/rtc/livevideo/intro/ability.html")!, options: [:], completionHandler: nil)
        }).disposed(by: disposeBag)
    }
    
    private func showCreatedAlert(voiceRoom: VoiceRoom) {
        if let preVC = presentedViewController {
            preVC.dismiss(animated: false) { [weak self] in
                self?.showCreatedAlert(voiceRoom: voiceRoom)
            }
            return
        }
        
        let alertVC = UIAlertController(title: "", message: "您已创建过语聊房，是否直接进入？", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "进入", style: .default, handler: { action in
            self.navigator(.voiceRoom(roomInfo: voiceRoom))
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    deinit {
        print("VRLVC deinit")
    }
}
