//
//  RCRadioRoomViewController+More.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import SVProgressHUD
import RCSceneService
import RCSceneMusic
import RCSceneFoundation

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
        radioRouter.trigger(.leaveAlert(isOwner: isOwner, delegate: self))
    }
}

extension RCRadioRoomViewController: RCSceneLeaveViewProtocol {
    func quitRoomDidClick() {
        radioLeaveRoom { _ in }
    }
    
    func closeRoomDidClick() {
        radioRouter.trigger(.voiceRoomAlert(title: "确定结束本次直播么？", actions: [.cancel("取消"), .confirm("确认")], alertType: alertTypeConfirmCloseRoom, delegate: self))
    }
    
    func scaleRoomDidClick() {
        guard let fm = self.floatingManager, let parent = parent else {
            navigationController?.popViewController(animated: false)
            return
        }
        fm.show(parent, superView: nil, animated: true)
        navigationController?.popViewController(animated: false)
    }
    
    /// 关闭房间
    func closeRoom() {
        clearMusicData()
        RCCoreClient.shared()
            .sendMessage(.ConversationType_CHATROOM,
                         targetId: roomInfo.roomId,
                         content: RCRRCloseMessage(),
                         pushContent: "",
                         pushData: "")
                { _ in } error: { _, _ in }

        SVProgressHUD.show()
        radioRoomService.closeRoom(roomId: roomInfo.roomId) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                switch result.map(AppResponse.self) {
                case let .success(response):
                    if response.validate() {
                        SVProgressHUD.showSuccess(withStatus: "直播结束，房间已关闭")
                        self?.radioLeaveRoom { _ in }
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
        radioLeaveRoom { _ in }
    }
    
    func clearMusicData() {
        if (self.roomInfo.isOwner) {
            DataSourceImpl.instance.clear()
            PlayerImpl.instance.clear()
            DelegateImpl.instance.clear()
        }
    }
}

let alertTypeVideoAlreadyClose = "alertTypeVideoAlreadyClose"
let alertTypeConfirmCloseRoom = "alertTypeConfirmCloseRoom"

extension RCRadioRoomViewController: VoiceRoomAlertProtocol {
    func cancelDidClick(alertType: String) {}

    func confirmDidClick(alertType: String) {
        switch alertType {
        case alertTypeConfirmCloseRoom:
            closeRoom()
        case alertTypeVideoAlreadyClose:
            radioLeaveRoom { _ in}
        default: ()
        }
    }
}
