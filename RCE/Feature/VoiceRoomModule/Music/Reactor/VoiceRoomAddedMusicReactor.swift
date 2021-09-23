//
//  VoiceRoomAddedMusicReactor.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import Foundation
import ReactorKit

enum MusicPlayStatus {
    case playing(VoiceRoomMusic)
    case pause
    case stop
}

extension MusicPlayStatus: Equatable {
    static func ==(lhs: MusicPlayStatus, rhs: MusicPlayStatus) -> Bool {
        switch (lhs, rhs) {
        case (.pause, .pause):
            return true
        case (.stop, .stop):
            return true
        case (let .playing(music1), let .playing(music2)):
            return music1.id == music2.id
        default:
            return false
        }
    }
}

final class VoiceRoomAddedMusicReactor: Reactor {
    enum Action {
        case refresh
        case append
        case delete(musicId: Int)
        case playMusic(VoiceRoomMusic)
        case pause
        case musicDidPlayEnd
        case stick(VoiceRoomMusic)
    }
    
    enum Mutation {
        case setRoomMusic(items: [VoiceRoomMusic])
        case removeMusic(musicId: Int)
        case setError(ReactorError)
        case setPlayStatus(MusicPlayStatus)
        case setUserNotOnSeatWarning(Bool)
    }
    
    struct State {
        var roomId: String
        var addedItems = [VoiceRoomMusic]()
        var sections = [VoiceRoomMusicSection]()
        var error: ReactorError?
        var playingMusic: VoiceRoomMusic?
        var playStatus = MusicPlayStatus.stop
        var showUserNotOnSeatWarn = false
    }
    
    var initialState: State
    
    init(roomId: String) {
        initialState = State(roomId: roomId)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            let roomMusiclist = networkProvider.rx
                .request(.musiclist(roomId: currentState.roomId, type: 1))
                .asObservable()
                .filterSuccessfulStatusCodes()
                .map([VoiceRoomMusic].self, atKeyPath: "data")
                .flatMapLatest { items -> Observable<Mutation> in
                    return Observable<Mutation>.just(.setRoomMusic(items: items))
                }
                .catchAndReturn(.setRoomMusic(items: []))
            return roomMusiclist
        case .append:
            let currentMusicsCount = currentState.addedItems.count
            let roomMusiclist = networkProvider.rx
                .request(.musiclist(roomId: currentState.roomId, type: 1))
                .asObservable()
                .filterSuccessfulStatusCodes()
                .map([VoiceRoomMusic].self, atKeyPath: "data")
                .flatMapLatest { [weak self] items -> Observable<Mutation> in
                    guard let self = self else { return .empty() }
                    if currentMusicsCount == 0, let music = items.first {
                        return .concat([.just(.setRoomMusic(items: items)), self.play(music)])
                    }
                    return Observable<Mutation>.just(.setRoomMusic(items: items))
                }
                .catchAndReturn(.setRoomMusic(items: []))
            return roomMusiclist
        case let .delete(musicId):
            let stopStatus = Observable<Mutation>.just(.setPlayStatus(.stop))
            let network = networkProvider.rx
                .request(.deleteMusic(roomId: currentState.roomId, musicId: musicId))
                .asObservable()
                .filterSuccessfulStatusCodes()
                .map(AppResponse.self)
                .flatMapLatest { items -> Observable<Mutation> in
                    return Observable<Mutation>.just(.removeMusic(musicId: musicId)).do { _ in
                        let notification = Notification.Name(rawValue: MusicNotification.deleteMusic.rawValue)
                        NotificationCenter.default.post(name: notification, object: nil)
                    }
                }
                .catchAndReturn(.setError(ReactorError("删除音乐失败，请重试")))
            if let currentPlayMusic = currentState.playingMusic, currentPlayMusic.id == musicId {
                RCRTCAudioMixer.sharedInstance().stop()
                return network.concat(stopStatus)
            } else {
                return network
            }
        case let .playMusic(music):
            return play(music)
        case .pause:
            RCRTCAudioMixer.sharedInstance().pause()
            return .just(.setPlayStatus(.pause))
        case .musicDidPlayEnd:
            let stop = Observable<Mutation>.just(.setPlayStatus(.stop))
            if let music = currentState.playingMusic, let index = currentState.addedItems.firstIndex(of: music) {
                if index < currentState.addedItems.count - 1 {
                    let nextMusic = currentState.addedItems[index + 1]
                    return MusicDownloader.shared.downloadMusic(nextMusic).flatMap {
                        _ -> Observable<Mutation> in
                        guard VoiceRoomManager.shared.isSitting() else {
                            return Observable<Mutation>.just(.setUserNotOnSeatWarning(true)).concat(Observable<Mutation>.just(.setUserNotOnSeatWarning(false)))
                        }
                        let isPlaying = RCRTCAudioMixer.sharedInstance().startMixing(with: nextMusic.fileURL(), playback: true, mixerMode: .mixing, loopCount: 1)
                        if isPlaying {
                            return stop.concat(Observable<Mutation>.just(.setPlayStatus(.playing(nextMusic))))
                        } else {
                            return stop.concat(Observable<Mutation>.just(.setError(ReactorError("音乐文件无法播放"))))
                        }
                    }
                }
            }
            return stop
        case let .stick(music):
            return stick(music)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setRoomMusic(items: let items):
            state.addedItems = items
            state.sections = [VoiceRoomMusicSection(items: state.addedItems.map {
                let musicId = $0.id
                let musicState: MusicListState = {
                    guard let id = state.playingMusic?.id else { return .couldDelete }
                    if state.playStatus == .pause || state.playStatus == .stop {
                        return .couldDelete
                    }
                    return id == musicId ? .playing : .couldDelete
                }()
                return VoiceRoomMusicItem(music: $0, state: musicState)
            })]
        case .removeMusic(let musicId):
            state.addedItems = state.addedItems.filter {
                $0.id != musicId
            }
            state.sections = [VoiceRoomMusicSection(items: state.addedItems.map {
                let musicState = (state.playingMusic?.id ?? -1) == $0.id ? MusicListState.playing : .couldDelete
                return VoiceRoomMusicItem(music: $0, state: musicState)
            })]
        case let .setError(error):
            state.error = error
        case let .setPlayStatus(status):
            state.playStatus = status
            switch status {
            case .stop:
                state.sections = [VoiceRoomMusicSection(items: state.addedItems.map {
                    return VoiceRoomMusicItem(music: $0, state: .couldDelete)
                })]
                state.playingMusic = nil
            case .pause:
                state.sections = [VoiceRoomMusicSection(items: state.addedItems.map {
                    return VoiceRoomMusicItem(music: $0, state: .couldDelete)
                })]
            case let .playing(music):
                print("music name:\(music.name)")
                state.playingMusic = music
                state.sections = [VoiceRoomMusicSection(items: state.addedItems.map {
                    let musicState = (music.id == $0.id ? MusicListState.playing : .couldDelete)
                    return VoiceRoomMusicItem(music: $0, state: musicState)
                })]
            }
        case let .setUserNotOnSeatWarning(isShow):
            state.showUserNotOnSeatWarn = isShow
        }
        return state
    }
}

