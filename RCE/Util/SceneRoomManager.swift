//
//  VoiceRoomManager.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/3.
//

import SVProgressHUD

enum PKStatus: Int {
    case begin = 0
    case pause
    case close
    
    var name: String {
        switch self {
        case .begin:
            return "开始"
        case .pause:
            return "暂停"
        case .close:
            return "结束"
        }
    }
}

class SceneRoomManager {
    static let shared = SceneRoomManager()
    
    private let queue = DispatchQueue(label: "voice_room_join_or_leave")
    
    /// 当前场景类型，进入room时，用room.roomType
    static var scene = HomeItem.audioRoom
    
    /// 座位信息：支持语聊房
    var seatlist = [RCVoiceSeatInfo]()
    /// 管理员
    var managerlist = [String]()
    /// 房间背景
    var backgroundlist = [String]()
    /// 屏蔽词
    var forbiddenWordlist = [String]()
    /// 合流状态
    var currentPlayingStatus = RCRTCAudioMixingState.mixingStateStop
    
    /// 是否在麦位上：支持语聊房
    func isSitting(_ userId: String = Environment.currentUserId) -> Bool {
        return seatlist.contains { $0.userId == userId }
    }
    
    /// 是否在麦位上：支持语聊房、直播
    func setPKStatus(roomId: String, toRoomId: String, status: PKStatus, completion: ((Bool) -> Void)? = nil) {
        let api = RCNetworkAPI.setPKState(roomId: roomId, toRoomId: toRoomId, status: status.rawValue)
        networkProvider.request(api) { result in
            switch result {
            case .success(_): completion?(true)
            case .failure(_): completion?(false)
            }
        }
    }
    
    func clear() {
        seatlist.removeAll()
        managerlist.removeAll()
    }
}

/// 简介：加入和离开房间
/// 实现：采用单线程结合DispatchSemaphore，确保加入离开房间线程安全
/// 注意：DispatchSemaphore添加超时
extension SceneRoomManager {
    /// 如果有kv信息，默认为创建
    func join(_ roomId: String,
              roomKVInfo: RCVoiceRoomInfo? = nil,
              complation: @escaping (Result<Void, ReactorError>) -> Void) {
        queue.async {
            var result = Result<Void, ReactorError>.success(())
            let semaphore = DispatchSemaphore(value: 0)
            
            if let roomKVInfo = roomKVInfo {
                RCVoiceRoomEngine.sharedInstance()
                    .createAndJoinRoom(roomId, room: roomKVInfo) {
                        result = .success(())
                        semaphore.signal()
                    } error: { errorCode, msg in
                        result = .failure(ReactorError("创建失败\(msg)"))
                        semaphore.signal()
                    }
            } else {
                RCVoiceRoomEngine.sharedInstance()
                    .joinRoom(roomId, success: {
                        result = .success(())
                        semaphore.signal()
                    }, error: { eCode, msg in
                        result = .failure(ReactorError(msg))
                        semaphore.signal()
                    })
            }
            let wait = semaphore.wait(timeout: .now() + 8)
            
            /// 更新用户所属房间
            networkProvider.request(.userUpdateCurrentRoom(roomId: roomId)) { _ in }
            
            DispatchQueue.main.async {
                switch wait {
                case .success: complation(result)
                case .timedOut: complation(.failure(ReactorError("加入房间超时")))
                }
            }
        }
    }
    
    func leave(_ complation: @escaping (Result<Void, ReactorError>) -> Void) {
        queue.async {
            var result = Result<Void, ReactorError>.success(())
            let semaphore = DispatchSemaphore(value: 0)
            RCVoiceRoomEngine.sharedInstance().leaveRoom({
                print("leave room")
                self.clear()
                result = .success(())
                semaphore.signal()
            }, error: { eCode, msg in
                result = .failure(ReactorError(msg))
                semaphore.signal()
            })
            let wait = semaphore.wait(timeout: .now() + 8)
            
            /// 更新用户所属房间
            networkProvider.request(.userUpdateCurrentRoom(roomId: "")) { _ in }
            
            DispatchQueue.main.async {
                switch wait {
                case .success: complation(result)
                case .timedOut: complation(.failure(ReactorError("离开房间超时")))
                }
            }
        }
    }
}
