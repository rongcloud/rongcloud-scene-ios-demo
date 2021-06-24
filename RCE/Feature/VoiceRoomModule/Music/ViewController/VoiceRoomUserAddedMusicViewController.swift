//
//  VoiceRoomUserAddedMusicViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import UIKit
import ReactorKit
import RxDataSources
import SVProgressHUD

class VoiceRoomUserAddedMusicViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.register(cellType: VoiceRoomMusicTableViewCell.self)
        instance.register(cellType: VoiceRoomAddedMusicCell.self)
        return instance
    }()
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<VoiceRoomMusicSection> = {
        return RxTableViewSectionedReloadDataSource<VoiceRoomMusicSection> { [weak self](dataSource, tableView, indexPath, item) -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: VoiceRoomAddedMusicCell.self)
            cell.updateCell(item: item.music, state: item.state)
            cell.rx.delete.map {
                Reactor.Action.delete(musicId: item.music.id)
            }
            .bind(to: self.reactor!.action)
            .disposed(by: cell.disposeBag)
            cell.rx
                .stick.map { Reactor.Action.stick(item.music) }
                .bind(to: self.reactor!.action)
                .disposed(by: cell.disposeBag)
            cell.rx.play.map {
                _ in
                Reactor.Action.playMusic(item.music)
            }
            .bind(to: self.reactor!.action)
            .disposed(by: cell.disposeBag)
            
            cell.rx.pause.map {
                _ in
                Reactor.Action.pause
            }
            .bind(to: self.reactor!.action)
            .disposed(by: cell.disposeBag)
            return cell
        }
    }()
    private let emptyView = MusicEmptyView()
    private let roomId: String
    var appendCallback:(() -> Void)?
    fileprivate let playEndSubject = PublishSubject<VoiceRoomAddedMusicReactor.Action>()
    
    init(roomId: String, appendCallback: @escaping (() -> Void)) {
        self.roomId = roomId
        self.appendCallback = appendCallback
        super.init(nibName: nil, bundle: nil)
        self.reactor = VoiceRoomAddedMusicReactor(roomId: roomId)
        RCRTCAudioMixer.sharedInstance().delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView.callback = appendCallback
        buildLayout()
    }
    
    private func buildLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 10))
    }
    
    func bind(reactor: VoiceRoomAddedMusicReactor) {
        NotificationCenter.default.rx
            .notification(NSNotification.Name(rawValue: MusicNotification.appendNewMusic.rawValue))
            .map {
                _ in
                Reactor.Action.append
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.viewDidLoad
            .map {
                Reactor.Action.refresh
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.addedItems)
            .map {
                !$0.isEmpty
            }
            .bind(to: emptyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.error)
            .distinctUntilChanged()
            .map(\.message)
            .bind(to: SVProgressHUD.rx.errorStatus)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.playStatus)
            .distinctUntilChanged()
            .subscribe(onNext: {
                [weak self] state in
                guard let self = self else { return }
                if case let .playing(music) = state {
                    self.onPlay(music)
                }
            }).disposed(by: disposeBag)
        
        playEndSubject.asObservable().bind(to: reactor.action).disposed(by: disposeBag)
    }
    
    private func onPlay(_ music: VoiceRoomMusic) {
        guard let index = reactor?.currentState.addedItems.firstIndex(of: music) else {
            return
        }
        let indexPath = IndexPath(item: index, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}


extension VoiceRoomUserAddedMusicViewController: RCRTCAudioMixerAudioPlayDelegate {
    func didReportPlayingProgress(_ progress: Float) {
        
    }
    
//    func didPlayToEnd() {
//        playEndSubject.onNext(.musicDidPlayEnd)
//    }
    
    func didAudioMixingStateChanged(_ mixingState: RCRTCAudioMixingState, reason mixingReason: RCRTCAudioMixingReason) {
        if mixingState == .mixingStateStop, mixingReason == .mixingReasonAllLoopsCompleted {
            playEndSubject.onNext(.musicDidPlayEnd)
        }
    }
}

