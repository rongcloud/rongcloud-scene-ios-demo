//
//  SceneRoomManager+Video.swift
//  RCSceneVideoRoom
//
//  Created by xuefeng on 2022/2/25.
//

import SVProgressHUD
import RCSceneFoundation
import RCSceneService
import RCSceneModular

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

extension SceneRoomManager {
    /// 合流状态
    var currentPlayingStatus: RCRTCAudioMixingState {
        RCRTCAudioMixingState.mixingStateStop
    }
    
    /// 是否在麦位上：支持语聊房
    func isSitting(_ userId: String = Environment.currentUserId) -> Bool {
        return seatlist.contains { $0 == userId }
    }
    
    /// 是否在麦位上：支持语聊房、直播
    func setPKStatus(roomId: String, toRoomId: String, status: PKStatus, completion: ((Bool) -> Void)? = nil) {
        voiceRoomService.setPKStatus(roomId: roomId, toRoomId: toRoomId, status: status.rawValue) { result in
            switch result {
            case .success(_): completion?(true)
            case .failure(_): completion?(false)
            }
        }
    }
    
    func getCurrentPKInfo(roomId: String, completion: @escaping ((PKStatusModel?) -> Void)) {
        voiceRoomService.pkDetail(roomId: roomId) { result in
            switch result {
            case let .success(response):
                let pkInfo = try? JSONDecoder().decode(PKStatusModel.self, from: response.data, keyPath: "data")
                completion(pkInfo)
            case let .failure(error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func clear() {
        seatlist.removeAll()
        managers.removeAll()
    }
}

/// 简介：加入和离开房间
/// 实现：采用单线程结合DispatchSemaphore，确保加入离开房间线程安全
/// 注意：DispatchSemaphore添加超时
extension SceneRoomManager {
    /// 如果有kv信息，默认为创建
    func voice_join(_ roomId: String,
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
            voiceRoomService.userUpdateCurrentRoom(roomId: roomId) { _ in}
            DispatchQueue.main.async {
                switch wait {
                case .success: complation(result)
                case .timedOut: complation(.failure(ReactorError("加入房间超时")))
                }
            }
        }
    }
    
    func voice_leave(_ complation: @escaping (Result<Void, ReactorError>) -> Void) {
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
            voiceRoomService.userUpdateCurrentRoom(roomId: "") { _ in}
            DispatchQueue.main.async {
                switch wait {
                case .success: complation(result)
                case .timedOut: complation(.failure(ReactorError("离开房间超时")))
                }
            }
        }
    }
}
