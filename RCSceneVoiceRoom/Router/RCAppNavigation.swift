//
//  RCRouter.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import UIKit
import RCSceneGift
import RCSceneService
import RCSceneModular
import RCSceneFoundation

enum RCNavigation: Navigation {
    case voiceRoom(roomInfo: VoiceRoom, needCreate: Bool)
    case requestOrInvite(roomId: String, delegate: HandleRequestSeatProtocol, showPage: Int, onSeatUserIds:[String])
    case masterSeatOperation(String, Bool, VoiceRoomMasterSeatOperationProtocol)
    case userSeatPop(seatIndex: UInt, isUserMute: Bool, isSeatMute: Bool, delegate: VoiceRoomSeatedOperationProtocol)
    case manageUser(dependency: UserOperationDependency, delegate: UserOperationProtocol?)
    case ownerClickEmptySeat(RCVoiceSeatInfo, UInt, VoiceRoomEmptySeatOperationProtocol)
    case inputText(name: String, delegate: VoiceRoomInputTextProtocol)
    case inputPassword(type: PasswordViewType, delegate: InputPasswordProtocol?)
    case requestSeatPop(delegate: RequestSeatPopProtocol)
    case changeBackground(imagelist: [String], delegate: ChangeBackgroundImageProtocol)
    case userlist(room: VoiceRoom, delegate: UserOperationProtocol)
    case gift(dependency: VoiceRoomGiftDependency, delegate: VoiceRoomGiftViewControllerDelegate)
    case giftCount(sendView: VoiceRoomGiftSendView)
    case voiceRoomAlert(title: String, actions: [VoiceRoomAlertAction], alertType: String, delegate: VoiceRoomAlertProtocol?)
    case leaveAlert(isOwner: Bool, delegate: RCSceneLeaveViewProtocol)
    case notice(modify: Bool = false, notice: String, delegate: VoiceRoomNoticeDelegate)
    case forbiddenList(roomId: String)
    case onlineRooms(selectingUserId: String?, delegate: OnlineRoomCreatorDelegate)
}

struct RCAppNavigation: AppNavigation {
    func navigate(_ navigation: Navigation, from: UIViewController, to: UIViewController) {
        if let router = navigation as? RCNavigation {
            switch router {
            case
                    .requestOrInvite,
                    .masterSeatOperation,
                    .userSeatPop,
                    .manageUser,
                    .ownerClickEmptySeat,
                    .inputText,
                    .inputPassword,
                    .requestSeatPop,
                    .changeBackground,
                    .userlist,
                    .gift,
                    .giftCount,
                    .voiceRoomAlert,
                    .leaveAlert,
                    .notice,
                    .forbiddenList,
                    .onlineRooms:
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
        case let .voiceRoom(roomInfo, needCreate):
            return VoiceRoomViewController(roomInfo: roomInfo, isCreate: needCreate)
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
            let vc = UserOperationViewController(dependency: dependency, delegate: delegate)
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
        case let .userlist(room, delegate):
            let vc = SceneRoomUserListViewController(room: room, delegate: delegate)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
            nav.modalTransitionStyle = .coverVertical
            nav.modalPresentationStyle = .overFullScreen
            return nav
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
