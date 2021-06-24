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
