//
//  LiveVideoOthersViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/28.
//

import SVProgressHUD
import RCSceneService

protocol LiveVideoOthersDelegate: AnyObject {
    func pkInvitationDidSend(userId: String, from roomId: String)
    func pkInvitationDidCancel(userId: String, from roomId: String)
}

class LiveVideoOthersViewController: UIViewController {
    
    weak var delegate: LiveVideoOthersDelegate?
    
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 22
        instance.clipsToBounds = true
        return instance
    }()
    private var others = [VoiceRoomUser]()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.register(cellType: OnlineCreatorTableViewCell.self)
        instance.dataSource = self
        instance.delegate = self
        return instance
    }()
    private lazy var emptyView = VoiceRoomUserListEmptyView()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17)
        instance.textColor = .white
        instance.text = "在线房主"
        return instance
    }()
    private var rooms = [VoiceRoom]() {
        didSet {
            emptyView.isHidden = rooms.count > 0
        }
    }
    
    var selectingOther: (roomId: String, userId: String)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        fetchOthers()
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(nameLabel)
        container.addSubview(emptyView)
        container.addSubview(tableView)
        
        container.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.67)
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.width.height.equalTo(190.resize)
        }
    }
}

extension LiveVideoOthersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OnlineCreatorTableViewCell.self)
        cell.updateCell(user: rooms[indexPath.row].createUser, selectingUserId: selectingOther?.userId)
        return cell
    }
}

extension LiveVideoOthersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        if selectingOther?.roomId == room.roomId {
            willCancelPKInvitation(roomId: room.roomId, userId: room.userId)
        } else {
            sendPKInvitation(room)
        }
    }
    
    private func willCancelPKInvitation(roomId: String, userId: String) {
        let controller = UIAlertController(title: nil, message: "已发起PK邀请", preferredStyle: .alert)
        let cancelPKAction = UIAlertAction(title: "撤回邀请", style: .default) { _ in
            self.cancelPKInvitation(roomId: roomId, userId: userId)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(cancelPKAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    private func cancelPKInvitation(roomId: String, userId: String) {
        RCLiveVideoEngine.shared().cancelPKInvitation(roomId, invitee: userId) { code in
            if code == .success {
                SVProgressHUD.showSuccess(withStatus: "已取消邀请")
                self.didCancelPKInvitation(roomId: roomId, userId: userId)
            } else {
                SVProgressHUD.showError(withStatus: "撤回PK邀请失败，请重试")
            }
        }
    }
    
    private func didCancelPKInvitation(roomId: String, userId: String) {
        dismiss(animated: true) {
            self.delegate?.pkInvitationDidCancel(userId: userId, from: roomId)
        }
    }
    
    private func sendPKInvitation(_ room: VoiceRoom) {
        videoRoomService.isPK(roomId: room.roomId) { result in
            switch result {
            case .success(let response):
                guard let status = try? JSONDecoder().decode(RoomPKStatus.self, from: response.data), !status.data else {
                    SVProgressHUD.showError(withStatus: "对方正在忙碌")
                    return
                }
                RCLiveVideoEngine.shared().sendPKInvitation(room.roomId, invitee: room.userId) { code in
                    if code == .success {
                        SVProgressHUD.showSuccess(withStatus: "已邀请 PK，等待对方接受")
                        self.didSendPKInvitation(room)
                    } else {
                        SVProgressHUD.showError(withStatus: "发送 PK 邀请失败")
                    }
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    private func didSendPKInvitation(_ room: VoiceRoom) {
        dismiss(animated: true)
        delegate?.pkInvitationDidSend(userId: room.userId, from: room.roomId)
    }
}

extension LiveVideoOthersViewController {
    func fetchOthers() {
        videoRoomService.onlineCreator {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                if let model = try? JSONDecoder().decode(RCNetworkWapper<[VoiceRoom]>.self, from: response.data) {
                    self.rooms = model.data ?? []
                    self.tableView.reloadData()
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}
