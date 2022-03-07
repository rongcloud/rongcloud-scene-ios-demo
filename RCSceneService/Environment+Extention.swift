//
//  AppEnvironment.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation
import RCSceneFoundation

public extension Environment {
    static var currentUserId: String {
        return UserDefaults.standard.loginUser()?.userId ?? ""
    }

    static var currentUser: User? {
        return UserDefaults.standard.loginUser()
    }
}
