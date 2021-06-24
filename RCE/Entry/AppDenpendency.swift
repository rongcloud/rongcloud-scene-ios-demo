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
        let home: UINavigationController = {
            let instance = UINavigationController(rootViewController: HomeViewController())
            instance.tabBarItem = UITabBarItem(title: "首页", image: nil, selectedImage: nil)
            return instance
        }()
        window.rootViewController = home
        return window
    }
    
    static func configManagers(_ options: [UIApplication.LaunchOptionsKey: Any]?) {
        
    }
    
    static func configAppearence() {
        
    }
    
    static func configSDKs(_ options: [UIApplication.LaunchOptionsKey: Any]?) {
        /// 友盟初始化
        UMConfigure.initWithAppkey(Environment.current.umengKey, channel: "App Store")
        MobClick.setAutoPageEnabled(true)
        /// 初始化语聊房
        RCVoiceRoomEngine.sharedInstance().initWithAppkey(Environment.current.rcKey)
        if let rongToken = UserDefaults.standard.rongToken() {
            RCVoiceRoomEngine.sharedInstance().connect(withToken: rongToken) {
                debugPrint("connect token success")
            } error: { code, msg in
                debugPrint("connect token failed \(code) \(msg)")
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
    }
}