extension VoiceRoomAddedMusicReactor {
    private func play(_ music: VoiceRoomMusic) -> Observable<Mutation> {
        let setStopMusicStatus = Observable<Mutation>.just(.setPlayStatus(.stop))
        let download = MusicDownloader.shared.downloadMusic(music).flatMap {
            isSuccess -> Observable<Mutation> in
            if isSuccess {
                RCRTCAudioMixer.sharedInstance().stop()
                guard VoiceRoomManager.shared.isSitting() else {
                    return Observable<Mutation>.just(.setUserNotOnSeatWarning(true)).concat(Observable<Mutation>.just(.setUserNotOnSeatWarning(false)))
                }
                let isPlaying = RCRTCAudioMixer.sharedInstance().startMixing(with: music.fileURL(), playback: true, mixerMode: .mixing, loopCount: 1)
                if isPlaying {
                    let setPlaying = Observable<Mutation>.just(.setPlayStatus(MusicPlayStatus.playing(music)))
                    return setStopMusicStatus.concat(setPlaying).concat(setPlaying)
                } else {
                    return Observable<Mutation>.just(.setError(ReactorError("音乐文件无法播放")))
                }
            } else {
                return .just(.setError(ReactorError("下载音乐失败，请稍后重试"))).concat(setStopMusicStatus)
            }
        }
        return download
    }
    private func stick(_ music: VoiceRoomMusic) -> Observable<Mutation> {
        var items = currentState.addedItems
        ///如果没有播放，将音乐移到顶部
        guard let playingMusic = currentState.playingMusic, case .playing = currentState.playStatus else {
//            if let index = items.firstIndex(of: music) {
//                items.remove(at: index)
//                items.insert(music, at: 0)
//            }
            return .concat([.just(.setRoomMusic(items: items)), play(music)])
        }
        ///如果当前有播放，将音乐移到下一个
        guard let index = items.firstIndex(of: music) else {
            return .empty()
        }
        items.remove(at: index)
        
        guard let currentIndex = items.firstIndex(of: playingMusic) else {
            return .empty()
        }
        items.insert(music, at: currentIndex + 1)
        
        let api: RCNetworkAPI = .moveMusic(roomId: initialState.roomId, fromId: music.id, toId: playingMusic.id)
        networkProvider.request(api) { result in }
        
        return .just(.setRoomMusic(items: items))
    }
}
