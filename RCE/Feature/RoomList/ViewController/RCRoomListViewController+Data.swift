//
//  RCRoomListViewController+Data.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/14.
//

import UIKit
import RCSceneService
import RCSceneVoiceRoom

private var RCRoomListPageKey = 1

extension RCRoomListViewController {
    private var currentPage: Int {
        get {
            objc_getAssociatedObject(self, &RCRoomListPageKey) as? Int ?? 1
        }
        set {
            objc_setAssociatedObject(self, &RCRoomListPageKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func refreshData(_ completion: @escaping (Result<VoiceRoomList, NetError>) -> Void) {
        currentPage = 1
        let api = RCNetworkAPI.roomlist(type: type, page: currentPage, size: 20)
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            switch result.map(VoiceRoomListWrapper.self) {
            case let .success(wrapper):
                self.currentPage += 1
                if let list = wrapper.data {
                    SceneRoomManager.shared.backgroundlist = list.images
                    completion(.success(list))
                } else {
                    completion(.failure(NetError("加载失败")))
                }
            case let .failure(error):
                completion(.failure(NetError(error.localizedDescription)))
            }
        }
    }
    
    func moreData(_ completion: @escaping (Result<VoiceRoomList, NetError>) -> Void) {
        let api = RCNetworkAPI.roomlist(type: type, page: currentPage, size: 20)
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            switch result.map(VoiceRoomListWrapper.self) {
            case let .success(wrapper):
                self.currentPage += 1
                if let list = wrapper.data {
                    completion(.success(list))
                } else {
                    completion(.failure(NetError("加载失败")))
                }
            case let .failure(error):
                completion(.failure(NetError(error.localizedDescription)))
            }
        }
    }
}

extension RCRoomListViewController: RCRoomContainerDataSource {
    func container(_ controller: RCRoomContainerViewController, refresh completion: @escaping ([VoiceRoom], Bool) -> Void) {
        refreshData { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(list):
                self.items = list.rooms
                if list.totalCount == self.items.count {
                    completion(self.items, true)
                } else {
                    completion(self.items, false)
                }
            case let .failure(error):
                print(error.localizedDescription)
                completion([], false)
            }
        }
    }
    
    func container(_ controller: RCRoomContainerViewController, more completion: @escaping ([VoiceRoom], Bool) -> Void) {
        moreData { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(list):
                self.items.append(contentsOf: list.rooms)
                if list.totalCount == self.items.count {
                    completion(self.items, true)
                } else {
                    completion(self.items, false)
                }
            case let .failure(error):
                print(error.localizedDescription)
                completion([], false)
            }
        }
    }
}
