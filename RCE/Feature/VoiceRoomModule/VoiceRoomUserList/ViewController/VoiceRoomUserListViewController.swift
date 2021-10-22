//
//  VoiceRoomUserListViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/21.
//

import UIKit
import RxSwift

class VoiceRoomUserListViewController: UIViewController {
    private var dependency: VoiceRoomUserOperationDependency
    private weak var delegate: VoiceRoomUserOperationProtocol?
    private var disposeBag = DisposeBag()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.register(cellType: InviteSeatTableViewCell.self)
        instance.dataSource = self
        instance.delegate = self
        return instance
    }()
    private lazy var emptyView = VoiceRoomUserListEmptyView()
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.white_quite_icon(), for: .normal)
        instance.addTarget(self, action: #selector(handleCancelClick), for: .touchUpInside)
        instance.sizeToFit()
        return instance
    }()
    private var userlist = [VoiceRoomUser]() {
        didSet {
            emptyView.isHidden = userlist.count > 0
        }
    }
    private var managerlist = [String]()
    
    init(dependency: VoiceRoomUserOperationDependency, delegate: VoiceRoomUserOperationProtocol) {
        self.delegate = delegate
        self.dependency = dependency
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "用户列表"
        view.addSubview(blurView)
        view.addSubview(emptyView)
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-72.resize)
            make.width.height.equalTo(190.resize)
        }
        fetchRoomUserlist()
        fetchManagerList()
    }
    
    private func buildLayout() {
        view.backgroundColor = R.color.hex03062F()?.withAlphaComponent(0.5)
        view.addSubview(blurView)
        view.addSubview(tableView)
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func fetchRoomUserlist() {
        networkProvider.rx
            .request(.roomUsers(roomId: dependency.room.roomId))
            .asObservable()
            .filterSuccessfulStatusCodes()
            .map([VoiceRoomUser].self, atKeyPath: "data")
            .subscribe(onNext: {
                [weak self] list in
                guard let self = self else { return }
                self.userlist = list
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func fetchManagerList() {
        networkProvider.rx.request(.roomManagers(roomId: dependency.room.roomId)).asObservable().filterSuccessfulStatusCodes().map([VoiceRoomUser].self, atKeyPath: "data").subscribe(onNext: {
            [weak self] value in
            guard let self = self else { return }
            self.managerlist = value.map(\.userId)
        }).disposed(by: disposeBag)
    }
    
    @objc func handleCancelClick() {
        dismiss(animated: true, completion: nil)
    }
}

extension VoiceRoomUserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: InviteSeatTableViewCell.self)
        cell.updateCell(user: userlist[indexPath.row], hidesInvite: true)
        return cell
    }
}

extension VoiceRoomUserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userlist[indexPath.row]
        guard user.userId != Environment.currentUserId else {
            return
        }
        dependency.presentUserId = user.userId
        navigator(.manageUser(dependency: dependency, delegate: delegate))
    }
}
