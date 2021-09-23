//
//  AppDelegate.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
  var window: UIWindow?
  private let dependency = CompositionRoot.resolve()
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//    UIViewController.swizzIt()
    dependency.configManagers(launchOptions)
    dependency.configureSDKs(launchOptions)
    dependency.configureAppearence()
    window = dependency.window()
    window?.makeKeyAndVisible()
    
    RCIM.shared().clearUserInfoCache()
    RCIM.shared().userInfoDataSource = self
    RCIM.shared().enablePersistentUserInfoCache = true

    window?.overrideUserInterfaceStyle = .light
    
    UNUserNotificationCenter.current().delegate = self
    
    return true
  }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        RCIMClient.shared().setDeviceTokenData(deviceToken)
    }
}

extension AppDelegate: RCIMUserInfoDataSource {
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { user in
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
