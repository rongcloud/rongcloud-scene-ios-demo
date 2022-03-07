//
//  UploadfileResponse.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/13.
//

import Foundation
import RCSceneFoundation

public struct UploadfileResponse: Codable {
    let code: Int
    public let data: String
    
    public func imageURL() -> String {
        return Environment.current.url.absoluteString + "file/show?" + "path=\(data)"
    }
}
