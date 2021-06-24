//
//  RoomListReactor.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/28.
//

import Foundation
import ReactorKit
import MJRefresh

final class VoiceRoomListReactor: Reactor {
    var initialState: State = State()
    enum Action {
        case refresh
        case loadMore
    }
    
    enum Mutation {
        case setRefresh(Bool)
        case setLoadMore(MJRefreshState)
        case setRoomlist(VoiceRoomList)
        case appendRoomList(VoiceRoomList)
        case setError(ReactorError)
        case setSuccess(ReactorSuccess)
        case setCreateRoom(VoiceRoom)
    }
    
    struct State {
        var isRefreshing: Bool = false
        var loadMoreState: MJRefreshState = .idle
        var section = [VoiceRoomSection]()
        var images = [String]()
        var page = 1
        var error: ReactorError?
        var success: ReactorSuccess?
        var createdRoom: VoiceRoom?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            guard !currentState.isRefreshing, currentState.loadMoreState != .refreshing else {
                return .empty()
            }
            let beginRefresh = Observable<Mutation>.just(.setRefresh(true))
            let endRefresh = Observable<Mutation>.just(.setRefresh(false))
            let getRoomList = fetchRoomList(paging: .refresh)
            return Observable.concat([beginRefresh, getRoomList, endRefresh]).catchAndReturn(.setRefresh(false))
        case .loadMore:
            guard !currentState.isRefreshing, currentState.loadMoreState != .refreshing  else {
                return .empty()
            }
            let beginPulling = Observable<Mutation>.just(.setLoadMore(.refreshing))
            let endPulling = Observable<Mutation>.just(.setLoadMore(.idle))
            let getRoomList = fetchRoomList(paging: .loadMore)
            return beginPulling.concat(getRoomList).concat(endPulling).catchAndReturn(.setLoadMore(.idle))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setRefresh(refresh):
            state.page = 1
            state.isRefreshing = refresh
        case let .setRoomlist(roomlist):
            state.section = [VoiceRoomSection(items: roomlist.rooms)]
            state.images = roomlist.images
            VoiceRoomSharedContext.shared.backgroundlist = roomlist.images
        case let .setError(error):
            state.error = error
        case let .setCreateRoom(room):
            state.createdRoom = room
        case let .setSuccess(success):
            state.success = success
        case let .setLoadMore(loadMoreState):
            state.loadMoreState = loadMoreState
        case let .appendRoomList(roomlist):
            let items = (state.section.first?.items ?? []) + roomlist.rooms
            state.section = [VoiceRoomSection(items: items)]
            state.page += 1
        }
        return state
    }
    
    private func fetchRoomList(paging: Paging) -> Observable<Mutation> {
        let page: Int = {
            switch paging {
            case .refresh:
                return 1
            default:
                return currentState.page + 1
            }
        }()
        let getRoomList = networkProvider.rx
            .request(.roomlist(page: page, size: 20))
            .filterSuccessfulStatusCodes()
            .asObservable()
            .map(VoiceRoomListWrapper.self)
            .flatMap { wrapper -> Observable<Mutation> in
                if wrapper.code == 10000, let list = wrapper.data {
                    if paging == .refresh {
                        return Observable<Mutation>.just(.setRoomlist(list))
                    } else {
                        return Observable<Mutation>.just(.appendRoomList(list))
                    }
                } else {
                    return Observable<Mutation>.just(.setError(ReactorError("获取列表失败，请稍后重试")))
                }
            }.catchAndReturn(.setError(ReactorError("网络请求错误")))
        return getRoomList
    }
}
