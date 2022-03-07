//
//  RCUserService.swift
//  RCE
//
//  Created by xuefeng on 2022/2/7.
//

import Foundation
import Moya

public let userProvider = MoyaProvider<RCUserService>(plugins: [RCServicePlugin])

public enum RCUserService {
    case usersInfo(id: [String])
    case updateUserInfo(userName: String, portrait: String)
    case getUserInfo(phone: String)
    case follow(userId: String)
    case followList(page: Int, type: Int)
    case onlineCreator
    case refreshToken(auth: String)
    case resign
}

extension RCUserService: RCServiceType {
    
    public var path: String {
        switch self {
        case .usersInfo:
            return "user/batch"
        case .updateUserInfo:
            return "user/update"
        case let .getUserInfo(phone):
            return "user/get/\(phone)"
        case let .follow(userId):
            return "user/follow/\(userId)"
        case .followList:
            return "user/follow/list"
        case .onlineCreator:
          return "mic/room/online/created/list"
        case .refreshToken:
            return "user/refreshToken"
        case .resign:
            return "/user/resign"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .usersInfo:
            return .post
        case .updateUserInfo:
            return .post
        case .getUserInfo:
            return .get
        case .follow:
            return .get
        case .followList:
            return .get
        case .onlineCreator:
          return .get
        case .refreshToken:
            return .post
        case .resign:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case let .usersInfo(list):
            return .requestParameters(parameters: ["userIds": list], encoding: JSONEncoding.default)
        case let .updateUserInfo(userName, portrait):
            return .requestParameters(parameters: ["userName": userName, "portrait": portrait], encoding: JSONEncoding.default)
        case .getUserInfo:
            return .requestPlain
        case .follow: return .requestPlain
        case let .followList(page, type):
            return .requestParameters(parameters: ["size": 20, "page": page, "type": type],
                                      encoding: URLEncoding.default)
        case .onlineCreator:
            return .requestPlain
        case .refreshToken:
            return .requestPlain
        case .resign:
            return .requestPlain
        }
    }
}
