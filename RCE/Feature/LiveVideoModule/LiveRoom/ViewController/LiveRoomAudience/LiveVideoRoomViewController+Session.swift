//
//  LiveVideoRoomViewController+Session.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import SVProgressHUD

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func session_viewDidLoad() {
        m_viewDidLoad()
        joinRoom()
    }
    
    func joinRoom() {
        SVProgressHUD.show()
        joinRoom { [weak self] result in
            switch result {
            case .success:
                debugPrint("join room success")
                self?.handleUserEnter(Environment.currentUserId)
                self?.role = RCLiveVideoEngine.shared().currentRole
                SVProgressHUD.dismiss(withDelay: 0.3)
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    func leaveRoom() {
        leaveRoom { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

extension LiveVideoRoomViewController: RCRoomCycleProtocol {
    func joinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        let roomId = room.roomId
        let api = RCNetworkAPI.roomInfo(roomId: roomId)
        networkProvider.request(api) { [weak self] result in
            switch result.map(RCNetworkWapper<VoiceRoom>.self) {
            case let .success(wrapper):
                switch wrapper.code {
                case 10000:
                    RCLiveVideoEngine.shared().joinRoom(roomId) { code in
                        if code == .success {
                            networkProvider.request(.userUpdateCurrentRoom(roomId: roomId)) { _ in }
                            completion(.success(()))
                        } else {
                            completion(.failure(ReactorError("加入房间失败:\(code.rawValue)")))
                        }
                    }
                case 30001:
                    completion(.success(()))
                    self?.didCloseRoom() /// 房间已关闭
                default: completion(.failure(ReactorError("加入房间失败")))
                }
            case let .failure(error):
                completion(.failure(ReactorError("加入房间失败:\(error.localizedDescription)")))
            }
        }
    }
    
    func leaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        RCLiveVideoEngine.shared().leaveRoom { code in
            switch code {
            case .success, .notJoinRoom:
                networkProvider.request(.userUpdateCurrentRoom(roomId: "")) { _ in }
                completion(.success(()))
            default:
                completion(.failure(ReactorError("离开房间失败:\(code.rawValue)")))
            }
        }
    }
    
    func descendantViews() -> [UIView] {
        return [messageView.tableView]
    }
}

extension LiveVideoRoomViewController {
    
    /// 关闭房间
    func closeRoom() {
        SVProgressHUD.show()
        let api: RCNetworkAPI = .closeRoom(roomId: room.roomId)
        networkProvider.request(api) { [weak self] result in
            switch result.map(AppResponse.self) {
            case let .success(response):
                if response.validate() {
                    SVProgressHUD.showSuccess(withStatus: "直播结束，房间已关闭")
                    self?.leaveRoom()
                } else {
                    SVProgressHUD.showSuccess(withStatus: "关闭房间失败")
                }
            case .failure:
                SVProgressHUD.showSuccess(withStatus: "关闭房间失败")
            }
        }
    }
    
    func didCloseRoom() {
        view.subviews.forEach {
            if $0 == roomInfoView { return }
            $0.removeFromSuperview()
        }
        roomInfoView.updateRoom(info: room)

        let tipLabel = UILabel()
        tipLabel.text = "该房间直播已结束"
        tipLabel.textColor = .white
        tipLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.618)
        }

        let tipButton = UIButton()
        tipButton.setTitle("返回房间列表", for: .normal)
        tipButton.setTitleColor(.white, for: .normal)
        tipButton.backgroundColor = .lightGray
        tipButton.layer.cornerRadius = 6
        tipButton.layer.masksToBounds = true
        tipButton.addTarget(self, action: #selector(backToRoomList), for: .touchUpInside)
        view.addSubview(tipButton)
        tipButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.1)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
    }
    
    @objc private func backToRoomList() {
        leaveRoom()
    }
}
