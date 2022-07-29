//
//  RCGameRoomListViewController+Data.swift
//  RCE
//
//  Created by haoxiaoqing on 2022/5/14.
//

import UIKit
import RCSceneRoom
import SVProgressHUD

private var RCRoomListPageKey = 1

struct GameRoomList: Codable {
    let totalCount: Int
    let rooms: [RCSceneRoom]
    let images: [String]
}

extension RCGameRoomListViewController {
    func getGameList(_ completion: @escaping (Result<[RCSceneGameResp], NetError>) -> Void) {
        gameRoomProvider.request(.gameList) { result in
            switch result.map(RCSceneWrapper<[RCSceneGameResp]>.self) {
            case let .success(wrapper):
                if let list = wrapper.data {
                    completion(.success(list))
                } else {
                    completion(.failure(NetError("游戏列表获取失败")))
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    
    private var currentPage: Int {
        get {
            objc_getAssociatedObject(self, &RCRoomListPageKey) as? Int ?? 1
        }
        set {
            objc_setAssociatedObject(self, &RCRoomListPageKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func refreshData(_ completion: @escaping (Result<GameRoomList, NetError>) -> Void) {
        currentPage = 1
        var sex: String = ""
        if gender == "男" {
            sex = "1"
        } else if gender == "女" {
            sex = "2"
        }
        let api = RCNetworkAPI.gameroomlist(type: type, page: currentPage, size: 20, sex: sex, gameId: gameId)
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            
            switch result.map(RCSceneWrapper<GameRoomList>.self) {
            case let .success(wrapper):
                self.currentPage += 1
                if let list = wrapper.data {
                    SceneRoomManager.shared.backgrounds = list.images
                    completion(.success(list))
                } else {
                    completion(.failure(NetError("加载失败")))
                }
            case let .failure(error):
                completion(.failure(NetError(error.localizedDescription)))
            }
        }
    }
    
    func moreData(_ completion: @escaping (Result<GameRoomList, NetError>) -> Void) {
        var sex: String = ""
        if gender == "男" {
            sex = "1"
        } else if gender == "女" {
            sex = "2"
        }
        let api = RCNetworkAPI.gameroomlist(type: type, page: currentPage, size: 20, sex: sex, gameId: gameId)
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            switch result.map(RCSceneWrapper<GameRoomList>.self) {
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
