//
//  DialKeyboardReactor.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/30.
//

import Foundation
import ReactorKit

final class DialKeyboardReactor: Reactor {
    enum Action {
        case selectKeyboard(item: DialKeyboardAction)
        case deleteItem
        case dial
    }
    
    enum Mutation {
        case setSelectItem(item: DialKeyboardAction)
        case deleteLast
        case startCalling
    }
    
    struct State {
        var beginCalling = false
        var inputNumber: String = ""
        var sections: [DialKeyboardSection] = [DialKeyboardSection(items: DialKeyboardAction.dialItems())]
    }
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .selectKeyboard(item):
            return Observable<Mutation>.just(.setSelectItem(item: item))
        case .deleteItem:
            return .just(.deleteLast)
        case .dial:
            return .just(.startCalling)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setSelectItem(item):
            switch item {
            case let .character(value):
                state.inputNumber.append(value)
            case let .number(number):
                state.inputNumber.append("\(number)")
            }
        case .deleteLast:
            if !state.inputNumber.isEmpty {
                state.inputNumber.removeLast()
            }
        case .startCalling:
            state.beginCalling = true
        }
        return state
    }
}
