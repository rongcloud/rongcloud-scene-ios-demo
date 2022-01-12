//
//  AppDenpendency.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation
import UIKit
import SVProgressHUD
import IQKeyboardManager
import SwiftyBeaver
import SwiftUI

public let log = SwiftyBeaver.self

struct AppDependency {
    let window: () -> UIWindow
    let configManagers: (_ options: [UIApplication.LaunchOptionsKey: Any]?) -> Void
    let configureSDKs: (_ options: [UIApplication.LaunchOptionsKey: Any]?) -> Void
    let configureAppearence: () -> Void
}

final class CompositionRoot: NSObject {
    
    static func resolve() -> AppDependency {
        return AppDependency(window: configWindow,
                             configManagers: configManagers,
                             configureSDKs: configSDKs,
                             configureAppearence: configAppearence)
    }
    
    static func configWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        return window
    }
    
    static func configManagers(_ options: [UIApplication.LaunchOptionsKey: Any]?) {
        
    }
    
    static func configAppearence() {
        
    }
    
    static func configSDKs(_ options: [UIApplication.LaunchOptionsKey: Any]?) {
        /// 友盟初始化
        #warning("""
            "友盟提示:"
            "隐私协议中必须含有友盟说明，初始化必须放到用户同意隐私协议后."
            "参考:"
            "https://developer.umeng.com/docs/147377/detail/213789"
            """)
        UMConfigure.initWithAppkey(Environment.current.umengKey, channel: "App Store")
        MobClick.setAutoPageEnabled(true)
        UMConfigure.setLogEnabled(true)
        
        /// 初始化语聊房
        RCIM.shared().initWithAppKey(Environment.current.rcKey)
        RCIM.shared().registerMessageType(RCGiftBroadcastMessage.self)
        RCIM.shared().registerMessageType(RCPKGiftMessage.self)
        RCIM.shared().registerMessageType(RCPKStatusMessage.self)
        if let rongToken = UserDefaults.standard.rongToken() {
            RCIM.shared().connect(withToken: rongToken) { code in
                debugPrint("db error code is \(code)")
            } success: { userId in
                UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
                    RCIM.shared().currentUserInfo = user.rcUser
                }
            } error: { code in
                fatalError("Connect rongcloud failed")
            }
        }
        /// IMKit 全局参数
        RCKitConfig.default().ui.globalConversationAvatarStyle = .USER_AVATAR_CYCLE
        RCKitConfig.default().ui.globalMessageAvatarStyle = .USER_AVATAR_CYCLE
        RCKitConfig.default().ui.globalConversationPortraitSize = CGSize(width: 48.resize, height: 48.resize)
        RCKitConfig.default().ui.enableDarkMode = true
        
        RCChatroomMessageCenter.registerMessageTypes()
        /// 设置SVProgress
        SVProgressHUD.setMaximumDismissTimeInterval(2)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        SVProgressHUD.setDefaultStyle(.dark)
        /// 注册Router
        Router.default.setupAppNavigation(appNavigation: RCAppNavigation())
        /// 适配UI
        Adaptor.set(design: CGSize(width: 375, height: 651))
        /// 设置RxSwift 的ImagePicker
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        /// 禁止constraint log
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        /// Keyboard
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        /// Style
        AppStyle.defaultApperance()
        // Bugly
        Bugly.start(withAppId: Environment.current.buglyKey)
        
        UNUserNotificationCenter.current()
            .getNotificationSettings { (settings) in
                switch settings.authorizationStatus {
                case .authorized:
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                case .notDetermined:
                    UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
                            if granted {
                                DispatchQueue.main.async {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            }
                        }
                default:
                    break
                }
            }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // SwiftBeaver 添加输出到 console
        let console = ConsoleDestination()
        log.addDestination(console)

        // 把 imlog 写入文件
//        RCIMClient.shared().logLevel = .log_Level_Verbose
//        NSString.redirectNSlogToDocumentFolder()
        
        // HIFIVE
        if Environment.currentUserId.count > 0 {
            RCMusicEngine.shareInstance().delegate = DelegateImpl.instance
            RCMusicEngine.shareInstance().player = PlayerImpl.instance
            RCMusicEngine.shareInstance().dataSource = DataSourceImpl.instance
        }
         
        MHSDK.shareInstance().`init`(Environment.MHBeautyKey)
        
        RCNetworkReach.active()
    }
}
