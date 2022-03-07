//
//  User.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/21.
//

import Foundation
import RCSceneFoundation
import MapKit

public struct User: Identifiable, Codable {
    public let userId: String
    public let userName: String
    public let portrait: String?
    public var imToken: String
    public let authorization: String
    public let type: Int

    public init(userId: String,
                userName: String,
                portrait: String?,
                imToken: String,
                authorization: String,
                type: Int) {
        self.userId = userId
        self.userName = userName
        self.portrait = portrait
        self.imToken = imToken
        self.authorization = authorization
        self.type = type
    }
    
    public func update(name: String, portrait: String) -> User {
        return User(userId: userId,
                    userName: name,
                    portrait: portrait,
                    imToken: imToken,
                    authorization: authorization,
                    type: type)
    }
    
    public var id: String {
        return userId
    }
    public var portraitUrl: String {
        return Environment.current.url.absoluteString + "file/show?path=" + (portrait ?? "")
    }
}

public extension UserDefaults {
    func loginUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: RCLoginUserKey) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func set(user: User?) {
        guard let data = try? JSONEncoder().encode(user) else {
            return
        }
        UserDefaults.standard.setValue(data, forKey: RCLoginUserKey)
    }
 }


public struct VoiceRoomUserWrapper: Codable {
    let code: Int
    public let data: [VoiceRoomUser]?
}

public struct VoiceRoomUser: Codable, Equatable {
    public let userId: String
    public let userName: String
    public let portrait: String?
    public let status: Int?
    
    public var portraitUrl: String {
        if let portrait = portrait, portrait.count > 0 {
            
            return Environment.current.url.absoluteString + "file/show?path=" + portrait
        }
        return "https://cdn.ronghub.com/demo/default/rce_default_avatar.png"
    }
    
    public var isFollow: Bool {
        return status == 1
    }
    
    public var relation: Int?
    public mutating func set(_ relation: Int) {
        self.relation = relation
    }
    
    public init(userId: String,
                userName: String,
                portrait: String?,
                status: Int?) {
        self.userId = userId
        self.userName = userName
        self.portrait = portrait
        self.status = status
    }
}
