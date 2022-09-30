//
//  UserInfoDownloader.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/11.
//

import Foundation
import RxSwift

import RCSceneVoiceRoom

extension RCSceneUserManager {
    static func fetch(_ userIds: [String]) -> Single<[RCSceneRoomUser]> {
        let api: RCUserService = .usersInfo(id: userIds)
        return userProvider.rx.request(api)
            .filterSuccessfulStatusCodes()
            .map([RCSceneRoomUser].self, atKeyPath: "data", using: JSONDecoder(), failsOnEmptyData: true)
    }
}
