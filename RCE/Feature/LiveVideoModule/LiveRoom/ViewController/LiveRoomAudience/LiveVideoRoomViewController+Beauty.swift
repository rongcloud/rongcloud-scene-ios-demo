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
        config.minBitrate = 500
        config.maxBitrate = 1000
        RCRTCEngine.sharedInstance().defaultVideoStream.videoConfig = config
        
        /// 设置美颜
        setupBeautyManagerIfNeeded()
        
        /// 开始直播
        RCRTCEngine.sharedInstance().defaultVideoStream.startCapture()
    }
    
    func didOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer?) -> Unmanaged<CMSampleBuffer>? {
        guard let sampleBuffer = sampleBuffer else { return nil }
        guard
            let osTypeHandler = osTypeHandler,
            let beautyManager = beautyManager,
            let processedSampleBuffer = osTypeHandler.onGPUFilterSource(sampleBuffer),
            let pixelBuffer = CMSampleBufferGetImageBuffer(processedSampleBuffer.takeUnretainedValue())
        else { return Unmanaged.passUnretained(sampleBuffer) }
        beautyManager.process(with: pixelBuffer, formatType: kCVPixelFormatType_32BGRA)
        return processedSampleBuffer
    }
    
    private func setupBeautyManagerIfNeeded() {
        if osTypeHandler == nil {
            osTypeHandler = ChatGPUImageHandler()
        }
        if beautyManager == nil {
            beautyManager = MHBeautyManager()
            beautyManager?.setupDefault()
        }
    }
}
