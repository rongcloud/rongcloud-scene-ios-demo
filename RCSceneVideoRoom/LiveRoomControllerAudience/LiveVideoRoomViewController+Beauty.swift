//
//  LiveVideoRoomViewController+Beauty.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/26.
//

import Foundation
extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func beauty_viewDidLoad() {
        m_viewDidLoad()
    }
}

extension LiveVideoRoomViewController {
    /// 用户上麦后，设置摄像机参数和美颜
    func setupCapture() {
        /// 设置视频流参数
        let config = RCRTCVideoStreamConfig()
        config.videoSizePreset = .preset480x480
        config.videoFps = .FPS15
        config.minBitrate = 180
        config.maxBitrate = 800
        RCRTCEngine.sharedInstance().defaultVideoStream.videoConfig = config
        
        /// 开始直播
        RCRTCEngine.sharedInstance().defaultVideoStream.startCapture()
    }
    
    func didOutputFrame(_ frame: RCRTCVideoFrame) -> RCRTCVideoFrame {
        return beautyPlugin?.didOutput(frame) ?? frame
    }
}
