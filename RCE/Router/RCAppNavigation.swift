//
//  RCRouter.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import UIKit
import RCSceneCall
import RCSceneLoginKit
import RCSceneCommunity


enum RCNavigation: Navigation {
    case createRoom(imagelist: [String])
    case login
    case userInfoEdit
    case inputPassword(RCSRPasswordCompletion)
    case messagelist
    case privateChat(userId: String)
    case dial(type: CallType)
    case promotion
    case promotionDetail
    case feedback
}

struct RCAppNavigation: AppNavigation {
    func navigate(_ navigation: Navigation, from: UIViewController, to: UIViewController) {
        if let router = navigation as? RCNavigation {
            switch router {
            case .createRoom,
                    .login,
                    .userInfoEdit,
                    .inputPassword,
                    .promotion,
                    .promotionDetail,
                    .feedback:
                from.present(to, animated: true, completion: nil)
            default:
                from.navigationController?.pushViewController(to, animated: true)
            }
        }
    }
    
    func viewControllerForNavigation(navigation: Navigation) -> UIViewController {
        guard let router = navigation as? RCNavigation else {
            return UIViewController()
        }
        switch router {
        case let .createRoom(imagelist):
            let vc = CreateVoiceRoomViewController(imagelist: imagelist)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case .login:
            let vc = RCSLoginViewController()
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            vc.successCompletion = { [weak vc] (userInfo) in
                let user = userInfo
                let rcsc_User = RCSCUser.init(userId: user.userId, userName: user.userName, portrait: user.portrait, imToken: user.imToken, authorization: user.authorization, type: user.type, sex: user.sex ) //FIXME:这里先默认sex,后期拿到可以重新定义接口
                RCSCUser.loadUser(user: rcsc_User)
                rcsc_User.rCSCstorageUser()

                RCCoreClient.shared().connect(withToken: userInfo.imToken) { dbErrorCode in
                    debugPrint("db error code \(dbErrorCode)")
                } success: { userId in
                    RCSensor.shared?.login(withKey: "$identity_login_id", loginId: userId!)
                    RCSensor.shared?.set(["mobile": userInfo.phone])
                    UserDefaults.standard.set(user: User(userId: userInfo.userId,
                                                         userName: userInfo.userName,
                                                         portrait: userInfo.portrait,
                                                         imToken: userInfo.imToken,
                                                         authorization: userInfo.authorization,
                                                         type: userInfo.type))
                    UserDefaults.standard.set(mobile: userInfo.phone)
                    UserDefaults.standard.set(authorization: userInfo.authorization)
                    UserDefaults.standard.set(rongCloudToken: userInfo.imToken)
                    DispatchQueue.main.async {
                        vc?.dismiss(animated: true, completion: nil)
                        NotificationNameLogin.post()
                    }
                    RCSceneUserManager.shared.fetchUserInfo(userId: userInfo.userId) { user in
                        RCIM.shared().currentUserInfo = user.rcUser
                    }
                } error: { errorCode in
                    debugPrint("connect token failed \(errorCode.rawValue)")
                }
            }
            return vc
        case .userInfoEdit:
            let vc = UserInfoEditViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case let .inputPassword(completion):
            let vc = RCSRPasswordViewController()
            vc.completion = completion
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case .messagelist:
            let vc = ChatListViewController(.ConversationType_PRIVATE)
            vc.hidesBottomBarWhenPushed = true
            return vc
        case let .privateChat(userId):
            let controller = ChatViewController(.ConversationType_PRIVATE, userId: userId)
            controller.hidesBottomBarWhenPushed = true
            return controller
        case let .dial(type):
            return DialViewController(type: type)
        case .promotion:
            let vc = PromotionViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case .promotionDetail:
            let vc = MineViewController()
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case .feedback:
            let vc = FeelingFeedbackViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        }
    }
}

extension UIViewController {
    @discardableResult
    func navigator(_ navigation: RCNavigation) -> UIViewController {
        return navigate(navigation as Navigation)
    }
}
