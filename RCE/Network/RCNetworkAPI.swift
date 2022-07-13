//
//  RCNetworkAPI.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import Foundation
import Moya

/// 如果不希望在Console中打印网络请求相关的log可以在把plugins参数移除。
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
    case sendCode(mobile: String, region: String)
    case login(mobile: String, code: String, userName: String?, portrait: String?, deviceId: String, region: String, platform: String)
    case loginDevice
    case createRoom(name: String, themePictureUrl: String, backgroundUrl: String, kv: [[String: String]], isPrivate: Int, password: String?, roomType: Int)
    case roomlist(type: Int = 1, page: Int, size: Int)
    case gameroomlist(type: Int = 1, page: Int, size: Int, sex: String, gameId: String)
    case usersInfo(id: [String])
    case upload(data: Data)
    case uploadAudio(data: Data, extension: String? = nil)
    case setRoomName(roomId: String ,name: String)
    case setRoomType(roomId: String, isPrivate: Bool, password: String?)
    case roomUsers(roomId: String)
    case roomManagers(roomId: String)
    case setRoomManager(roomId: String, userId: String, isManager: Bool)
    case updateUserInfo(userName: String, portrait: String)
    case closeRoom(roomId: String)
    case updateRoomBackground(roomId: String, backgroundUrl: String)
    case giftList(roomId: String)
    case sendGift(roomId: String, giftId: String, toUid: String, num: Int)
    case musiclist(roomId: String, type: Int)
    case addMusic(roomId: String, musicName: String, author: String, type: Int, url: String, backgroundUrl: String, thirdMusicId: String, size: Int)
    case deleteMusic(roomId: String, musicId: Int)
    case syncRoomPlayingMusicInfo(roomId: String, musicId: Int)
    case fetchRoomPlayingMusicInfo(roomId: String)
    case moveMusic(roomId: String, fromId: Int, toId: Int)
    case roomState(roomId: String)
    case refreshToken(auth: String)
    case getUserInfo(phone: String)
    case feedback(isGoodFeedback: Bool, reason: String?)
    case forbiddenList(roomId: String)
    case appendForbidden(roomId: String, name: String)
    case deleteForbidden(id: String)
    case follow(userId: String)
    case followList(page: Int, type: Int)
    case onlineCreator(type: Int)
    case setPKState(roomId: String, toRoomId: String, status: Int)
    case userUpdateCurrentRoom(roomId: String)
    case suspendRoom(roomId: String)
    case resumeRoom(roomId: String)
    case roomInfo(roomId: String)
    case roomBroadcast(userId: String, objectName: String, content: String)
    case pkDetail(roomId: String)
    case checkCurrentRoom
    case isPK(roomId: String)
    case checkCreatedRoom(type: Int)
    case findRoomByUser(userId: String, roomType: Int)
    case resign
    case checkVersion(platform: String)
    case checkText(text: String)
}

extension RCNetworkAPI: TargetType {
    var baseURL: URL {
        return Environment.url
    }
    
