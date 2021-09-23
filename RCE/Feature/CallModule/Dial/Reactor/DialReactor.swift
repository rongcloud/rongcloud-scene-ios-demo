//
//  DialReactor.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/30.
//

import Foundation
import ReactorKit

final class DialReactor: Reactor {
    enum Action {
        case callNumber(phone: String)
        case inputPhone(value: String)
        case callHistory(history: DialHistory)
    }
    
    enum Mutation {
        case setCallingUser(DialUser?)
        case setError(ReactorError)
        case setHudShow(Bool)
        case filterDataSource(value: String)
        case setInvite(Bool)
    }
    
    struct State {
        var shouldInvite = false
        var hudShowing = false
        var callingUid: String?
        var sections: [DialSection]
        var error: ReactorError?
        
        init() {
            let historyItems = UserDefaults.standard.historyList()
            sections = [.historySection(items: historyItems)]
        }
    }
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .callNumber(phone):
            guard phone.count == 11 else {
                return .just(.setError(ReactorError("请输入正确的手机号码")))
            }
            let beginHud = Observable<Mutation>.just(.setHudShow(true))
            let endHud = Observable<Mutation>.just(.setHudShow(false))
            let request = networkProvider.rx
                .request(.getUserInfo(phone: phone))
                .filterSuccessfulStatusCodes()
                .asObservable()
                .map(DialUser.self, atKeyPath: "data")
                .flatMap { user -> Observable<Mutation> in
                    if user.uid == Environment.currentUserId {
                        return .just(.setError(ReactorError("不能给自己拨号")))
                    }
                    return .just(.setCallingUser(user)).concat(endHud)
                }
                .catchAndReturn(.setInvite(true))
            let clearUid = Observable<Mutation>.just(.setCallingUser(nil))
            return Observable.concat([beginHud, request, clearUid])
        case let .inputPhone(phone):
            return Observable<Mutation>.just(.filterDataSource(value: phone)).concat(Observable<Mutation>.just(.setInvite(false)))
        case let .callHistory(history):
            let historyCall: Observable<Mutation> = .just(.setCallingUser(history.user))
            let clearUid: Observable<Mutation> = .just(.setCallingUser(nil))
            return .concat([historyCall, clearUid])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setCallingUser(user):
            state.callingUid = user?.uid
            updateHistory(user, state: &state)
        case let .setError(error):
            state.error = error
        case let .setHudShow(isShowing):
            state.hudShowing = isShowing
        case let .filterDataSource(value):
            print(value)
        case let .setInvite(isInvite):
            if isInvite {
                state.hudShowing = false
            }
            state.shouldInvite = isInvite
        }
        return state
    }
    
    private func updateHistory(_ user: DialUser?, state: inout State) {
        guard let user = user else { return }
        let history = DialHistory(userId: user.uid,
                                  avatar: user.portrait,
                                  date: Date(),
                                  number: user.mobile)
        UserDefaults.standard.appendDial(history)
        let historyItems = UserDefaults.standard.historyList()
        state.sections = [
            .historySection(items: historyItems)
        ]
    }
}
