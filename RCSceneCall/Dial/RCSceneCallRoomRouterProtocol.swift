//
//  RCSceneCallRoomRouterProtocol.swift
//  RCSceneCall
//
//  Created by xuefeng on 2022/2/23.
//

import Foundation

public var callRouter: RCSceneCallRoomRouterProtocol?

public protocol RCSceneCallRoomRouterProtocol {
    func feedback()
}

public extension RCSceneCallRoomRouterProtocol {
    func feedback() {}
}
