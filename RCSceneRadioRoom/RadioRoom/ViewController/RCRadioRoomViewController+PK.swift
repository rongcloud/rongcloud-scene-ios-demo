//
//  RCRadioRoomViewController+PK.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import SVProgressHUD
import RCSceneService
import RCSceneFoundation

fileprivate var kRadioRoomRtcOtherRoomKey: Int = 2

extension RCRadioRoomViewController {
    
    var rtcOtherRoom: RCRTCOtherRoom? {
        get {
            objc_getAssociatedObject(self, &kRadioRoomRtcOtherRoomKey) as? RCRTCOtherRoom
        }
        set {
            objc_setAssociatedObject(self,
                                     &kRadioRoomRtcOtherRoomKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard let rtcOtherRoom = rtcOtherRoom else { return }
            rtcOtherRoom.delegate = self
            listonToOtherRoom(rtcOtherRoom)
        }
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func PK_viewDidLoad() {
        m_viewDidLoad()
        //xuefengtodo
        //roomToolBarView.add(pk: self, action: #selector(handlePkButtonClick))
    }
    
    @objc private func handlePkButtonClick() {
        //navigatortodo
        //navigator(.onlineRooms(selectingUserId: nil, delegate: self))
    }
    
    private func listonToOtherRoom(_ room: RCRTCOtherRoom) {
        var streams = [RCRTCInputStream]()
        for user in room.remoteUsers {
            streams.append(contentsOf: user.remoteStreams)
        }
        rtcRoom?.localUser.subscribeStream(streams, tinyStreams: [], completion: { success, code in
            if success {
                print("liston to other room success")
            } else {
                print("liston to other room fail: \(code.rawValue)")
            }
        })
    }
}

extension RCRadioRoomViewController {
    // PK info KV changed
    func roomKVDidChanged(roomPKInfo: RCRadioRoomPKInfo?) {
        if roomPKInfo == nil {
            roomPKDidEnd()
        } else {
            roomPKDidBegin()
        }
    }
    
    // PK Begin UI
    private func roomPKDidBegin() {
        //xuefengtodo
//        guard let info = roomKVState.roomPKInfo else { return }
//
//        view.addSubview(roomPKView)
//        roomPKView.snp.remakeConstraints { make in
//            make.top.equalTo(roomNoticeView.snp.bottom).offset(16)
//            make.left.right.equalToSuperview().inset(12)
//        }
//        roomPKView.updateUserInfo(info: info.voiceRoomPKInfo)
//
//        messageView.snp.remakeConstraints { make in
//            make.bottom.equalTo(roomToolBarView.snp.top).offset(-8.resize)
//            make.left.right.equalToSuperview()
//            make.top.equalTo(roomPKView.snp.bottom).offset(20)
//        }
//        UIView.animate(withDuration: 0.3) {
//            self.roomOwnerView.alpha = 0
//            self.roomPKView.alpha = 1
//            self.view.layoutIfNeeded()
//        }
//        roomPKView.beginCountdown(remainSeconds: 150) {
//            [weak self] _,_ in
//            guard let self = self else { return }
//            self.finishPKIfNeeded({_ in})
//        }
    }
    
    // PK End UI
    private func roomPKDidEnd() {
        messageView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(roomToolBarView.snp.top).offset(-8.resize)
            $0.top.equalTo(roomOwnerView.snp.bottom).offset(24.resize)
        }

        UIView.animate(withDuration: 0.3) {
            self.roomOwnerView.alpha = 1
            //xuefengtodo
            //self.roomPKView.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // PK Begin Event
    func beginPK(_ info: RCRadioRoomPKInfo) {
        //xuefentodo
//        VoiceRoomManager.shared.setPKStatus(roomId: info.inviterRoomId, toRoomId: info.inviteeRoomId, status: .begin)
//        roomKVState.update(roomPKInfo: info)
//        roomPKDidBegin()
    }
    
    // PK End Event
    func endPK(_ info: RCRadioRoomPKInfo) {
        //xuefengtodo
//        VoiceRoomManager.shared.setPKStatus(roomId: info.inviterRoomId, toRoomId: info.inviteeRoomId, status: .close)
//        roomKVState.update(roomPKInfo: nil)
//        roomPKDidEnd()
    }
    
    // PK
    func restore(PK info: RCRadioRoomPKInfo?) {
        guard let info = info else { return }
        guard let roomId = info.otherRoomId else {
            return roomPKDidBegin()
        }
        RCRTCEngine.sharedInstance()
            .joinOtherRoom(roomId) { otherRoom, code in
                DispatchQueue.main.async { [weak self] in
                    guard code == .success else {
                        return SVProgressHUD.showError(withStatus: "加入房间失败:\(code.rawValue)")
                    }
                    self?.rtcOtherRoom = otherRoom
                    self?.roomPKDidBegin()
                }
            }
    }
}
//xuefengtodo
//extension RCRadioRoomViewController: OnlineRoomCreatorDelegate {
//    func selectedUserDidClick(userId: String, from roomId: String) {
//
//    }
//
//    func userDidInvite(userId: String, from roomId: String) {
//        rtcRoom?.localUser
//            .requestJoinOtherRoom(roomId,
//                                  userId: userId,
//                                  autoMix: true,
//                                  extra: "",
//                                  completion: { success, code in
//                                    if success {
//                                        SVProgressHUD.showSuccess(withStatus: "邀请发送成功")
//                                    } else {
//                                        SVProgressHUD.showError(withStatus: "邀请发送失败")
//                                    }
//                                  })
//    }
//}

extension RCRadioRoomViewController {
    public func didRequestJoinOtherRoom(_ inviterRoomId: String, inviterUserId: String, extra: String) {
        let controller = UIAlertController(title: "提示", message: "用户邀请您PK，是否同意?", preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "同意", style: .default) { [unowned self] _ in
            acceptPKRequest(inviterRoomId, inviterUserId: inviterUserId, accept: true)
        }
        let cancelAction = UIAlertAction(title: "拒绝", style: .cancel) { [unowned self] _ in
            acceptPKRequest(inviterRoomId, inviterUserId: inviterUserId, accept: false)
        }
        controller.addAction(sureAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    private func acceptPKRequest(_ inviterRoomId: String, inviterUserId: String, accept: Bool) {
        guard let rtcRoom = rtcRoom else { return }
        queue.async {
            let semaphore = DispatchSemaphore(value: 0)
            
            var result = Result<Void, ReactorError>.success(())
            
            rtcRoom.localUser
                .responseJoinOtherRoom(inviterRoomId,
                                       userId: inviterUserId,
                                       agree: accept,
                                       autoMix: true,
                                       extra: "") { success, code in
                    if success == false {
                        result = .failure(ReactorError("邀请回应失败:\(code.rawValue)"))
                    }
                    semaphore.signal()
                }
            semaphore.wait()
            if case let .failure(error) = result {
                return DispatchQueue.main.async {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
            
            guard accept else { return }
            
            var rtcOtherRoom: RCRTCOtherRoom?
            RCRTCEngine.sharedInstance()
                .joinOtherRoom(inviterRoomId) { otherRoom, code in
                    if code == .success {
                        if code != .success {
                            result = .failure(ReactorError("加入房间失败:\(code.rawValue)"))
                        } else {
                            rtcOtherRoom = otherRoom
                        }
                    }
                    semaphore.signal()
                }
            semaphore.wait()
            
            if case let .failure(error) = result {
                return DispatchQueue.main.async {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.rtcOtherRoom = rtcOtherRoom
                let info = RCRadioRoomPKInfo(inviterId: inviterUserId,
                                             inviteeId: Environment.currentUserId,
                                             inviterRoomId: inviterRoomId,
                                             inviteeRoomId: rtcRoom.roomId)
                self?.beginPK(info)
            }
        }
    }
    
    public func didResponseJoinOtherRoom(_ inviterRoomId: String, inviterUserId: String, inviteeRoomId: String, inviteeUserId: String, agree: Bool, extra: String) {
        guard agree, inviterUserId == Environment.currentUserId else { return }
        RCRTCEngine.sharedInstance()
            .joinOtherRoom(inviteeRoomId) { otherRoom, code in
                DispatchQueue.main.async { [weak self] in
                    guard code == .success else {
                        return SVProgressHUD.showError(withStatus: "加入房间失败:\(code.rawValue)")
                    }
                    self?.rtcOtherRoom = otherRoom
                    let info = RCRadioRoomPKInfo(inviterId: inviterUserId,
                                                 inviteeId: inviteeUserId,
                                                 inviterRoomId: inviterRoomId,
                                                 inviteeRoomId: inviteeRoomId)
                    self?.beginPK(info)
                }
            }
    }
    
    
    
    public func didFinishOtherRoom(_ roomId: String, userId: String) {
        //xuefengtodo
//        print("\(userId) finish pk")
//        guard let info = roomKVState.roomPKInfo else { return }
//        endPK(info)
    }
}

extension RCRadioRoomViewController: RCRTCOtherRoomEventDelegate {
}
