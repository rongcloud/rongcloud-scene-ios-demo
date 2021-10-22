//
//  RCRadioRoomViewController+More.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import SVProgressHUD

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func more_viewDidLoad() {
        m_viewDidLoad()
        RCCoreClient.shared().registerMessageType(RCRRCloseMessage.self)
        moreButton.setImage(R.image.more_icon(), for: .normal)
        moreButton.addTarget(self, action: #selector(handleMoreButton), for: .touchUpInside)
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func more_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard message.content.isKind(of: RCRRCloseMessage.self) else {
            return
        }
        didCloseRoom()
    }
    
    @objc private func handleMoreButton() {
        let isOwner = Environment.currentUserId == roomInfo.userId
        navigator(.leaveAlert(isOwner: isOwner, delegate: self))
    }
}

extension RCRadioRoomViewController: LeaveViewProtocol {
    func quitRoomDidClick() {
        leaveRoom()
    }
    
    func closeRoomDidClick() {
        let navigation: RCNavigation = .voiceRoomAlert(title: "确定结束本次直播么？",
                                                       actions: [.cancel("取消"), .confirm("确认")],
                                                       alertType: alertTypeConfirmCloseRoom,
                                                       delegate: self)
        navigator(navigation)
    }
    
    func scaleRoomDidClick() {
        guard let controller = parent as? RCRoomContainerViewController else { return }
        RCRoomFloatingManager.shared.show(controller)
        navigationController?.popViewController(animated: false)
    }
    
    /// 关闭房间
    func closeRoom() {
        RCCoreClient.shared()
            .sendMessage(.ConversationType_CHATROOM,
                         targetId: roomInfo.roomId,
                         content: RCRRCloseMessage(),
                         pushContent: "",
                         pushData: "")
                { _ in } error: { _, _ in }

        SVProgressHUD.show()
        let api: RCNetworkAPI = .closeRoom(roomId: roomInfo.roomId)
        networkProvider.request(api) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
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
    }
    
    func didCloseRoom() {
        view.subviews.forEach {
            if $0 == roomInfoView { return }
            $0.removeFromSuperview()
        }
        roomInfoView.updateRoom(info: roomInfo)
        
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

extension RCRadioRoomViewController: VoiceRoomAlertProtocol {
    func cancelDidClick(alertType: String) {}
    
    func confirmDidClick(alertType: String) {
        switch alertType {
        case alertTypeConfirmCloseRoom:
            closeRoom()
        case alertTypeVideoAlreadyClose:
            leaveRoom()
        default: ()
        }
    }
}
