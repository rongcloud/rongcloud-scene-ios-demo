//
//  RCRouter.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import Foundation

enum RCNavigation: Navigation {
    case voiceRoom(roomInfo: VoiceRoom, needCreate: Bool)
    case createRoom(imagelist: [String])
    case login
    case userInfoEdit
    case roomSetting([RoomSettingItem], VoiceRoomSettingProtocol)
    case requestOrInvite(roomId: String, delegate: HandleRequestSeatProtocol, showPage: Int, onSeatUserIds:[String])
    case masterSeatOperation(String, Bool, VoiceRoomMasterSeatOperationProtocol)
    case userSeatPop(seatIndex: UInt, isUserMute: Bool, isSeatMute: Bool, delegate: VoiceRoomSeatedOperationProtocol)
    case manageUser(dependency: VoiceRoomUserOperationDependency, delegate: VoiceRoomUserOperationProtocol?)
    case ownerClickEmptySeat(RCVoiceSeatInfo, UInt, VoiceRoomEmptySeatOperationProtocol)
    case inputText(name: String, delegate: VoiceRoomInputTextProtocol)
    case inputPassword(type: PasswordViewType, delegate: VoiceRoomInputPasswordProtocol?)
    case requestSeatPop(delegate: RequestSeatPopProtocol)
    case changeBackground(imagelist: [String], delegate: ChangeBackgroundImageProtocol)
    case inputMessage(roomId: String, delegate: VoiceRoomInputMessageProtocol)
    case userlist(dependency: VoiceRoomUserOperationDependency, delegate: VoiceRoomUserOperationProtocol)
    case messagelist
    case privateChat(userId: String)
    case gift(dependency: VoiceRoomGiftDependency, delegate: VoiceRoomGiftViewControllerDelegate)
    case giftCount(sendView: VoiceRoomGiftSendView)
    case voiceRoomAlert(title: String, actions: [VoiceRoomAlertAction], alertType: String, delegate: VoiceRoomAlertProtocol?)
    case leaveAlert(isOwner: Bool, delegate: LeaveViewProtocol)
    case dial(type: CallType)
    case promotion
    case promotionDetail
    case feedback
    case notice(modify: Bool = false, notice: String, delegate: VoiceRoomNoticeDelegate)
    case forbiddenList(roomId: String)
    case onlineRooms(selectingUserId: String?, delegate: OnlineRoomCreatorDelegate)
}

struct RCAppNavigation: AppNavigation {
    func navigate(_ navigation: Navigation, from: UIViewController, to: UIViewController) {
        if let router = navigation as? RCNavigation {
            switch router {
            case .createRoom,
                 .login,
                 .userInfoEdit,
                 .roomSetting,
                 .requestOrInvite,
                 .masterSeatOperation,
                 .userSeatPop,
                 .manageUser,
                 .ownerClickEmptySeat,
                 .inputText,
                 .inputPassword,
                 .requestSeatPop,
                 .changeBackground,
                 .inputMessage,
                 .userlist,
                 .gift,
                 .giftCount,
                 .voiceRoomAlert,
                 .leaveAlert,
                 .promotion,
                 .promotionDetail,
                    .feedback,
                    .notice,
                    .forbiddenList,
                    .onlineRooms:
                from.present(to, animated: true, completion: nil)
            default:
                from.navigationController?.pushViewController(to, animated: true)
            }
        }
    }
    
    func viewcontrollerForNavigation(navigation: Navigation) -> UIViewController {
        guard let router = navigation as? RCNavigation else {
            return UIViewController()
        }
        switch router {
        case let .createRoom(imagelist):
            let vc = CreateVoiceRoomViewController(imagelist: imagelist)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case let .voiceRoom(roomInfo, needCreate):
            return VoiceRoomViewController(roomInfo: roomInfo, isCreate: needCreate)
        case .login:
            let vc = LoginViewController()
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            return vc
        case .userInfoEdit:
            let vc = UserInfoEditViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case let .roomSetting(items, delegate):
            let vc = VoiceRoomSettingViewController(items: items, delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case let .requestOrInvite(roomId, delegate, page, list):
            return RequestOrInviteViewController(roomId: roomId, delegate: delegate, showPage: page, onSeatUserIds: list)
        case let .masterSeatOperation(userId, isMute, object):
            let vc = VoiceRoomMasterSeatOperationViewController(userId: userId, isMute: isMute, delegate: object)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case let .userSeatPop(seatIndex, isUserMute, isSeatMute, delegate):
            let vc = VoiceRoomSeatedOperationViewController(seatIndex: seatIndex, isMute: isUserMute,delegate: delegate, isSeatMute: isSeatMute)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case let .manageUser(dependency, delegate):
            let vc = VoiceRoomUserOperationViewController(dependency: dependency, delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case let .ownerClickEmptySeat(info, index, delegate):
            let vc = VoiceRoomEmptySeatOperationViewController(seatInfo: info, seatIndex: index, delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case let .inputText(name, delegate):
            let vc = VoiceRoomTextInputViewController(name: name, delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case let .inputPassword(type, delegate):
            let vc = VoiceRoomPasswordViewController(type: type, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case let .requestSeatPop(delegate):
            let vc = ManageRequestSeatViewController(delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case let .changeBackground(imagelist, delegate):
            let vc = ChangeBackgroundViewController(imagelist: imagelist, delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case let .inputMessage(id, delegate):
            let vc = VoiceRoomInputMessageViewController(id, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case let .userlist(dependency, delegate):
            let vc = VoiceRoomUserListViewController(dependency: dependency, delegate: delegate)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
            nav.modalTransitionStyle = .coverVertical
            nav.modalPresentationStyle = .overFullScreen
            return nav
        case .messagelist:
            let vc = ChatroomConversationListViewController(displayConversationTypes: [RCConversationType.ConversationType_PRIVATE.rawValue], collectionConversationType: [])
            return vc!
        case let .privateChat(userId):
            return ChatroomConversationViewController(conversationType: .ConversationType_PRIVATE, targetId: userId)!
        case let .gift(dependency, delegate):
            let vc = VoiceRoomGiftViewController(dependency: dependency, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case let .giftCount(sendView):
            let vc = VoiceRoomGiftCountViewController(sendView)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case let .voiceRoomAlert(title, actions, alertType, delegate):
            let vc = VoiceRoomAlertViewController(title: title, actions: actions, alertType: alertType, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case let .leaveAlert(isOwner, delegate):
            let vc = VoiceRoomLeaveAlertViewController(isOwner: isOwner, delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case let .dial(type):
            return DialViewController(type: type)
        case .promotion:
            let vc = PromotionViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case .promotionDetail:
            let vc = PromotionDetailViewController()
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case .feedback:
            let vc = FeelingFeedbackViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case let .notice(modify, notice ,delegate):
            let vc = VoiceRoomNoticeViewController(modify: modify, notice: notice, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return vc
        case let .forbiddenList(roomId):
            let vc = VoiceRoomForbiddenViewController(roomId: roomId)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return vc
        case let .onlineRooms(userId, delegate):
            let vc = OnlineRoomCreatorViewController(selectingUserId: userId, delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
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
