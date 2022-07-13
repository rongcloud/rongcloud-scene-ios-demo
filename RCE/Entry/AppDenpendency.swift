//
//  AppDenpendency.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import SwiftyBeaver
import RCSceneVoiceRoom
import RCSceneVideoRoom

import RCSceneCommunity

struct AppDependency {
    let window: () -> UIWindow
    let configManagers: (_ options: [UIApplication.LaunchOptionsKey: Any]?) -> Void
    let configureSDKs: (_ options: [UIApplication.LaunchOptionsKey: Any]?) -> Void
    let configureAppearance: () -> Void
}

final class CompositionRoot: NSObject {
    
    static func resolve() -> AppDependency {
        return AppDependency(window: configWindow,
                             configManagers: configManagers,
                             configureSDKs: configSDKs,
                             configureAppearance: configAppearance)
    }
    
    static func configWindow() -> UIWindow {
        return UIWindow(frame: UIScreen.main.bounds)
    }
    
    static func configManagers(_ options: [UIApplication.LaunchOptionsKey: Any]?) {
        AppConfigs.config()
    }
    
    static func configAppearance() {
        
    }
    
    static func configSDKs(_ options: [UIApplication.LaunchOptionsKey: Any]?) {
        /// 初始化语聊房
        RCIM.shared().initWithAppKey(AppConfigs.RCKey)
        
        RCIM.shared().registerMessageType(RCGiftBroadcastMessage.self)
        RCIM.shared().registerMessageType(RCPKGiftMessage.self)
        RCIM.shared().registerMessageType(RCPKStatusMessage.self)
        RCIM.shared().registerMessageType(RCShuMeiMessage.self)
        RCIM.shared().registerMessageType(RCLoginDeviceMessage.self)
        RCChatroomMessageCenter.registerMessageTypes()
        #warning("丢失链接临时解决方案")
        if let rongToken = UserDefaults.standard.rongToken() {
            //TODO: connect 丢失链接，临时解决方法
            DispatchQueue.main.async {
                RCIM.shared().connect(withToken: rongToken) { code in
                    debugPrint("db error code is \(code)")
                } success: { userId in
                    networkProvider.request(.loginDevice) { result in
                        switch result {
                        case .success(let response):
                            print(response)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    RCSceneUserManager.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
                        RCIM.shared().currentUserInfo = user.rcUser
                    }
                } error: { code in
                    fatalError("Connect rongcloud failed")
                }
            }
        }
        /// IMKit 全局参数
        RCKitConfig.default().ui.globalConversationAvatarStyle = .USER_AVATAR_CYCLE
        RCKitConfig.default().ui.globalMessageAvatarStyle = .USER_AVATAR_CYCLE
        RCKitConfig.default().ui.globalConversationPortraitSize = CGSize(width: 48.resize, height: 48.resize)
        RCKitConfig.default().ui.enableDarkMode = true
        
        /// 设置SVProgress
        SVProgressHUD.setMaximumDismissTimeInterval(2)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        SVProgressHUD.setDefaultStyle(.dark)
        /// 注册Router
        Router.default.setupAppNavigation(appNavigation: RCAppNavigation())
        /// 适配UI
        Adaptor.set(design: CGSize(width: 375, height: 667))
        /// 设置RxSwift 的ImagePicker
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        /// 禁止constraint log
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        /// Style
        AppStyle.defaultApperance()
        
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
        RCSRLog.addDestination(console)

        // 把 imlog 写入文件
//        RCIMClient.shared().logLevel = .log_Level_Verbose
//        NSString.redirectNSlogToDocumentFolder()
        
        RCBeautyPlugin.active()
        RCNetworkReach.active()
        
        //FIXME: 后期讨论后再调整.保证RCSceneCommunity和RCE 相对独立互补影响
        var serviceHostStr = Environment.url.absoluteString
        if "/" == serviceHostStr[serviceHostStr.index(before: serviceHostStr.endIndex)] {
            print("serviceHostStr -> /")
            serviceHostStr.remove(at: serviceHostStr.index(before: serviceHostStr.endIndex))
            print(serviceHostStr)
        }
        
        RCSCConfig.loadConfig(serviceHost: serviceHostStr, businessToken: Environment.businessToken)
        RCCoreClient.shared().initWithAppKey(Environment.rcKey)
    }
}

extension RCSceneRoomUser {
    public var rcUser: RCUserInfo {
        return RCUserInfo(userId: userId, name: userName, portrait: portraitUrl)
    }
}
