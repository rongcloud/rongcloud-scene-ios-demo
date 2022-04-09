//
//  SendCodeResponse.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/27.
//

import Foundation

public struct SendCodeResponse: Codable {
    let code: Int
    public let msg: String?
    public func validate() -> Bool {
        return code == 10000
    }
}
