//
//  RCNetworkAPI.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import Foundation
import Moya

/// 如果不希望在Console中打印网络请求相关的log可以在把plugins设置为空数组。
let networkProvider = MoyaProvider<RCNetworkAPI>(plugins: [networkLogPlugin])

let networkLogPlugin: NetworkLoggerPlugin = {
    let plgn = NetworkLoggerPlugin()
    plgn.configuration.logOptions = .verbose
    return plgn
}()

enum Paging {
    case refresh
    case loadMore
}

enum RCNetworkAPI {
    case sendCode(mobile: String)
    case login(mobile: String, code: String, userName: String?, portrait: String?, deviceId: String)
    case createRoom(name: String, themePictureUrl: String, backgroundUrl: String, kv: [[String: String]], isPrivate: Int, password: String?)
    case roomlist(page: Int, size: Int)
    case usersInfo(id: [String])
    case upload(data: Data)
    case uploadAudio(data: Data)
    case setRoomName(roomId: String ,name: String)
    case setRoomType(roomId: String, isPrivate: Bool, password: String?)
    case roomUsers(roomId: String)
    case roomManagers(roomId: String)
    case setRoomManager(roomId: String, userId: String, isManager: Bool)
    case updateUserInfo(userName: String, portrait: String)
    case closeRoom(roomId: String)
    case updateRoombackgroundUrl(roomId: String, backgroundUrl: String)
    case giftList(roomId: String)
    case sendGift(roomId: String, giftId: String, toUid: String, num: Int)
    case musiclist(roomId: String, type: Int)
    case addMusic(roomId: String, musicName: String, author: String, type: Int, url: String, size: Int)
    case deleteMusic(roomId: String, musicId: Int)
    case moveMusic(roomId: String, fromId: Int, toId: Int)
    case roomState(roomId: String)
    case refreshToken(auth: String)
}

extension RCNetworkAPI: TargetType {
    var baseURL: URL {
        return Environment.current.url
    }
    
    var path: String {
        switch self {
        case .sendCode:
            return "user/sendCode"
        case .login:
            return "user/login"
        case .createRoom:
            return "mic/room/create"
        case .roomlist:
            return "mic/room/list"
        case .usersInfo:
            return "user/batch"
        case .upload, .uploadAudio:
            return "file/upload"
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
        case .updateUserInfo:
            return "/user/update"
        case let .closeRoom(roomId):
            return "mic/room/\(roomId)/delete"
        case .updateRoombackgroundUrl:
            return "mic/room/background"
        case let .giftList(roomId):
            return "mic/room/\(roomId)/gift/list"
        case .sendGift:
            return "mic/room/gift/add"
        case .musiclist:
            return "mic/room/music/list"
        case .addMusic:
            return "mic/room/music/add"
        case .deleteMusic:
            return "mic/room/music/delete"
        case .moveMusic:
            return "mic/room/music/move"
        case let .roomState(roomId):
            return "mic/room/\(roomId)/setting"
        case .refreshToken:
            return "user/refreshToken"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .sendCode:
            return .post
        case .login:
            return .post
        case .createRoom:
            return .post
        case .roomlist:
            return .get
        case .usersInfo:
            return .post
        case .upload, .uploadAudio:
            return .post
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
        case .updateUserInfo:
            return .post
        case .closeRoom:
            return .get
        case .updateRoombackgroundUrl:
            return .put
        case .giftList:
            return .get
        case .sendGift:
            return .post
        case .musiclist:
            return .post
        case .addMusic:
            return .post
        case .deleteMusic:
            return .post
        case .moveMusic:
            return .post
        case .roomState:
            return .get
        case .refreshToken:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case let .sendCode(number):
            return .requestParameters(parameters: ["mobile": number], encoding: JSONEncoding.default)
        case let .login(mobile, code, userName, portrait, deviceId):
            return .requestParameters(parameters: ["mobile": mobile,
                                                   "verifyCode":code,
                                                   "userName": userName,
                                                   "portrait": portrait,
                                                   "deviceId": deviceId].compactMapValues { $0 }, encoding: JSONEncoding.default)
        case let .createRoom(name, themePictureUrl, backgroundUrl, kv, isPrivate, password):
            var params: [String: Any] = ["name": name, "themePictureUrl": themePictureUrl, "kv": kv, "isPrivate": isPrivate, "backgroundUrl": backgroundUrl]
            if let password = password {
                params["password"] = password
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .roomlist(page, size):
            return .requestParameters(parameters: ["size": size, "page": page], encoding: URLEncoding.default)
        case let .usersInfo(list):
            return .requestParameters(parameters: ["userIds": list], encoding: JSONEncoding.default)
        case let .upload(data):
            let imageData = MultipartFormData(provider: .data(data), name: "file", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
            return .uploadMultipart([imageData])
        case let .uploadAudio(data):
            let imageData = MultipartFormData(provider: .data(data), name: "file", fileName: "\(Int(Date().timeIntervalSince1970)).mp3", mimeType: "audio/mpeg3")
            return .uploadMultipart([imageData])
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
        case let .updateUserInfo(userName, portrait):
            return .requestParameters(parameters: ["userName": userName, "portrait": portrait], encoding: JSONEncoding.default)
        case .closeRoom:
            return .requestPlain
        case let .updateRoombackgroundUrl(roomId, backgroundUrl):
            return .requestParameters(parameters: ["roomId": roomId, "backgroundUrl": backgroundUrl], encoding: JSONEncoding.default)
        case .giftList:
            return .requestPlain
        case let .sendGift(roomId, giftId, toUid, num):
            return .requestParameters(parameters: ["roomId": roomId, "giftId": giftId, "toUid": toUid, "num": num],
                                      encoding: JSONEncoding.default)
        case let .musiclist(roomId, type):
            return .requestParameters(parameters: ["roomId": roomId, "type": type],
                                      encoding: JSONEncoding.default)
        case let .addMusic(roomId, musicName, author, type, url, size):
            return .requestParameters(parameters: ["roomId": roomId, "type": type, "name": musicName, "author": author, "url": url, "size": size],
                                      encoding: JSONEncoding.default)
        case let .deleteMusic(roomId, musicId):
            return .requestParameters(parameters: ["roomId": roomId, "id": musicId],
                                      encoding: JSONEncoding.default)
        case let .moveMusic(roomId, fromId, toId):
            return .requestParameters(parameters: ["roomId": roomId, "fromId": fromId, "toId": toId],
                                      encoding: JSONEncoding.default)
        case .roomState:
            return .requestPlain
        case .refreshToken:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        if let auth = UserDefaults.standard.authorizationKey() {
            return ["Authorization": auth]
        }
        if case let .refreshToken(auth) = self {
            return ["Authorization": auth]
        }
        return nil
    }
}
