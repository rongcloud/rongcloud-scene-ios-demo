//
//  SendCodeResponse.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/27.
//

import Foundation

struct SendCodeResponse: Codable {
    let code: Int
    
    func validate() -> Bool {
        return code == 10000
    }
}
