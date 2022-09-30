//
//  RCBeautyPlugin.swift
//  RCE
//
//  Created by shaoshuai on 2022/1/12.
//

import Foundation
import AVFoundation
import RCSceneVideoRoom
import RCSceneFaceBeautyKit

class RCBeautyPlugin {
    
    private static var isActive: Bool = false
    
    /// 相芯美颜初始化
    static func active() {
        if isActive { return }
        isActive = true
        let authData: UnsafeMutablePointer<CChar> = transform(&g_auth_package)
        let size = MemoryLayout.size(ofValue: g_auth_package)
        RCSBeautyEngine.sharedInstance().register(withAuthPackage: authData, authSize: Int32(size))
        RCSBeautyEngine.sharedInstance().setBeautyEnable(true)
    }
    
    
    private static func transform(_ data: UnsafeMutableRawPointer) -> UnsafeMutablePointer<CChar> {
        let dataPointer: UnsafeMutableRawPointer = data
        let opaque = OpaquePointer(dataPointer)
        print(opaque.debugDescription.count)
        let result = UnsafeMutablePointer<CChar>(opaque)
        return result
    }
    
}

extension RCBeautyPlugin: RCBeautyPluginDelegate {
    
    func didClick(_ action: RCBeautyAction) {
        guard let rootVC = UIApplication.shared.keyWindow()?.rootViewController else { return }
        RCSBeautyEngine.sharedInstance().show(in: rootVC, withType: Int32(action.item))
    }
    
    func didOutput(_ frame: RCRTCVideoFrame) -> RCRTCVideoFrame { frame }
}

extension RCBeautyAction {
    var item: Int {
        switch self {
        case .retouch: return 0
        case .sticker: return 1
        case .makeup: return 2
        case .effect: return 3
        }
    }
    
}
