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
    UIViewController.swizzIt()
    dependency.configManagers(launchOptions)
    dependency.configureSDKs(launchOptions)
    dependency.configureAppearence()
    window = dependency.window()
    window?.makeKeyAndVisible()
    
    RCIM.shared().clearUserInfoCache()
    RCIM.shared().userInfoDataSource = self
    RCIM.shared().enablePersistentUserInfoCache = true
    
    window?.overrideUserInterfaceStyle = .light
    
    return true
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
