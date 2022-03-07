//
//  RCLoginService.swift
//  RCE
//
//  Created by xuefeng on 2022/1/28.
//

import Foundation
import Moya


public let loginProvider = MoyaProvider<RCLoginService>(plugins: [RCServicePlugin])

public enum RCLoginService {
    case sendCode(mobile: String, region: String)
    case login(mobile: String, code: String, userName: String?, portrait: String?, deviceId: String, region: String, platform: String)
    case loginDevice
}

extension RCLoginService: RCServiceType {
    public var path: String {
        switch self {
        case .sendCode:
            return "user/sendCode"
        case .login:
            return "user/login"
        case .loginDevice:
            return "user/login/device/mobile"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .sendCode:
            return .post
        case .login:
            return .post
        case .loginDevice:
            return .post
        }
    }

    public var task: Task {
        switch self {
        case let .sendCode(number,region):
            return .requestParameters(parameters: ["mobile": number,
                                                   "region": region], encoding: JSONEncoding.default)
        case let .login(mobile, code, userName, portrait, deviceId, region, platform):
            return .requestParameters(parameters: ["mobile": mobile,
                                                   "verifyCode":code,
                                                   "userName": userName,
                                                   "portrait": portrait,
                                                   "deviceId": deviceId,
                                                   "platform": platform,
                                                   "region": region].compactMapValues { $0 }, encoding: JSONEncoding.default)
        case .loginDevice:
            return.requestPlain
        }
    }
}

