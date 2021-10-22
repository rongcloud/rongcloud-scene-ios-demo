//
//  LiveVideoRoomHostController+Audio.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import SVProgressHUD
import CoreGraphics
import SwiftUI

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func engine_viewDidLoad() {
        m_viewDidLoad()
        
        /// 视频码率对照表：https://support.rongcloud.cn/ks/MTA3OA==
        let config = RCRTCVideoStreamConfig()
        config.videoSizePreset = .preset1280x720
        config.videoFps = .FPS15
        config.minBitrate = 2000;
        config.maxBitrate = 2500;
        RCRTCEngine.sharedInstance().defaultVideoStream.videoConfig = config
        
        RCLiveVideoEngine.shared().prepare()
        RCLiveVideoEngine.shared().delegate = self
    }
    
    private func fetchManagerList() {
        let api: RCNetworkAPI = .roomManagers(roomId: room.roomId)
        networkProvider.request(api) { [weak self] result in
            switch result.map(ManagerListWrapper.self) {
            case let .success(wrapper):
                guard let self = self else { return }
                self.managers = wrapper.data ?? []
            case let.failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension LiveVideoRoomHostController: LiveVideoRoomCreationDelegate {
    func didCreate(_ room: VoiceRoom) {
        self.room = room
        self.rebuildLayout()
        self.setupMessageView()
        self.setupToolBarView()
        self.fetchManagerList()
        
        let roomId = room.roomId
        /// 开启直播
        RCLiveVideoEngine.shared().begin(room.roomId) { code in
            if code == .success {
                RCRTCEngine.sharedInstance().defaultVideoStream.startCapture()
                
                let seat = RCVoiceSeatInfo()
                seat.userId = Environment.currentUserId
                SceneRoomManager.shared.seatlist = [seat]
                
                networkProvider.request(.userUpdateCurrentRoom(roomId: roomId)) { _ in }
            } else {
                SVProgressHUD.showError(withStatus: "开始直播失败：\(code.rawValue)")
            }
        }
    }
    
    func restore(_ room: VoiceRoom) {
        self.room = room
        self.rebuildLayout()
        self.setupMessageView()
        self.setupToolBarView()
        self.fetchManagerList()
        
        let roomId = room.roomId
        /// 开启直播
        RCLiveVideoEngine.shared().begin(room.roomId) { code in
            if code == .success {
                RCRTCEngine.sharedInstance().defaultVideoStream.startCapture()
                networkProvider.request(.userUpdateCurrentRoom(roomId: roomId)) { _ in }
            } else {
                SVProgressHUD.showError(withStatus: "开始直播失败：\(code.rawValue)")
            }
        }
    }
}

extension LiveVideoRoomHostController: RCLiveVideoDelegate {
    func roomInfoDidSync() {
        roomInfoView.updateRoom(info: room)
    }
    
    func userDidKickOut(_ userId: String, byOperator operatorId: String) {
        handleKickOutRoom(userId, by: operatorId)
    }
    
    func didOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer?) -> Unmanaged<CMSampleBuffer>? {
        guard let sampleBuffer = sampleBuffer else { return nil }
        guard let processedSampleBuffer = gpuHandler.onGPUFilterSource(sampleBuffer) else {
            return Unmanaged.passUnretained(sampleBuffer)
        }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(processedSampleBuffer.takeUnretainedValue()) else {
            return Unmanaged.passUnretained(sampleBuffer)
        }
        beautyManager.process(with: pixelBuffer, formatType: kCVPixelFormatType_32BGRA)
        return processedSampleBuffer
    }
    
    func liveVideoDidUpdate(_ userIds: [String]) {
        var liveUsers: [String] = userIds.filter { $0.count > 1 }
        toolBarView.micState = liveUsers.count == 0 ? .request : .connecting
        liveUsers.append(Environment.currentUserId)
        SceneRoomManager.shared.seatlist = liveUsers.map { userId in
            let seat = RCVoiceSeatInfo()
            seat.userId = userId
            return seat
        }
        debugPrint("live video users: \(liveUsers)")
    }
    
    func liveVideoRequestDidChange() {
        RCLiveVideoEngine.shared().getRequests { [weak self] code, userIds in
            self?.toolBarView.update(users: userIds.count)
        }
    }
    
    func liveVideoInvitationDidAccept(_ userId: String) {
        toolBarView.micState = .connecting
    }
    
    func liveVideoInvitationDidReject(_ userId: String) {
        UserInfoDownloaded.shared.fetch([userId]) { users in
            guard let user = users.first else { return }
            SVProgressHUD.showInfo(withStatus: "\(user.userName)拒绝上麦")
        }
        toolBarView.micState = .request
    }
    
    func userDidEnter(_ userId: String) {
        handleUserEnter(userId)
        roomInfoView.updateRoomUserNumber()
    }
    
    func userDidExit(_ userId: String) {
        handleUserExit(userId)
        roomInfoView.updateRoomUserNumber()
    }
    
    func messageDidReceive(_ message: RCMessage) {
        handleReceivedMessage(message)
    }
    
    func network(_ delay: Int) {
        if room == nil { return }
        roomInfoView.updateNetworking(rtt: delay)
    }
    
    func liveVideoUserDidClick(_ userId: String) {
        let dependency = VoiceRoomUserOperationDependency(room: room,
                                                          presentUserId: userId)
        navigator(.manageUser(dependency: dependency, delegate: self))
    }
    
    func liveVideoUserDidLayout(_ frameInfo: [String : NSValue]) {
        layoutLiveVideoView(frameInfo)
    }
    
    func roomInfoDidUpdate(_ key: String, value: String) {
        if key == "gift" { roomGiftView.update(value) }
    }
}
