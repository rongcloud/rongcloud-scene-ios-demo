//
//  RCRadioRoomViewController+Session.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import SVProgressHUD
import RCSceneService
import RCSceneMusic
import RCSceneFoundation

fileprivate var kRadioRoomRtcRoomKey: Int = 1

extension RCRadioRoomViewController {
    
    var rtcRoom: RCRTCRoom? {
        get {
            objc_getAssociatedObject(self, &kRadioRoomRtcRoomKey) as? RCRTCRoom
        }
        set {
            objc_setAssociatedObject(self,
                                     &kRadioRoomRtcRoomKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue?.delegate = self
        }
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func session_viewDidLoad() {
        m_viewDidLoad()
        radioJoinRoom { _ in }
        roomKVState.delegate = self
        roomOwnerView.delegate = self
        RCRTCEngine.sharedInstance().statusReportDelegate = self
        RCChatRoomClient.shared().setChatRoomStatusDelegate(self)
        RCChatRoomClient.shared().setRCChatRoomKVStatusChangeDelegate(roomKVState)
    }
}

extension RCRadioRoomViewController {
    func dispatch_join(complation: @escaping (Result<Void, ReactorError>) -> Void) {
        let room = roomInfo
        queue.async {
            var result = Result<Void, ReactorError>.success(())
            let semaphore = DispatchSemaphore(value: 0)
            /// 加入聊天室
            RCChatRoomClient.shared()
                .joinChatRoom(room.roomId, messageCount: -1) {
                    semaphore.signal()
                } error: { code in
                    result = .failure(ReactorError("加入聊天室失败:\(code.rawValue)"))
                    semaphore.signal()
                }
            let _ = semaphore.wait(timeout: .now() + .seconds(8))
            if case .failure = result {
                return DispatchQueue.main.async { complation(result) }
            }
            
            /// 加入rtc
            let role: RCRTCLiveRoleType = room.isOwner ? .broadcaster : .audience
            let config = RCRTCRoomConfig()
            config.roomType = .live
            config.liveType = .audio
            config.roleType = role
            RCRTCEngine.sharedInstance()
                .joinRoom(room.roomId, config: config) { [unowned self] rtcRoom, code in
                    if let rtcRoom = rtcRoom, code == .success || code == .joinToSameRoom {
                        self.rtcRoom = rtcRoom
                    } else {
                        result = .failure(ReactorError("加入RTC失败:\(code.rawValue)"))
                    }
                    semaphore.signal()
                }
            semaphore.wait()
            if case .failure = result {
                return DispatchQueue.main.async { complation(result) }
            }
            
            /// 更新用户所属房间，静默操作
            radioRoomService.userUpdateCurrentRoom(roomId: room.roomId) { _ in }
            
            /// 房间加入成功
            DispatchQueue.main.async { complation(result) }
        }
    }
    
    func dispatch_leave(_ complation: @escaping (Result<Void, ReactorError>) -> Void) {
        queue.async { [unowned self] in
            var result = Result<Void, ReactorError>.success(())
            
            let semaphore = DispatchSemaphore(value: 0)
            
            /// 离开座位
            leaveSeat { res in
                result = res
                semaphore.signal()
            }
            let _ = semaphore.wait(timeout: .now() + .seconds(8))
            
            /// 离开聊天室
            RCChatRoomClient.shared().quitChatRoom(roomInfo.roomId) {
                semaphore.signal()
            } error: { code in
                result = .failure(ReactorError("离开聊天室失败:\(code.rawValue)"))
                semaphore.signal()
            }
            let _ = semaphore.wait(timeout: .now() + .seconds(8))
            
            /// 离开RTC
            RCRTCEngine.sharedInstance().leaveRoom { success, code in
                if success == false || code != .success {
                    result = .failure(ReactorError("离开RTC失败:\(code.rawValue)"))
                }
                semaphore.signal()
            }
            let _ = semaphore.wait(timeout: .now() + .seconds(8))
            
            /// 更新用户所属房间
            radioRoomService.userUpdateCurrentRoom(roomId: "") { _ in }
            
            /// 离开房间成功
            DispatchQueue.main.async { complation(result) }
        }
    }
}

extension RCRadioRoomViewController {
    
    func enterSeat(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        guard roomInfo.isOwner, let rtcRoom = rtcRoom else { return completion(.success(())) }
        rtcRoom.localUser
            .publishDefaultLiveStreams { success, code, liveInfo in
                if success == false || code != .success {
                    completion(.failure(ReactorError("发布流失败:\(code.rawValue)")))
                } else {
                    completion(.success(()))
                }
            }
        roomKVState.enterSeat()
        RCRTCEngine.sharedInstance()
            .defaultAudioStream
            .setMicrophoneDisable(roomKVState.mute)
    }
    
    func leaveSeat(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        guard roomInfo.isOwner, roomKVState.seating else { return completion(.success(())) }
        roomKVState.leaveSeat()
        RCRTCEngine.sharedInstance()
            .defaultAudioStream
            .setMicrophoneDisable(true)
        completion(.success(()))
    }
    
    func listenToTheRadio(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {
        if roomInfo.isOwner { return }
        guard let stream = rtcRoom?.getCDNStream() else { return }
        view.subviews.forEach { view in
            if view.isKind(of: RCRTCRemoteVideoView.self) {
                view.removeFromSuperview()
            }
        }
        let videoView = RCRTCRemoteVideoView()
        view.addSubview(videoView)
        stream.setVideoView(videoView)
        rtcRoom!.localUser
            .subscribeStream([stream], tinyStreams: []) { success, code in
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(ReactorError("订阅流失败:\(code.rawValue)")))
                }
            }
    }
    
    func relisten() {
        guard let stream = rtcRoom?.getCDNStream(), let rtcRoom = rtcRoom else { return }
        rtcRoom.localUser.unsubscribeStream(stream) { success, code in
            rtcRoom.localUser.subscribeStream([stream], tinyStreams: []) { success, code in
                
            }
        }
    }
}

extension RCRadioRoomViewController: RCRTCStatusReportDelegate {
    func didReport(_ form: RCRTCStatusForm) {
        DispatchQueue.main.async {
            self.handleReportDidChange(form)
        }
    }
    
