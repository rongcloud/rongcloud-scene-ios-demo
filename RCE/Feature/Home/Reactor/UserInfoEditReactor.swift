//
//  UserInfoEditReactor.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/2.
//

import ReactorKit

enum UserInfoEditNetworkState {
    case idle
    case request
    case success(VoiceRoomUser)
    case failure(ReactorError)
}

final class UserInfoEditReactor: Reactor {
    var initialState: State
    
    init(_ userId: String) {
        initialState = State(userId: userId)
    }
    
    enum Action {
        case fetch
        case update
        case header(UIImage?)
        case name(String?)
    }
    
    enum Mutation {
        case setUser(VoiceRoomUser)
        case setHeader(UIImage?)
        case setName(String?)
        case setUpdateState(UserInfoEditNetworkState)
    }
    
    struct State {
        let userId: String
        var user: VoiceRoomUser?
        var header: UIImage?
        var name: String?
        var updateState: UserInfoEditNetworkState = .idle
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return UserInfoDownloaded
                .fetch([initialState.userId])
                .asObservable()
                .compactMap { $0.first }
                .flatMap { user -> Observable<Mutation> in
                    return .just(.setUser(user))
                }
        case .update:
            let begin = Observable<Mutation>.just(.setUpdateState(.request))
            let task = update()
            let end = Observable<Mutation>.just(.setUpdateState(.idle))
            return .concat([begin, task, end])
        case let .header(image): return .just(.setHeader(image))
        case let .name(name): return .just(.setName(name))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setUser(user):
            state.user = user
            state.name = user.userName
        case let .setHeader(image): state.header = image
        case let .setName(name): state.name = name
        case let .setUpdateState(next):
            state.updateState = next
            if case let .success(user) = next {
                state.user = user
            }
        }
        return state
    }
}

extension UserInfoEditReactor {
    private func update() -> Observable<Mutation> {
        if currentState.header == nil, currentState.name == initialState.name {
            return .empty()
        }
        return Observable<Mutation>.create { [weak self] observable -> Disposable in
            guard let self = self else { return Disposables.create() }
            let userId = self.initialState.userId
            let name = self.currentState.name
            let portrait = self.currentState.user?.portrait
            
            func upload(_ image: UIImage?, completion: @escaping (Result<String?, ReactorError>) -> Void) {
                guard
                    let image = self.currentState.header, let data = image.jpegData(compressionQuality: 0.5)
                else {
                    return completion(.success(portrait))
                }
                networkProvider.request(.upload(data: data)) { result in
                    switch result {
                    case let .success(response):
                        guard
                            let res = try? JSONDecoder().decode(UploadfileResponse.self, from: response.data)
                        else {
                            completion(.failure(ReactorError("图片上传失败")))
                            return
                        }
                        completion(.success(res.data))
                    case let .failure(error):
                        completion(.failure(ReactorError(error.localizedDescription)))
                    }
                }
            }

            func update(_ name: String?, _ portrait: String?, completion: @escaping (Result<VoiceRoomUser, ReactorError>) -> Void) {
                guard let name = name, name.count > 0 else {
                    return completion(.failure(ReactorError("请输入姓名")))
                }
                let portrait = portrait ?? ""
                networkProvider.request(.updateUserInfo(userName: name, portrait: portrait)) { result in
                    switch result {
                    case let .success(response):
                        guard let res = try? JSONDecoder().decode(AppResponse.self, from: response.data) else {
                            completion(.failure(ReactorError("更新失败")))
                            return
                        }
                        
                        if (!res.validate()) {
                            return completion(.failure(ReactorError(res.msg ?? "更新失败")))
                        }
                        
                        let user = VoiceRoomUser(userId: userId, userName: name, portrait: portrait, status: 0)
                        completion(.success(user))
                    case let .failure(error):
                        completion(.failure(ReactorError(error.localizedDescription)))
                    }
                }
            }
            
            upload(self.currentState.header) { result in
                switch result {
                case let .success(portrait):
                    update(name, portrait) { result in
                        switch result {
                        case let .success(user):
                            observable.onNext(.setUpdateState(.success(user)))
                        case let .failure(error):
                            observable.onNext(.setUpdateState(.failure(error)))
                        }
                        observable.onCompleted()
                    }
                case let .failure(error):
                    observable.onNext(.setUpdateState(.failure(error)))
                }
            }
            
            return Disposables.create()
        }
    }
}
