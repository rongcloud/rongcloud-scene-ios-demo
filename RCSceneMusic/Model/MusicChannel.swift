//
//  MusicChannel.swift
//  RCE
//
//  Created by 叶孤城 on 2021/10/8.
//

import Foundation

struct MusicChannel: Codable, Equatable {
    let sheetId: Int
    let sheetName: String
    let music: [MusicRecord]
    
    static func == (lhs: MusicChannel, rhs: MusicChannel) -> Bool {
        return lhs.sheetId == rhs.sheetId
    }
}

struct MusicArtist: Codable {
    let name: String
}

struct MusicCover: Codable {
    let url: String
}

struct MusicRecord: Codable, Identifiable, Equatable {
    var id: String {
        return musicId
    }
    let musicId: String
    let musicName: String
    let albumName: String
    let artist: [MusicArtist]
    let cover: [MusicCover]
    let duration: Int
    var url: String?
    
    func fileURL() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = urls[0]
        return documentsDirectory.appendingPathComponent(self.musicName)
    }
    
    func isFileExist() -> Bool {
        return FileManager.default.fileExists(atPath: fileURL().path)
    }
    
    static func == (lhs: MusicRecord, rhs: MusicRecord) -> Bool {
        return lhs.musicId == rhs.musicId
    }
}
