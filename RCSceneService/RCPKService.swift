//
//  RCPKService.swift
//  RCE
//
//  Created by xuefeng on 2022/2/7.
//

import Foundation
import Moya

public let pkProvider = MoyaProvider<RCPKService>(plugins: [RCServicePlugin])

public enum RCPKService {
    case setPKState(roomId: String, toRoomId: String, status: Int)
    case pkDetail(roomId: String)
    case isPK(roomId: String)
}

extension RCPKService: RCServiceType {
    
    public var path: String {
        switch self {
        case .setPKState:
            return "mic/room/pk"
        case let .pkDetail(roomId):
            return "/mic/room/pk/detail/\(roomId)"
        case let .isPK(roomId):
            return "/mic/room/pk/\(roomId)/isPk"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .setPKState:
            return .post
        case .pkDetail:
            return .get
        case .isPK:
            return .get
        }
    }
    
    public var task: Task {
        switch self {
        case let .setPKState(roomId, toRoomId, status):
            return .requestParameters(parameters: ["roomId": roomId, "toRoomId": toRoomId, "status": status],
                                             encoding: JSONEncoding.default)
        case .pkDetail:
            return .requestPlain
        case .isPK:
            return .requestPlain
        }
    }
}


