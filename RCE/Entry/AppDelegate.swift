//
//  AppDelegate.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import UIKit
import XCoordinator
import RCSceneVoiceRoom

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private let appRouter = AppCoordinator().strongRouter
    private let dependency = CompositionRoot.resolve()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dependency.configManagers(launchOptions)
        dependency.configureSDKs(launchOptions)
        dependency.configureAppearance()
        window = dependency.window()
        appRouter.setRoot(for: window!)
        window?.makeKeyAndVisible()
        
        RCCoreClient.shared().add(self)
        
        
        RCIM.shared().clearUserInfoCache()
        RCIM.shared().userInfoDataSource = self
        RCIM.shared().enablePersistentUserInfoCache = true
        
        window?.overrideUserInterfaceStyle = .light
        UNUserNotificationCenter.current().delegate = self
        
        let serverString = Environment.sensorServer
        RCSensor.start(serverString, launchOptions: launchOptions)
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        RCIMClient.shared().setDeviceTokenData(deviceToken)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        SensorsAnalyticsSDK.sharedInstance()?.handleSchemeUrl(url) == true
    }
}

extension AppDelegate: RCIMUserInfoDataSource {
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        RCSceneUserManager.shared.fetchUserInfo(userId: userId) { user in
            let userInfo = RCUserInfo(userId: userId, name: user.userName, portrait: user.portraitUrl)
            completion?(userInfo)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {
        print("userNotificationCenter openSettings")
    }
}

extension AppDelegate : RCIMClientReceiveMessageDelegate{
    public func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        guard let msg = message, msg.conversationType == .ConversationType_PRIVATE || msg.conversationType == .ConversationType_SYSTEM else {
            return
        }
        DispatchQueue.main.async {
            if msg.conversationType == .ConversationType_PRIVATE {
                let count = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"ConversationType_PRIVATE_SYSTEM_UnReadCount"), object: self, userInfo: ["unReadCount_PRIVATE":Int(count)])
            } else {
                let count = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_SYSTEM.rawValue])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"ConversationType_PRIVATE_SYSTEM_UnReadCount"), object: self, userInfo: ["unReadCount_SYSTEM": Int(count)])
            }
        }
    }
}
