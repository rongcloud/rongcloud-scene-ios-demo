//
//  EditUserReactor.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/1.
//

import Foundation
import ReactorKit

final class EditUserReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        return state
    }
}
