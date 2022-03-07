//
//  VoiceRoomService.swift
//  RCSceneVoiceRoom
//
//  Created by hanxiaoqing on 2022/2/11.
//

import Foundation
import RCSceneService
import RCSceneFoundation
import Moya

let musicService = MusicService()

class MusicService {
    func musicList(roomId: String, type: Int, completion: @escaping Completion) {
        let api = RCMusicService.musicList(roomId: roomId, type: type)
        musicProvider.request(api, completion: completion)
    }
    
    func fetchRoomPlayingMusicInfo(roomId: String, completion: @escaping Completion) {
        let api = RCMusicService.fetchRoomPlayingMusicInfo(roomId: roomId)
        musicProvider.request(api, completion: completion)
    }
    
    func addMusic(roomId: String, musicName: String, author: String, type: Int, url: String, backgroundUrl: String, thirdMusicId: String, size: Int, completion: @escaping Completion) {
        let api = RCMusicService.addMusic(roomId: roomId, musicName: musicName, author: author, type: type, url: url, backgroundUrl: backgroundUrl, thirdMusicId: thirdMusicId, size: size)
        musicProvider.request(api, completion: completion)
    }
    
    func deleteMusic(roomId: String, musicId: Int, completion: @escaping Completion) {
        let api = RCMusicService.deleteMusic(roomId: roomId, musicId: musicId)
        musicProvider.request(api, completion: completion)
    }
    
    func syncRoomPlayingMusicInfo(roomId: String, musicId: Int, completion: @escaping Completion) {
        let api = RCMusicService.syncRoomPlayingMusicInfo(roomId: roomId, musicId: musicId)
        musicProvider.request(api, completion: completion)
    }
    
    func moveMusic(roomId: String, fromId: Int, toId: Int, completion: @escaping Completion) {
        let api = RCMusicService.moveMusic(roomId: roomId, fromId: fromId, toId: toId)
        musicProvider.request(api, completion: completion)
    }
}

