//
//  UserInfoDownloader.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/11.
//

import Foundation
import RxSwift
import RCSceneService
import RCSceneVoiceRoom

extension UserInfoDownloaded {
    static func fetch(_ userIds: [String]) -> Single<[VoiceRoomUser]> {
        let api: RCUserService = .usersInfo(id: userIds)
        return userProvider.rx.request(api)
            .filterSuccessfulStatusCodes()
            .map([VoiceRoomUser].self, atKeyPath: "data", using: JSONDecoder(), failsOnEmptyData: true)
    }
}
