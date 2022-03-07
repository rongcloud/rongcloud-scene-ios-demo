//
//  RCMusicService.swift
//  RCE
//
//  Created by xuefeng on 2022/2/7.
//

import Foundation
import Moya

public let musicProvider = MoyaProvider<RCMusicService>(plugins: [RCServicePlugin])

public enum RCMusicService {
    case musicList(roomId: String, type: Int)
    case addMusic(roomId: String, musicName: String, author: String, type: Int, url: String, backgroundUrl: String, thirdMusicId: String, size: Int)
    case deleteMusic(roomId: String, musicId: Int)
    case syncRoomPlayingMusicInfo(roomId: String, musicId: Int)
    case fetchRoomPlayingMusicInfo(roomId: String)
    case moveMusic(roomId: String, fromId: Int, toId: Int)
}

extension RCMusicService: RCServiceType {
    
    public var path: String {
        switch self {
        case .musicList:
            return "mic/room/music/list"
        case .addMusic:
            return "mic/room/music/add"
        case .deleteMusic:
            return "mic/room/music/delete"
        case .syncRoomPlayingMusicInfo:
            return "mic/room/music/play"
        case let .fetchRoomPlayingMusicInfo(roomId):
            return "mic/room/music/play/\(roomId)"
        case .moveMusic:
            return "mic/room/music/move"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .musicList:
            return .post
        case .addMusic:
            return .post
        case .deleteMusic:
            return .post
        case .syncRoomPlayingMusicInfo:
            return .post
        case .fetchRoomPlayingMusicInfo:
            return .get
        case .moveMusic:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case let .musicList(roomId, type):
            return .requestParameters(parameters: ["roomId": roomId, "type": type],
                                      encoding: JSONEncoding.default)
        case let .addMusic(roomId, musicName, author, type, url, backgroundUrl, thirdMusicId, size):
            return .requestParameters(parameters: ["roomId": roomId, "type": type, "name": musicName, "author": author, "url": url, "size": size, "backgroundUrl":backgroundUrl, "thirdMusicId":thirdMusicId],
                                      encoding: JSONEncoding.default)
        case let .deleteMusic(roomId, musicId):
            return .requestParameters(parameters: ["roomId": roomId, "id": musicId],
                                      encoding: JSONEncoding.default)
        case let .syncRoomPlayingMusicInfo(roomId, musicId):
            let parameters = musicId == 0 ? ["roomId": roomId] : ["roomId": roomId, "id": musicId];
            return .requestParameters(parameters: parameters,
                                      encoding: JSONEncoding.default)
        case .fetchRoomPlayingMusicInfo:
            return .requestPlain
        case let .moveMusic(roomId, fromId, toId):
            return .requestParameters(parameters: ["roomId": roomId, "fromId": fromId, "toId": toId],
                                      encoding: JSONEncoding.default)
        }
    }
}

