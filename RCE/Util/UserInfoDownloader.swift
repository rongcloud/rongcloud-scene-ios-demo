//
//  UserInfoDownloader.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/11.
//

import Foundation
import RxSwift

typealias VoiceRoomUserCallback = (VoiceRoomUser) -> Void
final class UserInfoDownloaded {
    static let shared = UserInfoDownloaded()
    
    private let disposeBag = DisposeBag()
    private var downloadingUser = [String: [VoiceRoomUserCallback]]()
    private var cachedUser = [String: VoiceRoomUser]()
    
    func refreshUserInfo(userId: String, completion: @escaping VoiceRoomUserCallback) {
        if let _ = cachedUser[userId] {
            cachedUser.removeValue(forKey: userId)
        }
        networkProvider.rx
            .request(.usersInfo(id: [userId]))
            .filterSuccessfulStatusCodes()
            .map([VoiceRoomUser].self, atKeyPath: "data", using: JSONDecoder(), failsOnEmptyData: true)
            .subscribe { list in
                for user in list {
                    self.cachedUser[user.userId] = user
                    completion(user)
                }
            } onFailure: { error in
                debugPrint(error.localizedDescription)
            } onDisposed: {
                
            }.disposed(by: disposeBag)
    }
    
    func fetchUserInfo(userId: String, completion: @escaping VoiceRoomUserCallback) {
        if let user = cachedUser[userId] {
            completion(user)
            return
        }
        if var completions = downloadingUser[userId] {
            completions.append(completion)
            downloadingUser[userId] = completions
            return
        }
        downloadingUser[userId] = [completion]
        networkProvider.rx
            .request(.usersInfo(id: [userId]))
            .filterSuccessfulStatusCodes()
            .map([VoiceRoomUser].self, atKeyPath: "data", using: JSONDecoder(), failsOnEmptyData: true)
            .subscribe { list in
                for user in list {
                    self.cachedUser[user.userId] = user
                    self.downloadingUser[userId]?.forEach({ completion in
                        completion(user)
                    })
                    self.downloadingUser.removeValue(forKey: userId)
                }
            } onFailure: { error in
                debugPrint(error.localizedDescription)
                self.downloadingUser.removeValue(forKey: userId)
            } onDisposed: {
                self.downloadingUser.removeValue(forKey: userId)
            }.disposed(by: disposeBag)
    }
    
    func fetch(_ userIds: [String], completion: @escaping ([VoiceRoomUser]) -> Void) {
        let users = userIds.compactMap { cachedUser[$0] }
        if users.count == userIds.count {
            return completion(users)
        }
        let ids = userIds.filter { cachedUser[$0] == nil }
        let api = RCNetworkAPI.usersInfo(id: ids)
        networkProvider.request(api) { result in
            switch result.map(VoiceRoomUserWrapper.self) {
            case let .success(wrapper):
                let list = wrapper.data ?? []
                list.forEach { self.cachedUser[$0.userId] = $0 }
                if users.count + list.count == userIds.count {
                    completion(userIds.compactMap { self.cachedUser[$0] })
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateLocalCache(_ user: VoiceRoomUser) {
        cachedUser[user.userId] = user
    }
    
    static func fetch(_ userIds: [String]) -> Single<[VoiceRoomUser]> {
        let api: RCNetworkAPI = .usersInfo(id: userIds)
        return networkProvider.rx.request(api)
            .filterSuccessfulStatusCodes()
            .map([VoiceRoomUser].self, atKeyPath: "data", using: JSONDecoder(), failsOnEmptyData: true)
    }
}
