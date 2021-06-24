//
//  CreateVoiceRoomReactor.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import Foundation
import ReactorKit

enum RoomType {
    case privateRoom
    case publicRoom
}

final class CreateVoiceRoomReacotor: Reactor {
    var initialState: State
    
    init(imagelist: [String]) {
        initialState = State(imagelist: imagelist)
    }
    enum Action {
        case selectThumbImage(UIImage?)
        case inputRoomName(String)
        case selectBackgroundImage(String)
        case selectRoomType(RoomType)
        case createRoom
        case inputPassowrd(String)
    }
    
    enum Mutation {
        case setThumbImage(UIImage?)
        case setRoomName(String)
        case setBacroundImage(String)
        case setRoomType(RoomType)
        case setError(ReactorError)
        case setPassword(String)
        case setSuccess(ReactorSuccess)
        case createRoomSuccess(CreateVoiceRoomWrapper)
        case uploadImage(UploadfileResponse)
        case setShowPassword(Bool)
        case setNeedLogin(Bool)
    }
    
    struct State {
        var uploadResponse: UploadfileResponse?
        var thumbImage: UIImage?
        var bgImageUrl: String?
        var roomName: String = ""
        var password: String?
        var type: RoomType = .privateRoom
        var section: [SelectRoomBackgroundSection]
        var error: ReactorError?
        var success: ReactorSuccess?
        var createdRoom: CreateVoiceRoomWrapper?
        var showPassoword = false
        var needLogin = false
        
        init(imagelist: [String]) {
            section = [SelectRoomBackgroundSection(items: imagelist)]
            bgImageUrl = imagelist.first
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .inputPassowrd(password):
            return Observable.concat([Observable<Mutation>.just(.setPassword(password)), createRoom(password: password)])
        case let .selectThumbImage(image):
            let setImage = Observable<Mutation>.just(.setThumbImage(image))
            if let data = image?.jpegData(compressionQuality: 0.5) {
                let uploadImage = networkProvider.rx.request(.upload(data: data)).filterSuccessfulStatusCodes().asObservable().map(UploadfileResponse.self).flatMap { reponse -> Observable<Mutation> in
                    return Observable<Mutation>.just(.uploadImage(reponse))
                }
                return setImage.concat(uploadImage)
            } else {
                return setImage
            }
        case let .inputRoomName(text):
            return Observable<Mutation>.just(.setRoomName(text))
        case let .selectBackgroundImage(backgroundImage):
            return Observable<Mutation>.just(.setBacroundImage(backgroundImage))
        case let .selectRoomType(type):
            return Observable<Mutation>.just(.setRoomType(type))
        case .createRoom:
            guard !Environment.currentUserId.isEmpty else {
                return Observable<Mutation>.just(.setError(ReactorError("用户信息失效，请重新登录")))
            }
            guard !currentState.roomName.isEmpty else {
                return Observable<Mutation>.just(.setError(ReactorError("请填写房间名称")))
            }
            if currentState.type == .privateRoom, currentState.password == nil {
                return Observable<Mutation>.just(.setShowPassword(true)).concat(Observable<Mutation>.just(.setShowPassword(false)))
            }
            return createRoom(password: nil)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setThumbImage(image):
            state.thumbImage = image
        case let .setRoomName(name):
            state.roomName = name
        case let .setBacroundImage(imageUrl):
            state.bgImageUrl = imageUrl
        case let .setRoomType(type):
            state.type = type
        case let .setSuccess(success):
            state.success = success
        case let .setError(error):
            state.error = error
        case let .createRoomSuccess(voiceRoom):
            state.createdRoom = voiceRoom
        case let .uploadImage(response):
            state.uploadResponse = response
        case let .setShowPassword(isShow):
            state.showPassoword = isShow
        case let .setPassword(password):
            state.password = password
        case let .setNeedLogin(isNeed):
            state.needLogin = isNeed
        }
        return state
    }
    
    private func createRoom(password: String?) -> Observable<Mutation> {
        let seatInfolist = (0..<9).map { _ in RCVoiceSeatInfo() }
        let voiceRoom = RCVoiceRoomInfo()
        voiceRoom.roomName = currentState.roomName
        voiceRoom.seatCount = seatInfolist.count
        let roomKV = voiceRoom.createRoomKV()
        let imageURL = currentState.uploadResponse?.imageURL() ?? ""
        let backgroundUrl = currentState.bgImageUrl ?? ""
        let createRoom = networkProvider.rx.request(.createRoom(name: currentState.roomName, themePictureUrl: imageURL, backgroundUrl: backgroundUrl, kv: [roomKV], isPrivate: (currentState.type == .privateRoom ? 1 : 0), password: password))
            .asObservable()
            .filterSuccessfulStatusCodes()
            .map(CreateVoiceRoomWrapper.self)
            .flatMap { wrapper -> Observable<Mutation> in
                guard let _ = wrapper.data else {
                    if wrapper.needLogin() {
                        return Observable<Mutation>.just(.setNeedLogin(true))
                    } else {
                        return Observable<Mutation>.just(.setError(ReactorError("创建失败，请稍后重试")))
                    }
                }
                if wrapper.isCreated() {
                    return Observable<Mutation>.just(.createRoomSuccess(wrapper))
                }
                return Observable<Mutation>.just(.setSuccess(ReactorSuccess("创建成功"))).concat(Observable<Mutation>.just(.createRoomSuccess(wrapper)))
            }.catch { error in
                debugPrint(error.localizedDescription)
                return Observable.just(.setError(ReactorError("创建失败，请稍后重试")))
            }
        return createRoom
    }
}
