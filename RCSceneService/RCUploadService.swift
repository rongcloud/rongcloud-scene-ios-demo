//
//  RCDataService.swift
//  RCE
//
//  Created by xuefeng on 2022/2/7.
//

import Foundation
import Moya

public let uploadProvider = MoyaProvider<RCUploadService>(plugins: [RCServicePlugin])

public enum RCUploadService {
    case upload(data: Data)
    case uploadAudio(data: Data, extensions: String? = nil)
}

extension RCUploadService: RCServiceType {
    
    public var path: String {
        switch self {
        case .upload, .uploadAudio:
            return "file/upload"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .upload, .uploadAudio:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case let .upload(data):
            let imageData = MultipartFormData(provider: .data(data), name: "file", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
            return .uploadMultipart([imageData])
        case let .uploadAudio(data, ext):
            let fileName = "\(Int(Date().timeIntervalSince1970)).\(ext ?? "mp3")"
            let imageData = MultipartFormData(provider: .data(data), name: "file", fileName: fileName, mimeType: "audio/mpeg3")
            return .uploadMultipart([imageData])
        }
    }
}



