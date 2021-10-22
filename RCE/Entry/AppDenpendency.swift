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
        RCVoiceRoomEngine.sharedInstance().initWithAppkey(Environment.current.rcKey)
        RCCoreClient.shared().registerMessageType(RCGiftBroadcastMessage.self)
        RCCoreClient.shared().registerMessageType(RCPKGiftMessage.self)
        if let rongToken = UserDefaults.standard.rongToken() {
            RCVoiceRoomEngine.sharedInstance().connect(withToken: rongToken) {
                UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
                    RCIM.shared().currentUserInfo = user.rcUser
                }
               // SVProgressHUD.showSuccess(withStatus: "连接融云成功")
            } error: { errorCode, msg in
                fatalError("Connect rongcloud failed")
               // SVProgressHUD.showError(withStatus: "连接融云失败")
            }
        }
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
        
        let console = ConsoleDestination()
        log.addDestination(console)
        
        // HIFIVE
        if Environment.currentUserId.count > 0 {
            HFOpenApiManager.shared().registerApp(withAppId: "hifive app id", serverCode: "hifive server code", clientId: Environment.currentUserId, version: "V4.1.2") { _ in
                log.verbose("register hifive success")
            } fail: { error in
                fatalError("Register Hi five failed")
            }
        }
        // log
//        RCIMClient.shared().logLevel = .log_Level_Verbose
//        NSString.redirectNSlogToDocumentFolder()
        
        MHSDK.shareInstance().`init`("美狐美颜key")
    }
}
