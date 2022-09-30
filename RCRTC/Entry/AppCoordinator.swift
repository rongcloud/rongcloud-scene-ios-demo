//
//  AppCoordinator.swift
//  RCE
//
//  Created by shaoshuai on 2022/2/21.
//

import XCoordinator
import UIKit


enum AppRouter: Route {
    case community
    case recreational
    case discoverNew
    case message
    case profile
}

func tabItem(title: String?, image: UIImage?, selectedImage: UIImage?) -> UITabBarItem {
    let item = UITabBarItem(title: title, image: image, selectedImage:selectedImage)
    item.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .selected)
    item.setTitleTextAttributes([.foregroundColor : UIColor.init(hexString: "0xC8CCD4")], for: .normal)
    return item
}

class AppCoordinator: TabBarCoordinator<AppRouter> {
    private let community = CommunityCoordinator()
    private let recreational = HomeCoordinator()
    private let discoverNew = DiscoverNewCoordinator()
    private let message = MessageCoordinator()
    private let profile = ProfileCoordinator()

    init() {
        community.viewController.tabBarItem = tabItem(title: "社区", image: R.image.new_tab_bar_community(), selectedImage:R.image.new_tab_bar_community_select())
        community.viewController.tabBarItem.tag = 0
         
        recreational.viewController.tabBarItem = tabItem(title: "娱乐", image: R.image.new_tab_bar_recreational(), selectedImage:R.image.new_tab_bar_recreational_select())
        recreational.viewController.tabBarItem.tag = 1
        
        discoverNew.viewController.tabBarItem = tabItem(title: "发现", image: R.image.new_tab_bar_discover(), selectedImage:R.image.new_tab_bar_discover_select())
        discoverNew.viewController.tabBarItem.tag = 2
        
        message.viewController.tabBarItem = tabItem(title: "消息", image: R.image.new_tab_bar_msg(), selectedImage:R.image.new_tab_bar_msg_select())
        message.viewController.tabBarItem.tag = 3
        
        profile.viewController.tabBarItem = tabItem(title: "我的", image: R.image.new_tab_bar_profile(), selectedImage:R.image.new_tab_bar_profile_select())
        profile.viewController.tabBarItem.tag = 4
        
       super.init(tabs: [community, recreational, discoverNew, message, profile], select: community)

        
        
        NotificationCenter.default.addObserver(self, selector: #selector(observerNotification(notification:)), name: NSNotification.Name(rawValue:"ConversationType_PRIVATE_SYSTEM_UnReadCount"), object: nil)
        let num1 = NSNumber(value: RCConversationType.ConversationType_PRIVATE.rawValue)
        let count1 = RCIMClient.shared().getUnreadCount([num1])
        let num2 = NSNumber(value: RCConversationType.ConversationType_SYSTEM.rawValue)
        let count2 = RCIMClient.shared().getUnreadCount([num2])
        let countAll = count1 + count2
        if countAll > 0 {
            rootViewController.tabBar.showBadgeOnItemIndex(3)
        }
        
        
        rootViewController.tabBar.isTranslucent = false
        rootViewController.tabBar.barTintColor = .white
        rootViewController.tabBar.backgroundColor = .white
    }
                                               
       @objc func observerNotification(notification:Notification) {
//           let userInfo = notification.userInfo as! [String: AnyObject]
//           let count1 = userInfo["unReadCount_PRIVATE"] as? Int
//           let count2 = userInfo["unReadCount_SYSTEM"] as? Int
//
//           let countAll = Int(count1 ?? 0 ) + Int(count2 ?? 0)
           let num1 = NSNumber(value: RCConversationType.ConversationType_PRIVATE.rawValue)
           let count1 = RCIMClient.shared().getUnreadCount([num1])
           let num2 = NSNumber(value: RCConversationType.ConversationType_SYSTEM.rawValue)
           let count2 = RCIMClient.shared().getUnreadCount([num2])
           
           let countAll = count1 + count2
           if countAll > 0 {
               rootViewController.tabBar.showBadgeOnItemIndex(3)
           }else{
               rootViewController.tabBar.hideBadgeOnItemIndex(3)
           }
          
       }
                                
    override func prepareTransition(for route: AppRouter) -> TabBarTransition {
        switch route {
        case .community:
            return .trigger(.community, on: community)
        case .recreational:
            return .trigger(.home, on: recreational)
        case .discoverNew:
            return .trigger(.discoverNew, on: discoverNew)
        case .message:
            return .trigger(.message, on: message)
        case .profile:
            return .trigger(.profile, on: profile)
        }
    }
}
