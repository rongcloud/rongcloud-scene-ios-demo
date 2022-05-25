//
//  RCBeautyPlugin.swift
//  RCE
//
//  Created by shaoshuai on 2022/1/12.
//

import AVFoundation
import RCSceneVideoRoom

#if canImport(MHBeautySDK)

class RCBeautyPlugin {
    
    private static var isActive: Bool = false

    /// 美狐美颜管理实例
    private(set) lazy var beautyManager: MHBeautyManager = {
        let instance = MHBeautyManager()
        instance.applyDefaultValues()
        return instance
    }()

    /// 美狐美颜管理控制器
    private(set) lazy var controller: MHBeautyViewController = {
        let instance = MHBeautyViewController(manager: beautyManager)
        instance.enableClickingDismiss()
        return instance
    }()
    
    /// 美狐美颜初始化
    static func active() {
        if isActive { return }
        isActive = true
        MHSDK.shareInstance().`init`(AppConfigs.MHBeautyKey)
    }
    
    deinit {
        beautyManager.destroy()
    }
}

extension RCBeautyPlugin: RCBeautyPluginDelegate {
    func didClick(_ action: RCBeautyAction) {
        UIApplication.shared.keyWindow()?
            .rootViewController?
            .present(controller, animated: true)
        controller.showItem(action.item)
    }

    func didOutput(_ frame: RCRTCVideoFrame) -> RCRTCVideoFrame {
        var tmpPixelBuffer: CVPixelBuffer?
        let result = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(frame.width),
                                         Int(frame.height),
                                         kCVPixelFormatType_32BGRA,
                                         nil,
                                         &tmpPixelBuffer)
        guard
            result == kCVReturnSuccess,
            let pixelBuffer = tmpPixelBuffer
        else { return frame }
        frame.convert(to: pixelBuffer)
        beautyManager.process(with: pixelBuffer, formatType: kCVPixelFormatType_32BGRA)
        
        var timingInfo = CMSampleTimingInfo()
        timingInfo.presentationTimeStamp = CMTime(value: frame.timeStampNs, timescale: 1000000000)
        
        var tmpVideoInfo: CMVideoFormatDescription?
        let status = CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil,
                                                                  imageBuffer: pixelBuffer,
                                                                  formatDescriptionOut: &tmpVideoInfo)
        guard status == noErr, let videoInfo = tmpVideoInfo else { return frame }
        
        var tmpSampleBuffer: CMSampleBuffer?
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                           imageBuffer: pixelBuffer,
                                           dataReady: true,
                                           makeDataReadyCallback: nil,
                                           refcon: nil,
                                           formatDescription: videoInfo,
                                           sampleTiming: &timingInfo,
                                           sampleBufferOut: &tmpSampleBuffer)
        guard let sampleBuffer = tmpSampleBuffer else { return frame }
        
        let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: true)
        let dict = unsafeBitCast(CFArrayGetValueAtIndex(attachments, 0), to: CFMutableDictionary.self)
        let key = Unmanaged.passUnretained(kCMSampleAttachmentKey_DisplayImmediately).toOpaque()
        let value = Unmanaged.passUnretained(kCFBooleanTrue).toOpaque()
        CFDictionarySetValue(dict, key, value)
        
        return RCRTCVideoFrame(sampleBuffer: sampleBuffer, rotation: frame.rotation)
    }
}

extension RCBeautyAction {
    var item: RCMHBeautyType {
        switch self {
        case .sticker: return .sticker
        case .retouch: return .retouch
        case .makeup: return .makeup
        case .effect: return .effect
        }
    }
}

#else

class RCBeautyPlugin {
    /// 美颜初始化方法
    static func active() {}
}

extension RCBeautyPlugin: RCBeautyPluginDelegate {
    func didClick(_ action: RCBeautyAction) {}
    func didOutput(_ frame: RCRTCVideoFrame) -> RCRTCVideoFrame { frame }
}

#endif
