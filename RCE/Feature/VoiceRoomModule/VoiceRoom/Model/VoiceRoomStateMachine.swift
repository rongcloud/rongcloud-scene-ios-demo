//import Foundation
//import RxSwift
//
//enum RoomSeatMode {
//    case free
//    case apply
//}
//
//enum VoiceRoomEvent {
//    case lockRoom(isLock: Bool)
//    case setRoomTitle(title: String)
//    case setBackground(url: String)
//    case roomSeatMode(mode: RoomSeatMode)
//    case muteAll(isMute: Bool)
//    case lockAll(isLock: Bool)
//    case silence(isSilence: Bool)
//    case setSeatCount(count: Int)
//
//    case leaveRoom
//    case closeRoom
//    case clickSettingRoom
//    case setManager(userId: String, isSetManager: Bool)
//    case setUserOnSeat(userId: String, isOn: Bool)
//    case lockSeat(seatIndex: UInt, isLock: Bool)
//    case muteSeat(seatIndex: UInt, isMute: Bool)
//    case kickoutRoom
//
//}
//
//class VoiceRoomStateMachine {
//    private var disposeBag = DisposeBag()
//    weak var viewControllerRef: VoiceRoomViewController?
//    var kvRoom: RCVoiceRoomInfo?
//    var roomInfo: VoiceRoom
//    var seatMode: RoomSeatMode = .apply
//    var isLockRoom: Bool = false
//    var isMuteAll: Bool = false
//    var isLockAll: Bool = false
//    var isSilence: Bool = false
//    var seatCount: Int = 9
//    var isManager: Bool = false
//    var isSelfOnSeat: Bool = false
//    var connectState = ConnectMicState.request
//
//    init(roomInfo: VoiceRoom, viewControllerRef: VoiceRoomViewController) {
//        self.roomInfo = roomInfo
//        self.viewControllerRef = viewControllerRef
//    }
//
//    func updateKv(_ kvRoom: RCVoiceRoomInfo) {
//        self.kvRoom = kvRoom
//    }
//
//    func handleEvent(_ event: VoiceRoomEvent) {
//        switch event {
//        case .lockRoom(isLock: let isLock):
//            if isLock {
//                viewControllerRef?.navigator(.inputPassword(type: .input, delegate: self))
//            } else {
//                lockRoom(isLock: isLock)
//            }
//        case .clickSettingRoom:
//            viewControllerRef?.navigator(.roomSetting(settinglist(), self))
//        case .setRoomTitle(title: let title):
//            guard let kvRoom = self.kvRoom else {
//                return
//            }
//            kvRoom.roomName = title
//            RCVoiceRoomEngine.sharedInstance().setRoomInfo(kvRoom) {
//
//            } error: { code, msg in
//
//            }
//        case .setBackground(url: let url):
//            ()
//        case .roomSeatMode(mode: let mode):
//            ()
//        case .muteAll(isMute: let isMute):
//            ()
//        case .lockAll(isLock: let isLock):
//            ()
//        case .silence(isSilence: let isSilence):
//            RCVoiceRoomEngine.sharedInstance().muteAllRemoteStreams(isSilence)
//            self.isSilence = isSilence
//        case .setSeatCount(count: let count):
//            guard let kvRoom = self.kvRoom else {
//                return
//            }
//
//        case .leaveRoom:
//            ()
//        case .closeRoom:
//            ()
//        case .setManager(userId: let userId, isSetManager: let isSetManager):
//            ()
//        case let .setUserOnSeat(userId, isOn):
//            ()
//        case let .lockSeat(seatIndex, isLock):
//            RCVoiceRoomEngine.sharedInstance().lockSeat(seatIndex, lock: isLock) {
//
//            } error: { code, msg in
//
//            }
//        case let .muteSeat(seatIndex, isMute):
//            RCVoiceRoomEngine.sharedInstance().muteSeat(seatIndex, mute: isMute) {
//
//            } error: { code, msg in
//
//            }
//        case .kickoutRoom:
//            ()
//        }
//    }
//
//    func lockRoom(isLock: Bool, password: String? = nil) {
//
//    }
//
//    func setManage(userId: String, isManager: Bool) {
//        networkProvider.rx.request(.setRoomManager(roomId: roomInfo.roomId, userId: userId, isManager: isManager)).asObservable().filterSuccessfulStatusCodes()
//    }
//
//    func settinglist() -> [RoomSettingItem] {
//        return [.lockRoom(isLockRoom),
//                .muteAllSeat(isMuteAll),
//                .lockAllSeat(isLockAll),
//                .muteSelf(isSilence),
//                .music,
//                .isFreeEnterSeat(seatMode == .free),
//                .roomTitle,
//                .roomBackground,
//                .lessSeatMode(seatCount == 5)]
//    }
//}
//
//extension VoiceRoomStateMachine: VoiceRoomInputPasswordProtocol {
//    func passwordDidEnter(password: String) {
//        lockRoom(isLock: true, password: password)
//    }
//}
//
//extension VoiceRoomStateMachine: VoiceRoomSettingProtocol {
//    func lockRoomDidClick(isLock: Bool) {
//        handleEvent(.lockRoom(isLock: isLock))
//    }
//
//    func freeMicDidClick(isFree: Bool) {
//        handleEvent(.roomSeatMode(mode: (isFree ? .free : .apply)))
//    }
//
//    func lockAllSeatDidClick(isLock: Bool) {
//        handleEvent(.lockAll(isLock: isLock))
//    }
//
//    func silenceSelfDidClick(isSilence: Bool) {
//        handleEvent(.silence(isSilence: isSilence))
//    }
//
//    func muteAllSeatDidClick(isMute: Bool) {
//        handleEvent(.muteAll(isMute: isMute))
//    }
//
//    func lessSeatDidClick(isLess: Bool) {
//        handleEvent(.setSeatCount(count: (isLess ? 5 : 9)))
//    }
//
//    func modifyRoomTitleDidClick() {
//
//    }
//
//    func modifyRoomBackgroundDidClick() {
//
//    }
//
//    func musicDidClick() {
//
//    }
//}
