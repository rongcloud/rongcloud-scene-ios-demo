//
//  DialReactor.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/30.
//

import Foundation
import ReactorKit
import RCSceneService
import RCSceneFoundation

final public class DialReactor: Reactor {
    public enum Action {
        case callNumber(phone: String)
        case inputPhone(value: String)
        case callHistory(history: DialHistory)
    }
    
    public enum Mutation {
        case setCallingUser(DialUser?)
        case setError(ReactorError)
        case setHudShow(Bool)
        case filterDataSource(value: String)
        case setInvite(Bool)
    }
    
    public struct State {
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
    public func verification(phone: String) -> Bool {
        Environment.current == .overseas ? phone.count >= 6 : phone.count == 11
    }
    
    public var initialState: State = State()
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .callNumber(phone):
            guard verification(phone: phone) else {
                return .just(.setError(ReactorError("手机号码格式不正确")))
            }
            let beginHud = Observable<Mutation>.just(.setHudShow(true))
            let endHud = Observable<Mutation>.just(.setHudShow(false))
            let request = userProvider.rx
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
    
    public func reduce(state: State, mutation: Mutation) -> State {
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
