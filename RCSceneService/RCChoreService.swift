//
//  RCChoreService.swift
//  RCE
//
//  Created by xuefeng on 2022/2/7.
//

import Foundation
import Moya

public let choreProvider = MoyaProvider<RCChoreService>(plugins: [RCServicePlugin])

public enum RCChoreService {
    case feedback(isGoodFeedback: Bool, reason: String?)
    case checkVersion(platform: String)
    case checkText(text: String)
}

extension RCChoreService: RCServiceType {
    
    public var path: String {
        switch self {
        case .feedback:
            return "feedback/create"
        case .checkVersion:
            return "/appversion/latest"
        case let .checkText(text):
            return "mic/audit/text/\(text)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .feedback:
            return .post
        case .checkVersion:
            return .get
        case .checkText:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case let .feedback(isGoodFeedback, reason):
            var parameters: [String: Any] = ["isGoodFeedback": isGoodFeedback]
            if let reason = reason {
                parameters["reason"] = reason
            }
            return .requestParameters(parameters: parameters,
                                      encoding: JSONEncoding.default)
        case let .checkVersion(platform):
            return .requestParameters(parameters: ["platform": platform], encoding: URLEncoding.default)
        case .checkText:
            return .requestPlain
        }
    }
}



