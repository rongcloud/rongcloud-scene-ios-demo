//
//  VoiceRoomManager.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/3.
//

import Foundation
import RxSwift
import UIKit
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

class VoiceRoomManager {
    static let shared = VoiceRoomManager()
    
    private let queue = DispatchQueue(label: "voice_room_join_or_leave")
    var seatlist = [RCVoiceSeatInfo]()
    var managerlist = [String]()
    var backgroundlist = [String]()
    var forbiddenWordlist = [String]()
    var currentPlayingStatus = RCRTCAudioMixingState.mixingStateStop
    
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
            let _ = semaphore.wait(timeout: .now() + .seconds(8))
            
            /// 更新用户所属房间
            networkProvider.request(.userUpdateCurrentRoom(roomId: roomId)) { _ in }
            
            DispatchQueue.main.async {
                complation(result)
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
            let _ = semaphore.wait(timeout: .now() + .seconds(8))
            
            /// 更新用户所属房间
            networkProvider.request(.userUpdateCurrentRoom(roomId: "")) { _ in }
            
            DispatchQueue.main.async {
                complation(result)
            }
        }
    }
    
    func leaveRoom() -> Observable<Bool> {
        return Observable<Bool>.create { observer -> Disposable in
            self.leave { result in
                switch result {
                case .success(_):
                    observer.onNext(true)
                    observer.onCompleted()
                case .failure(_):
                    observer.onNext(false)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func clear() {
        seatlist.removeAll()
        managerlist.removeAll()
    }
    
    func isSitting(_ userId: String = Environment.currentUserId) -> Bool {
        return seatlist.contains { $0.userId == userId }
    }
    
    func setPKStatus(roomId: String, toRoomId: String, status: PKStatus, completion: ((Bool) -> Void)? = nil) {
        networkProvider.request(RCNetworkAPI.setPKState(roomId: roomId, toRoomId: toRoomId, status: status.rawValue)) { result in
            switch result {
            case .success(_):
              //  SVProgressHUD.showSuccess(withStatus: "PK \(status.name) 成功")
                completion?(true)
            case .failure(_):
              //  SVProgressHUD.showSuccess(withStatus: "PK \(status.name) 失败")
                completion?(false)
            }
        }
    }
}
