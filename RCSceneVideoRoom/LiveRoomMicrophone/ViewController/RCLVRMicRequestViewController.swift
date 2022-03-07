//
//  LiveRoomMicrophoneRequestViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/7.
//

import SVProgressHUD
import RCSceneService

class RCLVRMicRequestViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.register(cellType: RCLVMicRequestCell.self)
        instance.dataSource = self
        return instance
    }()
    
    private lazy var emptyView = VoiceRoomUserListEmptyView()
    
    private var userlist = [VoiceRoomUser]() {
        didSet {
            emptyView.isHidden = userlist.count > 0
        }
    }
    
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
        
        fetchMicRequestUsers()
    }
    
    private func fetchMicRequestUsers() {
        RCLiveVideoEngine.shared()
            .getRequests { [weak self] code, userIds in
                if code == .success {
                    self?.fetchAllUserInfo(userIds)
                } else {
                    SVProgressHUD.showError(withStatus: "获取排麦用户列表失败")
                }
            }
    }
    
    private func fetchAllUserInfo(_ userIds: [String]) {
        videoRoomService.usersInfo(id: userIds) { [weak self] result in
            switch result.map(RCNetworkWapper<[VoiceRoomUser]>.self) {
            case let .success(wrapper):
                if let users = wrapper.data {
                    self?.userlist = users
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

extension RCLVRMicRequestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView
            .dequeueReusableCell(for: indexPath, cellType: RCLVMicRequestCell.self)
            .updateCell(userlist[indexPath.row])
    }
}

extension RCLVRMicRequestViewController: RCLVMicRequestDelegate {
    func acceptMicRequest(_ user: VoiceRoomUser) {
        RCLiveVideoEngine.shared()
            .acceptRequest(user.userId) { [weak self] code in
                switch code {
                case .success: self?.didAcceptMicRequest(user)
                case .seatIsFull, .seatIsLock:
                    SVProgressHUD.showError(withStatus: "没有空麦位了")
                    self?.dismiss(animated: true)
                case .seatUserExist:
                    SVProgressHUD.showError(withStatus: "连麦已占用")
                    self?.dismiss(animated: true)
                default:
                    SVProgressHUD.showError(withStatus: "无法与对方进行视频连麦")
                    self?.dismiss(animated: true)
                }
            }
    }
    
    func rejectMicRequest(_ user: VoiceRoomUser) {
        RCLiveVideoEngine.shared()
            .rejectRequest(user.userId) { [weak self] code in
                if code == .success {
                    self?.didRejectMicRequest(user)
                } else {
                    SVProgressHUD.showError(withStatus: "上麦请求处理失败")
                    self?.dismiss(animated: true)
                }
            }
    }
    
    private func didAcceptMicRequest(_ user: VoiceRoomUser) {
        dismiss(animated: true) { [weak self] in
            guard let controller = self?.parent as? RCLVMicViewController else { return }
            controller.delegate?.didAcceptSeatRequest(user)
        }
    }
    
    private func didRejectMicRequest(_ user: VoiceRoomUser) {
        guard let index = userlist.firstIndex(where: { $0.userId == user.userId }) else { return }
        
        userlist.remove(at: index)
        let indexPath = IndexPath(item: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        guard let controller = parent as? RCLVMicViewController else { return }
        controller.delegate?.didRejectRequest(user)
    }
}
