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

struct NetError: Error, LocalizedError {
    let msg: String
    
    public init(_ msg: String) {
        self.msg = msg
    }
    
    public var errorDescription: String? {
        return msg
    }
}
