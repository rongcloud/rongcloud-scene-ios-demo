//
//  VoiceRoomMusicListReactor.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import Foundation
import ReactorKit

enum MusicNotification: String {
    case appendNewMusic = "appendNewMusic"
    case deleteMusic = "deleteMusic"
}

final class VoiceRoomMusicListReactor: Reactor {
    enum Action {
        case refresh
        case append(VoiceRoomMusic)
        case addLocalMusic([VoiceRoomLocalMusic])
    }
    
    enum Mutation {
        case setMusicItems(items: [VoiceRoomMusic])
        case setRoomMusic(items: [VoiceRoomMusic])
        case setSuccess(ReactorSuccess)
        case setError(ReactorError)
        case setNetState(RCNetworkState)
        case setAppendingState(Bool)
        case setChannels(items: [MusicChannel])
    }
    
    struct State {
        var roomId: String
        var musicType: Int = 0
        var items = [VoiceRoomMusic]()
        var addedItems = [VoiceRoomMusic]()
        var sections = [VoiceRoomMusicSection]()
        var success: ReactorSuccess?
        var error: ReactorError?
        var netState = RCNetworkState.idle
        var isAppendingMusic = false
        var channelSections = [MusicChannelSection]()
    }
    private let service = VoiceRoomMusicService()
    var initialState: State
    
    init(roomId: String) {
        initialState = State(roomId: roomId)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            let channelList = service.channelSheetList(groupId: "w06k2pe634")
                .flatMapLatest { channels -> Observable<Mutation> in
                    if let channel = channels.first {
                        let setChannels = Observable<Mutation>.just(.setChannels(items: channels))
                        let musiclist = self.service.musicList(sheetId: channel.sheetId).flatMap { musicRecords -> Observable<Mutation> in
                            let musicItems = musicRecords.map {
                                return VoiceRoomMusic(id: $0.musicId.intValue, name: $0.musicName, author: $0.artist.first?.name ?? "", roomId: "", type: 2, url: nil, size: "")
                            }
                            return Observable<Mutation>.just(.setMusicItems(items: musicItems))
                        }
                        return setChannels.concat(musiclist)
                    } else {
                        return .empty()
                    }
                }
            let musiclist = networkProvider.rx
                .request(.musiclist(roomId: currentState.roomId, type: 0))
                .asObservable()
                .filterSuccessfulStatusCodes()
                .map([VoiceRoomMusic].self, atKeyPath: "data")
                .flatMapLatest { items -> Observable<Mutation> in
                    return Observable<Mutation>.just(.setMusicItems(items: items))
                }
                .catchAndReturn(.setMusicItems(items: []))
            let roomMusiclist = networkProvider.rx
                .request(.musiclist(roomId: currentState.roomId, type: 1))
                .asObservable()
                .filterSuccessfulStatusCodes()
                .map([VoiceRoomMusic].self, atKeyPath: "data")
                .flatMapLatest { items -> Observable<Mutation> in
                    return Observable<Mutation>.just(.setRoomMusic(items: items))
                }
                .catchAndReturn(.setRoomMusic(items: []))
            return musiclist.concat(roomMusiclist).concat(channelList)
        case let .append(item):
            guard !currentState.isAppendingMusic else {
                return .empty()
            }
            let roomMusiclist = networkProvider.rx
                .request(.musiclist(roomId: currentState.roomId, type: 1))
                .asObservable()
                .filterSuccessfulStatusCodes()
                .map([VoiceRoomMusic].self, atKeyPath: "data")
                .flatMapLatest { items -> Observable<Mutation> in
                    return Observable<Mutation>.just(.setRoomMusic(items: items))
                }
                .catchAndReturn(.setRoomMusic(items: []))
            let addMusic = service.musicUrl(musicId: "\(item.id)").flatMapLatest { [weak self] musicUrl -> Observable<Mutation> in
                guard let self = self else { return .empty()}
                return networkProvider.rx.request(.addMusic(roomId: self.currentState.roomId, musicName: item.name, author: item.author, type: 2, url: musicUrl, size: 0)).asObservable().filterSuccessfulStatusCodes().map(AppResponse.self).flatMap {
                    _ -> Observable<Mutation> in
                    return .just(.setSuccess(ReactorSuccess("添加成功"))).do { _ in
                        let notification = Notification.Name(rawValue: MusicNotification.appendNewMusic.rawValue)
                        NotificationCenter.default.post(name: notification, object: nil)
                    }
                }
            }.catchAndReturn(.setError(ReactorError("添加失败")))
            let beginAppending = Observable<Mutation>.just(.setAppendingState(true))
            let downloadMusic = MusicDownloader.shared.downloadMusic(item).flatMap { isSuccess -> Observable<Mutation> in
                if isSuccess {
                    return addMusic.concat(roomMusiclist)
                } else {
                    return Observable<Mutation>.just(.setError(ReactorError("添加失败")))
                }
            }
            let endAppending = Observable<Mutation>.just(.setAppendingState(false))
            return Observable.concat([beginAppending, downloadMusic, endAppending])
        case let .addLocalMusic(musics):
            let begin = Observable<Mutation>.just(.setNetState(.begin))
            let request = addLocalMusic(musics)
                .do(onNext: { _ in
                    let notification = Notification.Name(rawValue: MusicNotification.appendNewMusic.rawValue)
                    NotificationCenter.default.post(name: notification, object: nil)
                })
            let end = Observable<Mutation>.just(.setNetState(.idle))
            return .concat([begin, request, end])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setMusicItems(items):
            state.items = items
        case .setRoomMusic(items: let items):
            state.addedItems = items
            state.sections = [VoiceRoomMusicSection(items: state.items.map {
                let musicState = state.addedItems.contains($0) ? MusicListState.added : MusicListState.notAdd
                return VoiceRoomMusicItem(music: $0, state: musicState)
            })]
        case let .setSuccess(success):
            state.success = success
        case let .setError(error):
            state.error = error
        case let .setNetState(netState):
            state.netState = netState
        case let .setAppendingState(isAppend):
            state.isAppendingMusic = isAppend
        case .setChannels(items: let items):
            state.channelSections = [MusicChannelSection(items: items)]
        }
        return state
    }
}

