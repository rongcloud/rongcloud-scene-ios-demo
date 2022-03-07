//
//  RCNetworkState.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/4.
//

import Foundation

public enum RCNetworkState: Equatable {
    case idle
    case begin
    case success
    case failure(ReactorError)
}


import Moya

public struct NetError: Error, LocalizedError {
    let msg: String
    
    public init(_ msg: String) {
        self.msg = msg
    }
    
    public var errorDescription: String? {
        return msg
    }
}

extension Result where Success == Moya.Response, Failure == MoyaError {
    public func map<T: Codable>(_ type: T.Type) -> Result<T, NetError> {
        switch self {
        case let .failure(error):
            return .failure(NetError(error.localizedDescription))
        case let .success(response):
            do {
                let model = try JSONDecoder().decode(type, from: response.data)
                return .success(model)
            } catch {
                debugPrint("map fail: \(error.localizedDescription)")
            }
            return .failure(NetError("数据解析失败"))
        }
    }
}
