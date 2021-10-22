//
//  VoiceRoomMusic.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import Foundation
struct VoiceRoomMusic: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let author: String
    let roomId: String
    let type: Int
    let url: String?
    let size: String
    
    static func == (lhs: VoiceRoomMusic, rhs: VoiceRoomMusic) -> Bool {
        return lhs.url == rhs.url
    }
    
    func fileURL() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = urls[0]
        return documentsDirectory.appendingPathComponent(self.name)
    }
    
    func isFileExist() -> Bool {
        return FileManager.default.fileExists(atPath: fileURL().path)
    }
}

struct VoiceRoomLocalMusic {
    let name: String
    let author: String
    let size: Int
    let filePath: String
    var url: String = ""
    
    mutating func setUrl(_ string: String) {
        self.url = string
    }
    
    static func localMusic(_ fileURL: URL) -> VoiceRoomLocalMusic? {
        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }
        guard
            fileURL.startAccessingSecurityScopedResource()
        else {
            return nil
        }
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let filePath = docPath + "/" + fileURL.lastPathComponent
        do {
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }
            try FileManager.default.copyItem(at: fileURL, to: URL(fileURLWithPath: filePath))
            
            var name = fileURL.lastPathComponent
            var author = ""
            let asset = AVURLAsset(url: URL(fileURLWithPath: filePath))
            for format in asset.availableMetadataFormats {
                let metadata = asset.metadata(forFormat: format)
                for item in metadata {
                    if item.commonKey?.rawValue == "title" {
                        name = item.value as? String ?? ""
                    } else if item.commonKey?.rawValue == "artist" {
                        author = item.value as? String ?? ""
                    }
                }
            }
            
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            let fileSize = attribute[.size] as? Int ?? 0
            return VoiceRoomLocalMusic(name: name, author: author, size: fileSize / 1024, filePath: filePath)
        } catch {
            return nil
        }
    }
}
