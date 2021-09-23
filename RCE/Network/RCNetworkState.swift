//
//  RCNetworkState.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/4.
//

import Foundation

enum RCNetworkState: Equatable {
    case idle
    case begin
    case success
    case failure(ReactorError)
}


import Moya

struct NetError: Error, LocalizedError {
    let msg: String
    
    init(_ msg: String) {
        self.msg = msg
    }
    
    var errorDescription: String? {
        return msg
    }
}

extension Result where Success == Moya.Response, Failure == MoyaError {
    func map<T: Codable>(_ type: T.Type) -> Result<T, NetError> {
        switch self {
        case let .failure(error):
            return .failure(NetError(error.localizedDescription))
        case let .success(response):
            guard let model = try? JSONDecoder().decode(type, from: response.data) else {
                return .failure(NetError("数据解析失败"))
            }
            return .success(model)
        }
    }
}
