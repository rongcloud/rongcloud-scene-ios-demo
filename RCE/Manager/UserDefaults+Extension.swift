//
//  UserDefaults+Extension.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/28.
//

import Foundation

private let RCRongCloudTokenKey = "RCRongCloudTokenKey"
private let RCAuthorizationKey = "RCAuthorizationKey"
private let RCLoginUserKey = "RCLoginUserKey"
extension UserDefaults {
    func rongToken() -> String? {
        return UserDefaults.standard.string(forKey: RCRongCloudTokenKey)
    }
    
    func loginUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: RCLoginUserKey) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: data)
    }
    
    func authorizationKey() -> String? {
        return UserDefaults.standard.string(forKey: RCAuthorizationKey)
    }
    
    func set(authorization: String) {
        UserDefaults.standard.setValue(authorization, forKey: RCAuthorizationKey)
    }
    
    func set(rongCloudToken: String) {
        UserDefaults.standard.setValue(rongCloudToken, forKey: RCRongCloudTokenKey)
    }
    
    func set(user: User?) {
        guard let data = try? JSONEncoder().encode(user) else {
            return
        }
        UserDefaults.standard.setValue(data, forKey: RCLoginUserKey)
    }
    
    func clearLoginStatus() {
        UserDefaults.standard.removeObject(forKey: RCAuthorizationKey)
        UserDefaults.standard.removeObject(forKey: RCRongCloudTokenKey)
        UserDefaults.standard.removeObject(forKey: RCLoginUserKey)
    }
}
