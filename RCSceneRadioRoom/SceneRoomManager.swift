//
//  VoiceRoomManager.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/3.
//

import SVProgressHUD
import RCSceneService
import RCSceneFoundation

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
    /// 是否在麦位上：支持语聊房、直播
    func setPKStatus(roomId: String, toRoomId: String, status: PKStatus, completion: ((Bool) -> Void)? = nil) {
        radioRoomService.setPKStatus(roomId: roomId, toRoomId: toRoomId, status: status.rawValue) { result in
            switch result {
            case .success(_): completion?(true)
            case .failure(_): completion?(false)
            }
        }
    }
    
    func getCurrentPKInfo(roomId: String, completion: @escaping ((PKStatusModel?) -> Void)) {
        radioRoomService.pkDetail(roomId: roomId) { result in
            switch result {
            case let .success(response):
                let pkInfo = try? JSONDecoder().decode(PKStatusModel.self, from: response.data, keyPath: "data")
                completion(pkInfo)
            case let .failure(error):
                debugPrint(error.localizedDescription)
            }
        }
    }
}
