//
//  RCNetworkLiveAPI.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/1.
//

import Moya

let RCLiveAPIProvider = MoyaProvider<RCNetworkAPI>(plugins: networkPlugins)

enum RCLiveAPI {
    case roomList
}

class RCLive: RCTargetType {
    override var path: String {
        return super.path
    }
}

class RCLiveProvider: MoyaProvider<RCLive> {
    
}
