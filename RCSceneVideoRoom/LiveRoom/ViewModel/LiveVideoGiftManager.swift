//
//  LiveVideoGiftManager.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/6.
//

import UIKit
import RCSceneService

let NotificationNameGiftUpdate = Notification.Name("NotificationNameGiftUpdate")

class LiveVideoGiftManager: NSObject {
    static let shared = LiveVideoGiftManager()
    
    private var currentRoomId: String = ""
    
    var giftInfo: [String: Int] = [:]
    
    func refresh(_ roomId: String) {
        giftInfo = [:]
        videoRoomService.giftList(roomId: roomId) { [weak self] result in
            switch result {
            case let .success(value):
                print(value)
                guard
                    let info = try? JSONSerialization.jsonObject(with: value.data, options: .allowFragments),
                    let items = (info as? [String: Any])?["data"] as? [[String: Int]]
                else { return }
                debugPrint(items)
                self?.didFetchGiftInfo(items)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func didFetchGiftInfo(_ items: [[String: Int]]) {
        items.forEach { item in
            item.forEach { (key: String, value: Int) in
                giftInfo[key] = value
            }
        }
        NotificationNameGiftUpdate.post(giftInfo)
    }
    
    func updateGift(_ items: [String: Int]) {
        items.forEach { (key: String, value: Int) in
            if let count = giftInfo[key] {
                giftInfo[key] = count + value
            } else {
                giftInfo[key] = value
            }
        }
        NotificationNameGiftUpdate.post(giftInfo)
    }
}
