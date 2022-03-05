//
//  Response.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/27.
//

import Foundation

struct AppResponse: Codable {
    let code: Int
    let msg: String?
    
    func validate() -> Bool {
        return code == 10000
    }
}
