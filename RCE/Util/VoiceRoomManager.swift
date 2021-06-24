//
//  VoiceRoomManager.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/3.
//

import Foundation

class VoiceRoomManager {
    static let shared = VoiceRoomManager()
    
    private let queue = DispatchQueue(label: "voice_room_join_or_leave")
    
    func join(_ roomId: String, complation: @escaping (Result<Void, ReactorError>) -> Void) {
        queue.async {
            var result = Result<Void, ReactorError>.success(())
            let semaphore = DispatchSemaphore(value: 0)
            RCVoiceRoomEngine.sharedInstance().joinRoom(roomId, success: {
                print("enter room")
                semaphore.signal()
            }, error: { eCode, msg in
                result = .failure(ReactorError(msg))
                semaphore.signal()
            })
            semaphore.wait()
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
                semaphore.signal()
            }, error: { eCode, msg in
                result = .failure(ReactorError(msg))
                semaphore.signal()
            })
            semaphore.wait()
            DispatchQueue.main.async {
                complation(result)
            }
        }
    }
}
