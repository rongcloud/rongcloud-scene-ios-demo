//
//  RCRoomService.swift
//  RCE
//
//  Created by xuefeng on 2022/2/7.
//

import Foundation
import Moya


public let roomProvider = MoyaProvider<RCRoomService>(plugins: [RCServicePlugin])

public enum RCRoomService {
    case createRoom(name: String, themePictureUrl: String, backgroundUrl: String, kv: [[String: String]], isPrivate: Int, password: String?, roomType: Int)
    case roomList(type: Int = 1, page: Int, size: Int)
    case setRoomName(roomId: String ,name: String)
    case setRoomType(roomId: String, isPrivate: Bool, password: String?)
    case roomUsers(roomId: String)
    case roomManagers(roomId: String)
    case setRoomManager(roomId: String, userId: String, isManager: Bool)
    case closeRoom(roomId: String)
    case updateRoomBackgroundUrl(roomId: String, backgroundUrl: String)
    case roomState(roomId: String)
    case roomInfo(roomId: String)
    case userUpdateCurrentRoom(roomId: String)
    case suspendRoom(roomId: String)
    case resumeRoom(roomId: String)
    case roomBroadcast(userId: String, objectName: String, content: String)
    case checkCurrentRoom
    case checkCreatedRoom
}

extension RCRoomService: RCServiceType {
    public var path: String {
        switch self {
        case .createRoom:
            return "mic/room/create"
        case .roomList:
            return "mic/room/list"
        case .setRoomName:
            return "mic/room/name"
        case .setRoomType:
            return "mic/room/private"
        case let .roomUsers(roomId):
            return "mic/room/\(roomId)/members"
        case let .roomManagers(roomId):
            return "mic/room/\(roomId)/manage/list"
        case .setRoomManager:
            return "mic/room/manage"
        case let .closeRoom(roomId):
            return "mic/room/\(roomId)/delete"
        case .updateRoomBackgroundUrl:
            return "mic/room/background"
        case let .roomState(roomId):
            return "mic/room/\(roomId)/setting"
        case let .roomInfo(roomId):
            return "mic/room/\(roomId)"
        case .userUpdateCurrentRoom:
            return "user/change"
        case let .suspendRoom(roomId):
            return "mic/room/\(roomId)/stop"
        case let .resumeRoom(roomId):
            return "mic/room/\(roomId)/start"
        case .roomBroadcast:
            return "mic/room/message/broadcast"
        case .checkCurrentRoom:
            return "user/check"
        case .checkCreatedRoom:
            return "/mic/room/create/check"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .createRoom:
            return .post
        case .roomList:
            return .get
        case .setRoomName:
            return .put
        case .setRoomType:
            return .put
        case .roomUsers:
            return .get
        case .roomManagers:
            return .get
        case .setRoomManager:
            return .put
        case .closeRoom:
            return .get
        case .updateRoomBackgroundUrl:
            return .put
        case .roomState:
            return .get
        case .roomInfo:
            return .get
        case .userUpdateCurrentRoom:
            return .get
        case .suspendRoom:
            return .get
        case .resumeRoom:
            return .get
        case .roomBroadcast:
            return .post
        case .checkCurrentRoom:
            return .get
        case .checkCreatedRoom:
            return .put
        }
    }
    
    public var task: Task {
        switch self {
        case let .createRoom(name, themePictureUrl, backgroundUrl, kv, isPrivate, password, roomType):
            var params: [String: Any] = ["name": name, "themePictureUrl": themePictureUrl, "kv": kv, "isPrivate": isPrivate, "backgroundUrl": backgroundUrl, "roomType": roomType]
            if let password = password {
                params["password"] = password
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .roomList(type, page, size):
            return .requestParameters(parameters: ["type": type, "size": size, "page": page, "q": Date().timeIntervalSince1970], encoding: URLEncoding.default)
        case let .setRoomName(roomId, name):
            return .requestParameters(parameters: ["roomId": roomId, "name": name], encoding: JSONEncoding.default)
        case let .setRoomType(roomId, isPrivate, password):
            let value = isPrivate ? 1 : 0
            var params: [String: Any] = ["roomId": roomId, "isPrivate": value]
            if let password = password {
                params["password"] = password
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .roomManagers:
            return .requestPlain
        case .roomUsers:
            return .requestPlain
        case let .setRoomManager(roomId, userId, isManager):
            return .requestParameters(parameters: ["roomId": roomId, "userId": userId, "isManage": isManager], encoding: JSONEncoding.default)
        case .closeRoom:
            return .requestPlain
        case let .updateRoomBackgroundUrl(roomId, backgroundUrl):
            return .requestParameters(parameters: ["roomId": roomId, "backgroundUrl": backgroundUrl], encoding: JSONEncoding.default)
        case .roomState:
            return .requestPlain
        case .roomInfo:
            return .requestPlain
        case let .userUpdateCurrentRoom(roomId):
            return .requestParameters(parameters: ["roomId": roomId],
                                      encoding: URLEncoding.default)
        case .suspendRoom, .resumeRoom:
            return .requestPlain
        case let .roomBroadcast(userId, objectName, content):
            return .requestParameters(parameters: ["fromUserId": userId, "objectName": objectName, "content": content],
                                      encoding: JSONEncoding.default)
        case .checkCurrentRoom:
            return.requestPlain
        case .checkCreatedRoom:
            return .requestPlain
        }
    }
}