    var path: String {
        switch self {
        case .sendCode:
            return "user/sendCode"
        case .login:
            return "user/login"
        case .loginDevice:
            return "user/login/device/mobile"
        case .createRoom:
            return "mic/room/create"
        case .roomlist:
            return "mic/room/list"
        case .gameroomlist:
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
            return "user/update"
        case let .closeRoom(roomId):
            return "mic/room/\(roomId)/delete"
        case .updateRoomBackground:
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
        case .syncRoomPlayingMusicInfo:
            return "mic/room/music/play"
        case let .fetchRoomPlayingMusicInfo(roomId):
            return "mic/room/music/play/\(roomId)"
        case .moveMusic:
            return "mic/room/music/move"
        case let .roomState(roomId):
            return "mic/room/\(roomId)/setting"
        case .refreshToken:
            return "user/refreshToken"
        case let .getUserInfo(phone):
            return "user/get/\(phone)"
        case .feedback:
            return "feedback/create"
        case let .forbiddenList(roomId):
            return "mic/room/sensitive/\(roomId)/list"
        case .appendForbidden:
            return "mic/room/sensitive/add"
        case let .deleteForbidden(id):
            return "mic/room/sensitive/del/\(id)"
        case let .follow(userId):
            return "user/follow/\(userId)"
        case .followList:
            return "user/follow/list"
        case .onlineCreator:
          return "mic/room/online/created/list/v1"
        case .userUpdateCurrentRoom:
            return "user/change"
        case .setPKState:
            return "mic/room/pk"
        case let .suspendRoom(roomId):
            return "mic/room/\(roomId)/stop"
        case let .resumeRoom(roomId):
            return "mic/room/\(roomId)/start"
        case let .roomInfo(roomId):
            return "mic/room/\(roomId)"
        case .roomBroadcast:
            return "mic/room/message/broadcast"
        case let .pkDetail(roomId):
            return "/mic/room/pk/detail/\(roomId)"
        case .checkCurrentRoom:
            return "user/check"
        case let .isPK(roomId):
            return "/mic/room/pk/\(roomId)/isPk"
        case .checkCreatedRoom:
            return "/mic/room/create/check/v1"
        case .resign:
            return "/user/resign"
        case .checkVersion:
            return "/appversion/latest"
        case let .checkText(text):
            return "mic/audit/text/\(text)"
        case .findRoomByUser:
            return "/mic/room/online/created/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .sendCode:
            return .post
        case .login:
            return .post
        case .loginDevice:
            return .post
        case .createRoom:
            return .post
        case .roomlist:
            return .get
        case .gameroomlist:
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
        case .updateRoomBackground:
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
        case .syncRoomPlayingMusicInfo:
            return .post
        case .fetchRoomPlayingMusicInfo:
            return .get
        case .moveMusic:
            return .post
        case .roomState:
            return .get
        case .refreshToken:
            return .post
        case .getUserInfo:
            return .get
        case .feedback:
            return .post
        case .forbiddenList:
            return .get
        case .appendForbidden:
            return .post
        case .deleteForbidden:
            return .get
        case .follow:
            return .get
        case .followList:
            return .get
        case .userUpdateCurrentRoom:
            return .get
        case .onlineCreator:
          return .get
        case .setPKState:
            return .post
        case .suspendRoom:
            return .get
        case .resumeRoom:
            return .get
        case .roomInfo:
            return .get
        case .roomBroadcast:
            return .post
        case .pkDetail:
            return .get
        case .checkCurrentRoom:
            return .get
        case .isPK:
            return .get
        case .checkCreatedRoom:
            return .put
        case .resign:
            return .post
        case .checkVersion:
            return .get
        case .checkText:
            return .post
        case .findRoomByUser:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case let .sendCode(number,region):
            return .requestParameters(parameters: ["mobile": number,
                                                   "region": region], encoding: JSONEncoding.default)
        case let .login(mobile, code, userName, portrait, deviceId, region, platform):
            let params: [String: Any?] = [
                "mobile": mobile,
                "verifyCode":code,
                "userName": userName,
                "portrait": portrait,
                "region": region,
                "deviceId": deviceId,
                "platform": platform,
                "platformType": "ios",
                "version": appVersion,
                "channel": kAppChannel
            ]
            print(params)
            return .requestParameters(parameters: params.compactMapValues { $0 },
                                      encoding: JSONEncoding.default)
        case .loginDevice:
            return.requestPlain
        case let .createRoom(name, themePictureUrl, backgroundUrl, kv, isPrivate, password, roomType):
            var params: [String: Any] = ["name": name, "themePictureUrl": themePictureUrl, "kv": kv, "isPrivate": isPrivate, "backgroundUrl": backgroundUrl, "roomType": roomType]
            if let password = password {
                params["password"] = password
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .roomlist(type, page, size):
            return .requestParameters(parameters: ["type": type, "size": size, "page": page, "q": Date().timeIntervalSince1970], encoding: URLEncoding.default)
        case let .gameroomlist(type, page, size, sex, gameId):
            return .requestParameters(parameters: ["type": type, "size": size, "page": page, "sex": sex, "gameId": gameId, "q": Date().timeIntervalSince1970], encoding: URLEncoding.default)
        case let .usersInfo(list):
            return .requestParameters(parameters: ["userIds": list], encoding: JSONEncoding.default)
        case let .upload(data):
            let imageData = MultipartFormData(provider: .data(data), name: "file", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
            return .uploadMultipart([imageData])
        case let .uploadAudio(data, ext):
            let fileName = "\(Int(Date().timeIntervalSince1970)).\(ext ?? "mp3")"
            let imageData = MultipartFormData(provider: .data(data), name: "file", fileName: fileName, mimeType: "audio/mpeg3")
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
        case let .updateRoomBackground(roomId, backgroundUrl):
            return .requestParameters(parameters: ["roomId": roomId, "backgroundUrl": backgroundUrl], encoding: JSONEncoding.default)
        case .giftList:
            return .requestPlain
        case let .sendGift(roomId, giftId, toUid, num):
            return .requestParameters(parameters: ["roomId": roomId, "giftId": giftId, "toUid": toUid, "num": num],
                                      encoding: JSONEncoding.default)
        case let .musiclist(roomId, type):
            return .requestParameters(parameters: ["roomId": roomId, "type": type],
                                      encoding: JSONEncoding.default)
        case let .addMusic(roomId, musicName, author, type, url, backgroundUrl, thirdMusicId, size):
            return .requestParameters(parameters: ["roomId": roomId, "type": type, "name": musicName, "author": author, "url": url, "size": size, "backgroundUrl":backgroundUrl, "thirdMusicId":thirdMusicId],
                                      encoding: JSONEncoding.default)
        case let .deleteMusic(roomId, musicId):
            return .requestParameters(parameters: ["roomId": roomId, "id": musicId],
                                      encoding: JSONEncoding.default)
        case let .syncRoomPlayingMusicInfo(roomId, musicId):
            let parameters = musicId == 0 ? ["roomId": roomId] : ["roomId": roomId, "id": musicId];
            return .requestParameters(parameters: parameters,
                                      encoding: JSONEncoding.default)
        case .fetchRoomPlayingMusicInfo:
            return .requestPlain
        case let .moveMusic(roomId, fromId, toId):
            return .requestParameters(parameters: ["roomId": roomId, "fromId": fromId, "toId": toId],
                                      encoding: JSONEncoding.default)
        case .roomState:
            return .requestPlain
        case .refreshToken:
            return .requestPlain
        case .getUserInfo:
            return .requestPlain
        case let .feedback(isGoodFeedback, reason):
            var parameters: [String: Any] = ["isGoodFeedback": isGoodFeedback]
            if let reason = reason {
                parameters["reason"] = reason
            }
            return .requestParameters(parameters: parameters,
                                      encoding: JSONEncoding.default)
        case .forbiddenList:
            return .requestPlain
        case let .appendForbidden(roomId, name):
            return .requestParameters(parameters: ["roomId": roomId, "name": name],
                                      encoding: JSONEncoding.default)
        case .deleteForbidden:
            return .requestPlain
            
        case .follow: return .requestPlain
            
        case let .followList(page, type):
            return .requestParameters(parameters: ["size": 20, "page": page, "type": type],
                                      encoding: URLEncoding.default)
        case let .userUpdateCurrentRoom(roomId):
            return .requestParameters(parameters: ["roomId": roomId],
                                      encoding: URLEncoding.default)
            
        case .onlineCreator(let type):
            return .requestParameters(parameters: ["roomType": type],
                                      encoding: URLEncoding.default)
        case let .setPKState(roomId, toRoomId, status):
            return .requestParameters(parameters: ["roomId": roomId, "toRoomId": toRoomId, "status": status],
                                             encoding: JSONEncoding.default)
        case .suspendRoom, .resumeRoom:
            return .requestPlain
        case .roomInfo:
            return .requestPlain
        case let .roomBroadcast(userId, objectName, content):
            return .requestParameters(parameters: ["fromUserId": userId, "objectName": objectName, "content": content],
                                      encoding: JSONEncoding.default)
        case .pkDetail:
            return .requestPlain
        case .checkCurrentRoom:
            return.requestPlain
        case .isPK:
            return .requestPlain
        case .checkCreatedRoom(let type):
            return .requestParameters(parameters: ["roomType": type],
                                      encoding: JSONEncoding.default)
        case .resign:
            return .requestPlain
        case let .checkVersion(platform):
            return .requestParameters(parameters: ["platform": platform], encoding: URLEncoding.default)
        case .checkText:
            return .requestPlain
        case let .findRoomByUser(userId, roomType):
            return .requestPlain
//            return .requestParameters(parameters: ["roomType": roomType, "userId": userId], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        var header = [String: String]()
        if let auth = UserDefaults.standard.authorizationKey() {
            header["Authorization"] = auth
        }
        header["BusinessToken"] = Environment.businessToken
        return header
    }
}

//    {
//        return ""
//        return "baiduBrand"
//        return "baiduPay"
//        return "sogouPay"
//        return "360Pay"
//        return "smPay"
//        return "bdfeed"
//        return "googleWM"
//        return "direct"
//        return "baiduNature"
//        return "360Nature"
//        return "sogouNature"
//        return "outside"
//        return "google"
//        return "Wechat"
//        return "googlepay"
//        return "userassign"
//    }
fileprivate let kAppChannel: String = ""
