//
//  LiveRoomMicrophoneInviteViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/10.
//

import SVProgressHUD

class RCLVRMicInviteViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.register(cellType: RCLVMicInviteCell.self)
        instance.dataSource = self
        return instance
    }()
    private lazy var emptyView = VoiceRoomUserListEmptyView()

    private var userlist = [VoiceRoomUser](){
        didSet {
            emptyView.isHidden = userlist.count > 0
        }
    }
    
    private var inviteUserIds = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(emptyView)
        view.addSubview(tableView)
        
        emptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40.resize)
            make.width.height.equalTo(160.resize)
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        fetchMicInviteUsers()
        fetchRoomUserlist()
    }
    
    private func fetchMicInviteUsers() {
        RCLiveVideoEngine.shared()
            .getInvitations { [weak self] code, userIds in
                if code == .success {
                    self?.inviteUserIds = Set(userIds)
                    self?.tableView.reloadData()
                } else {
                    SVProgressHUD.showError(withStatus: "获取排麦用户列表失败")
                }
            }
    }
    
    private func fetchRoomUserlist() {
        var micUserIds = RCLiveVideoEngine.shared().liveVideoUserIds
        micUserIds.append(Environment.currentUserId)
        let api = RCNetworkAPI.roomUsers(roomId: RCLiveVideoEngine.shared().roomId)
        networkProvider.request(api) { [weak self] result in
            switch result.map(RCNetworkWapper<[VoiceRoomUser]>.self) {
            case let .success(wrapper):
                if let users = wrapper.data {
                    self?.userlist = users.filter { !micUserIds.contains($0.userId) }
                    self?.tableView.reloadData()
                } else {
                    SVProgressHUD.showError(withStatus: "获取排麦用户列表失败")
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}

extension RCLVRMicInviteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = userlist[indexPath.row]
        return tableView
            .dequeueReusableCell(for: indexPath, cellType: RCLVMicInviteCell.self)
            .updateCell(user, isInvited: inviteUserIds.contains(user.userId))
    }
}

extension RCLVRMicInviteViewController: RCLVMicInviteDelegate {
    func micInvite(_ user: VoiceRoomUser) {
        RCLiveVideoEngine.shared()
            .inviteLiveVideo(user.userId, at: -1) { [weak self] code in
                switch code {
                case .success:
                    self?.didMicInvite(user)
                case .invitationIsFull:
                    SVProgressHUD.showError(withStatus: "上麦邀请队列已满")
                case .liveVideoIsFull:
                    SVProgressHUD.showError(withStatus: "麦位已满")
                default:
                    SVProgressHUD.showError(withStatus: "邀请失败")
                }
            }
    }
    
    private func didMicInvite(_ user: VoiceRoomUser) {
        dismiss(animated: true) { [weak self] in
            guard let controller = self?.parent as? RCLVMicViewController else { return }
            controller.delegate?.didSendInvitation(user)
        }
    }
}
