//
//  RCSceneRoomSettingProtocol.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import UIKit

public protocol RCSceneRoomSettingProtocol: AnyObject {
    /// 如果外部需要自定义事件响应，返回 true，默认为 false
    func eventWillTrigger(_ item: Item) -> Bool
    
    /// 事件响应，部分 Item 会在 SDK 内完成事件处理：标题、通知等
    func eventDidTrigger(_ item: Item, extra: String?)
}

extension RCSceneRoomSettingProtocol {
    public func eventWillTrigger(_ item: Item) -> Bool { return false }
    public func eventDidTrigger(_ item: Item, extra: String?) {}
}
