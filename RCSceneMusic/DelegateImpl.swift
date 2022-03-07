//
//  DelegateImpl.swift
//  RCE
//
//  Created by xuefeng on 2021/11/30.
//

import UIKit
import SVProgressHUD
import RCSceneService

public class DelegateImpl: NSObject, RCMusicEngineDelegate {
    
    public static let instance = DelegateImpl()
    
    public var roomId: String?

    var downloadingMusicId: String?
    
    let semaphore = DispatchSemaphore(value: 1)
    
    var autoPlayMusic = false
    
    public func downloadedMusic(_ music: RCMusicInfo, completion: @escaping (Bool) -> Void) {
        
        guard let music = music as? MusicInfo, let roomId = DelegateImpl.instance.roomId, let url = music.fileUrl, let musicId = music.musicId else {
            SVProgressHUD.showError(withStatus: "参数错误")
            return completion(false)
        }
        
        //如果当前下载的音乐和即将下载的音乐相同时过滤掉
        if (DelegateImpl.instance.downloadingMusicId == musicId || DataSourceImpl.instance.ids.contains(musicId)) {
            return completion(false)
        }
        
        DelegateImpl.instance.downloadingMusicId = musicId
        func downloadFailed() {
            completion(false)
            semaphore.signal()
            clear()
            SVProgressHUD.showError(withStatus: "下载音乐失败")
        }
        DispatchQueue.global().async {
            let wait = self.semaphore.wait(timeout: .distantFuture)
            if (wait == .success) {
                MusicDownloader.shared.hifiveDownload(music: music) { success in
                    guard let filePath = music.fullPath() else {
                        return downloadFailed()
                    }
                    if (success) {
                        do {
                            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
                            let fileSize = attribute[.size] as? Int ?? 0
                            musicService.addMusic(roomId: roomId,
                                                   musicName: music.musicName ?? "",
                                                   author: music.author ?? "",
                                                   type: 3,
                                                   url: url,
                                                   backgroundUrl: music.coverUrl ?? "",
                                                   thirdMusicId: musicId,
                                                   size: fileSize) { result in
                                switch result.map(AppResponse.self) {
                                case .success:
                                    completion(true)
                                    if (DataSourceImpl.instance.ids.count == 0) {
                                        //当列表为空时，添加的第一首音乐自动播放
                                        self.autoPlayMusic = true
                                    }
                                    DataSourceImpl.instance.ids.insert(musicId)
                                    NotificationCenter.default.post(name: .RCMusicLocalDataChanged, object: nil)
                                    self.clear()
                                    self.semaphore.signal()
                                case .failure:
                                    downloadFailed()
                                }
                            }
                        } catch {
                            downloadFailed()
                        }
                    } else {
                        downloadFailed()
                    }
                }
            }
        }
    }
    
    public func deleteMusic(_ music: RCMusicInfo, completion: @escaping (Bool) -> Void) {
        guard let roomId = DelegateImpl.instance.roomId, let musicId = music.musicId, let info = music as? MusicInfo, let id = info.id else {
            SVProgressHUD.showError(withStatus: "参数错误，roomId为空")
            return completion(false)
        }
        
        DispatchQueue.global().async {
            let wait = self.semaphore.wait(timeout: .distantFuture)
            if (wait == .success) {
                musicService.deleteMusic(roomId: roomId, musicId: id) { result in
                    switch result.map(AppResponse.self) {
                    case .success:
                        completion(true)
                        DataSourceImpl.instance.ids.remove(musicId)
                        NotificationCenter.default.post(name: .RCMusicLocalDataChanged, object: nil)
                    case .failure:
                        completion(false)
                        SVProgressHUD.showError(withStatus: "网络错误")
                    }
                    self.semaphore.signal()
                }
            }
        }
    }
    
    
    public func topMusic(_ music1: RCMusicInfo?, withMusic music2: RCMusicInfo, completion: @escaping (Bool) -> Void) {
        guard let roomId = DelegateImpl.instance.roomId, let info2 = music2 as? MusicInfo, let id2 = info2.id  else {
            SVProgressHUD.showError(withStatus: "参数错误")
            return completion(false)
        }
        
        let info1 = music1 as? MusicInfo
        
        let id1 = info1 == nil ? 0 : info1!.id
        
        DispatchQueue.global().async {
            let wait = self.semaphore.wait(timeout: .distantFuture)
            if (wait == .success) {
                musicService.moveMusic(roomId: roomId, fromId: id2, toId: id1 ?? 0) { result in
                    switch result.map(AppResponse.self) {
                    case .success:
                        //音乐置顶成功后，如果当前没有播放的音乐，开始播放置顶音乐
                        if (PlayerImpl.instance.currentPlayingMusic == nil) {
                            let _ = PlayerImpl.instance.startMixing(with: info2)
                        }
                        completion(true)
                        NotificationCenter.default.post(name: .RCMusicLocalDataChanged, object: nil)
                    case .failure:
                        completion(false)
                        SVProgressHUD.showError(withStatus: "网络错误")
                    }
                    self.semaphore.signal()
                }
            }
        }
    }
    
    //开始播放 同步状态时 info != nil
    //暂停播放 同步状态时 info == nil
    func syncPlayingMusicInfo(_ info: MusicInfo?,_ completion: @escaping () -> Void) {
        guard let roomId = roomId else {
            print("同步音乐信息失败，房间ID不能为空")
            return
        }
        
        var id = 0
        
        if let info = info, let musicId = info.id {
            id = musicId
        }
        musicService.syncRoomPlayingMusicInfo(roomId: roomId, musicId: id) { result in
            switch result.map(AppResponse.self) {
            case .success:
                print("同步音乐信息成功")
                completion()
            case .failure:
                print("同步音乐信息失败")
            }
        }
    }
    
    public func clear() {
        DelegateImpl.instance.downloadingMusicId = nil
    }
}
