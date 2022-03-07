//
//  LiveVideoViewModel.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/8.
//

import UIKit
import RCSceneService

let roomThumbNames = [
    "room_background_image1",
    "room_background_image2",
    "room_background_image3",
    "room_background_image4",
    "room_background_image5",
    "room_background_image6"
]

struct CreateLiveVideoRoomState {
    var isPrivate = true
    var password = ""
    var roomName = ""
    var roomThumbImage: UIImage?
    
    var needInputPassword: Bool {
        return isPrivate && password.count == 0
    }
}

final class LiveVideoViewModel {
    var createState = CreateLiveVideoRoomState()
    
    func create(_ completion: @escaping (Result<RCNetworkWapper<VoiceRoom>, NetError>) -> Void) {
        guard createState.roomName.count > 0 else {
            return completion(.failure(NetError("请输入房间名称")))
        }
        guard let image = createState.roomThumbImage else {
            return completion(.failure(NetError("请选择房间图标")))
        }
        if createState.needInputPassword {
            return completion(.failure(NetError("请输入密码")))
        }
        
        let name = createState.roomName
        let isPrivate = createState.isPrivate ? 1 : 0
        let password = createState.password
        upload(image) { [weak self] result in
            switch result {
            case let .success(path):
                self?.create(name,
                       isPrivate: isPrivate,
                       password: password,
                       path: path,
                       completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func upload(_ image: UIImage, completion: @escaping (Result<String, NetError>) -> Void) {
        videoRoomService.upload(data: image.jpegData(compressionQuality: 0.5)!) { result in
            switch result.map(UploadfileResponse.self) {
            case let .success(response):
                completion(.success(response.imageURL()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func create(_ name: String,
                        isPrivate: Int,
                        password: String,
                        path: String,
                        completion: @escaping (Result<RCNetworkWapper<VoiceRoom>, NetError>) -> Void) {
        videoRoomService.createRoom(name: name, themePictureUrl: path, backgroundUrl: "", kv: [], isPrivate: isPrivate, password: password, roomType: 3) { result in
            switch result.map(RCNetworkWapper<VoiceRoom>.self) {
            case let .success(wrapper):
                completion(.success(wrapper))
            case let .failure(error):
                completion(.failure(NetError(error.localizedDescription)))
            }
        }
    }
}
