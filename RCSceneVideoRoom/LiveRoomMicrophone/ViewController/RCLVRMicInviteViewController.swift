//
//  LiveRoomMicrophoneInviteViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/10.
//

import SVProgressHUD
import RCSceneService

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
    
    private let seatIndex: Int
    init(_ seatIndex: Int) {
        self.seatIndex = seatIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        fetchRoomUserlist()
    }
    
    private func fetchRoomUserlist() {
        let micUserIds = RCLiveVideoEngine.shared().currentSeats.map { $0.userId }
        videoRoomService.roomUsers(roomId: RCLiveVideoEngine.shared().roomId) { [weak self] result in
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
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: RCLVMicInviteCell.self)
        cell.hiddenInviteButton = false
        return cell.updateCell(user)
    }
}

extension RCLVRMicInviteViewController: RCLVMicInviteDelegate {
    func micInvite(_ user: VoiceRoomUser) {
        RCLiveVideoEngine.shared()
            .inviteLiveVideo(user.userId, at: seatIndex) { [weak self] code in
                switch code {
                case .success:
                    self?.didMicInvite(user)
                    SVProgressHUD.showSuccess(withStatus: "已邀请上麦")
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