    private func handleReportDidChange(_ form: RCRTCStatusForm) {
        roomInfoView.updateNetworking(rtt: form.rtt)
        if let status = form.sendStats.first(where: { $0.mediaType == RongRTCMediaTypeAudio }) {
            roomKVState.speak(status.audioLevel)
        }
    }
}

extension RCRadioRoomViewController: RCRTCRoomEventDelegate {
    func didJoin(_ user: RCRTCRemoteUser) {
        roomInfoView.updateRoomUserNumber()
    }
    
    func didLeave(_ user: RCRTCRemoteUser) {
        roomInfoView.updateRoomUserNumber()
    }
    
    func didPublishStreams(_ streams: [RCRTCInputStream]) {
        debugPrint(streams)
    }
    
    func didPublishLive(_ streams: [RCRTCInputStream]) {
        debugPrint(streams)
    }
    
    func didPublishCDNStream(_ stream: RCRTCCDNInputStream) {
        debugPrint(stream)
        rtcRoom?.localUser
            .subscribeStream([stream], tinyStreams: [], completion: { success, code in })
    }
}

extension RCRadioRoomViewController: RCRadioRoomOwnerViewProtocol {
    func masterViewDidClick() {
        guard roomInfo.isOwner else { return }
        if roomKVState.seating {
            let userId = Environment.currentUserId
            let isMute = roomKVState.mute
            radioRouter.trigger(.masterSeatOperation(userid: userId, isMute: isMute, delegate: self))
        } else {
            enterSeat { _ in }
        }
    }
}

extension RCRadioRoomViewController: VoiceRoomMasterSeatOperationProtocol {
    func didMasterLeaveButtonClicked() {
        leaveSeat { _ in }
        dismiss(animated: true, completion: nil)
    }
    
    func didMasterSeatMuteButtonClicked(_ isMute: Bool) {
        guard roomKVState.seating else { return }
        roomKVState.muteToggle()
        RCRTCEngine.sharedInstance()
            .defaultAudioStream
            .setMicrophoneDisable(roomKVState.mute)
    }
}

extension RCRadioRoomViewController: RCRadioRoomKVDelegate {
    func roomKVDidChanged(mute: Bool) {
        roomOwnerView.update(seat: mute)
    }
    
    func roomKVDidChanged(seating: Bool) {
        SceneRoomManager.shared.seatlist = [roomInfo.userId]
        roomOwnerView.update(seat: seating ? roomInfo.userId : nil)
    }
    
    func roomKVDidChanged(suspend: Bool) {
        if suspend {
            roomDidSuspend()
        } else {
            roomDidResume()
        }
    }
    
    func roomKVDidChanged(speaking: Bool) {
        roomOwnerView.update(radar: speaking)
        floatingManager?.setSpeakingState(isSpeaking: speaking)
    }
    
    func roomKVDidChanged(background: String) {
        NotificationNameRoomBackgroundUpdated.post((roomInfo.roomId, background))
    }
    
    func roomKVDidChanged(roomName: String) {
        roomInfo.roomName = roomName
        roomInfoView.updateRoom(info: roomInfo)
    }
    
    func roomKVDidSync() {
        roomInfo.roomName = roomKVState.roomName
        roomInfoView.updateRoom(info: roomInfo)
        roomOwnerView.update(radar: roomKVState.speaking)
        roomOwnerView.update(seat: roomKVState.seating ? roomInfo.userId : nil)
        roomOwnerView.update(seat: roomKVState.mute)
    }
}

extension RCRadioRoomViewController: RCChatRoomStatusDelegate {
    func onChatRoomJoining(_ chatroomId: String!) {
    }
    
    func onChatRoomJoined(_ chatroomId: String!) {
    }
    
    func onChatRoomJoinFailed(_ chatroomId: String!, errorCode: RCErrorCode) {
    }
    
    func onChatRoomReset(_ chatroomId: String!) {
    }
    
    func onChatRoomQuited(_ chatroomId: String!) {
    }
    
    func onChatRoomDestroyed(_ chatroomId: String!, type: RCChatRoomDestroyType) {
        print("room(\(chatroomId!) destroyed(\(type.rawValue)")
    }
}
