//
//  VoiceRoomMusicService.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/28.
//

import Foundation
import RxSwift

struct MusicFile: Codable {
    let fileUrl: String
    
}

protocol VoiceRoomMusicServiceProtocol {
    func channelSheetList(groupId: String) -> Observable<[MusicChannel]>
    func musicList(sheetId: Int) -> Observable<[MusicRecord]>
    func musicUrl(musicId: String) -> Observable<String>
}

final class VoiceRoomMusicService: VoiceRoomMusicServiceProtocol {
    func channelSheetList(groupId: String) -> Observable<[MusicChannel]> {
        return Observable.create { observer in
            HFOpenApiManager.shared().channelSheet(withGroupId: groupId, language: "0", recoNum: "0", page: "1", pageSize: "20") { response in
                if let dict = response,
                   let data = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed) {
                    do {
                        let list = try JSONDecoder().decode([MusicChannel].self, from: data, keyPath: "record")
                        observer.onNext(list)
                        observer.onCompleted()
                    } catch let error {
                        debugPrint(error)
                        observer.onError(error)
                    }
                } else {
                    observer.onCompleted()
                }
            } fail: { _ in
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func musicList(sheetId: Int) -> Observable<[MusicRecord]> {
        return Observable.create { observer in
            HFOpenApiManager.shared().sheetMusic(withSheetId: "\(sheetId)", language: "0", page: "1", pageSize: "20") { response in
                if let dict = response,
                   let data = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed) {
                    do {
                        let list = try JSONDecoder().decode([MusicRecord].self, from: data, keyPath: "record")
                        observer.onNext(list)
                        observer.onCompleted()
                    } catch let error {
                        observer.onError(error)
                    }
                } else {
                    observer.onCompleted()
                }
            } fail: { error in
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func musicUrl(musicId: String) -> Observable<String> {
        return Observable.create { observer in
            HFOpenApiManager.shared().trafficHQListen(withMusicId: musicId, audioFormat: nil, audioRate: nil) { response in
                if let response = response,
                   let data = try? JSONSerialization.data(withJSONObject: response, options: .fragmentsAllowed) {
                    do {
                        let file = try JSONDecoder().decode(MusicFile.self, from: data)
                        observer.onNext(file.fileUrl)
                        observer.onCompleted()
                    } catch let error {
                        observer.onError(error)
                    }
                } else {
                    observer.onCompleted()
                }
            } fail: { error in
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
