//
//  LiveVideoRoomViewController+Session.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import SVProgressHUD
import RCSceneService
import RCSceneMusic

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func session_viewDidLoad() {
        m_viewDidLoad()
        joinRoom()
    }
    
    func joinRoom() {
        SVProgressHUD.show()
        videoJoinRoom { [weak self] result in
            switch result {
            case .success:
                debugPrint("join room success")
                SceneRoomManager.shared.currentRoom = self?.room
                self?.role = RCLiveVideoEngine.shared().currentRole
                SVProgressHUD.dismiss(withDelay: 0.3)
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    func leaveRoom() {
        videoLeaveRoom { [weak self] _ in
            SceneRoomManager.shared.currentRoom = nil
            self?.navigationController?.popViewController(animated: true)
            DataSourceImpl.instance.clear()
            PlayerImpl.instance.clear()
        }
    }
}

extension LiveVideoRoomViewController {
    
    /// 关闭房间
    func closeRoom() {
        SVProgressHUD.show()
        videoRoomService.closeRoom(roomId: room.roomId) { [weak self] result in
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
            if $0 == roomUserView { return }
            $0.removeFromSuperview()
        }
        roomUserView.setRoom(room)

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
