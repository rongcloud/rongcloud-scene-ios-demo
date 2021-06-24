//
//  UploadfileResponse.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/13.
//

import Foundation

struct UploadfileResponse: Codable {
    let code: Int
    let data: String
    
    func imageURL() -> String {
        return Environment.current.url.absoluteString + "/file/show?" + "path=\(data)"
    }
}
