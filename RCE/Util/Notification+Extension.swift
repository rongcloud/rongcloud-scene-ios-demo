//
//  Notification+Extension.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/3.
//

import Foundation

let NotificationNameLogin = Notification.Name("NotificationNameLogin")
let NotificationNameLogout = Notification.Name("NotificationNameLogout")
let NotificationNameUserInfoUpdated = Notification.Name("NotificationNameUserInfoUpdated")
let NotificationNameRoomBackgroundUpdated = Notification.Name("NotificationNameRoomBackgroundUpdated")

extension Notification.Name {
    func addObserver(_ observer: Any,
                     selector aSelector: Selector,
                     object anObject: Any? = nil) {
        NotificationCenter.default.addObserver(observer,
                                               selector: aSelector,
                                               name: self,
                                               object: anObject)
    }
    
    func post(_ object: Any? = nil) {
        NotificationCenter.default.post(name: self, object: object)
    }
}
