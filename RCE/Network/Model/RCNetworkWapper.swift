//
//  RCNetworkWapper.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/19.
//

import Foundation

struct RCNetworkWapper<T: Codable>: Codable {
    let code: Int
    let msg: String?
    let data: T?
}