extension VoiceRoomMusicListReactor {
    private func addLocalMusic(_ musics: [VoiceRoomLocalMusic]) -> Observable<Mutation> {
        var tempMusics = [VoiceRoomLocalMusic]()
        guard musics.count > 0 else { return .just(.setNetState(.failure(ReactorError("上传失败")))) }
        let roomId = initialState.roomId
        return Observable<[VoiceRoomLocalMusic]>.create { observer -> Disposable in
            var left = musics.count
            for var music in musics {
                let data = try! Data(contentsOf: URL(fileURLWithPath: music.filePath))
                networkProvider
                    .request(.uploadAudio(data: data)) { result in
                        switch result {
                        case let .success(response):
                            guard
                                let model = try? JSONDecoder().decode(UploadfileResponse.self, from: response.data)
                            else { return }
                            let urlString = Environment.current.url.absoluteString + "/file/show?path=" + model.data
                            music.setUrl(urlString)
                            tempMusics.append(music)
                        case let .failure(error):
                            print(error)
                        }
                        left -= 1
                        if left <= 0 {
                            observer.onNext(tempMusics)
                            observer.onCompleted()
                        }
                    }
            }
            return Disposables.create()
        }
        .flatMapLatest { musics -> Observable<Mutation> in
            guard musics.count > 0 else { return .just(.setNetState(.failure(ReactorError("上传失败")))) }
            return Observable<Mutation>.create { observer -> Disposable in
                var hasFailed = false
                var left = musics.count {
                    didSet {
                        guard left == 0 else {
                            return
                        }
                        if hasFailed {
                            observer.onNext(.setNetState(.failure(ReactorError("添加失败"))))
                        } else {
                            observer.onNext(.setNetState(.success))
                        }
                        observer.onCompleted()
                    }
                }
                for music in musics {
                    let api: RCNetworkAPI = .addMusic(roomId: roomId,
                                                      musicName: music.name,
                                                      author: music.author,
                                                      type: 1,
                                                      url: music.url,
                                                      size: music.size)
                    networkProvider.request(api) { result in
                        if case .failure = result {
                            hasFailed = true
                        }
                        left -= 1
                    }
                }
                return Disposables.create()
            }
        }
    }
}
