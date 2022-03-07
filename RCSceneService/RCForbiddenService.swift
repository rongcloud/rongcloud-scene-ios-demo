//
//  RCForbiddenService.swift
//  RCE
//
//  Created by xuefeng on 2022/2/7.
//

import Foundation
import Moya

public let forbiddenProvider = MoyaProvider<RCForbiddenService>(plugins: [RCServicePlugin])

public enum RCForbiddenService {
    case forbiddenList(roomId: String)
    case appendForbidden(roomId: String, name: String)
    case deleteForbidden(id: String)
}

extension RCForbiddenService: RCServiceType {
    public var path: String {
        switch self {
        case let .forbiddenList(roomId):
            return "mic/room/sensitive/\(roomId)/list"
        case .appendForbidden:
            return "mic/room/sensitive/add"
        case let .deleteForbidden(id):
            return "mic/room/sensitive/del/\(id)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .forbiddenList:
            return .get
        case .appendForbidden:
            return .post
        case .deleteForbidden:
            return .get
        }
    }
    
    public var task: Task {
        switch self {
        case .forbiddenList:
            return .requestPlain
        case let .appendForbidden(roomId, name):
            return .requestParameters(parameters: ["roomId": roomId, "name": name],
                                      encoding: JSONEncoding.default)
        case .deleteForbidden:
            return .requestPlain
        }
    }
}


