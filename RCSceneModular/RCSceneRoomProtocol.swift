//
//  RCSceneModulorProtocol.swift
//  RCSceneModular
//
//  Created by shaoshuai on 2022/2/26.
//

import Foundation

public protocol InputPasswordProtocol: AnyObject {
    func passwordDidEnter(password: String)
    func passwordDidVerify(_ room: VoiceRoom) //room: VoiceRoom
}

public extension InputPasswordProtocol {
    func passwordDidEnter(password: String) {}
    func passwordDidVerify(_ room: VoiceRoom) {}
}

public protocol RCRoomCycleProtocol where Self: UIViewController {
    /// 加入房间
    func joinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void)
    /// 离开房间
    func leaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void)
    
    /// 禁用滚动事件的视图
    func descendantViews() -> [UIView]
    
    /// 设置房间容器事件
    func setRoomContainerAction(action: RCRoomContainerAction)
    
    /// 设置浮窗容器事件
    func setRoomFloatingAction(action: RCSceneRoomFloatingProtocol)
}

extension RCRoomCycleProtocol {
    public func joinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {}
    public func leaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {}
    public func descendantViews() -> [UIView] { [] }
    public func setRoomContainerAction(action: RCRoomContainerAction) {}
    public func setRoomFloatingAction(action: RCSceneRoomFloatingProtocol) {}
}

public protocol RCRoomContainerAction where Self: UIViewController {
    /// 打开滚动功能
    func enableSwitchRoom()
    /// 关闭滚动功能
    func disableSwitchRoom()
    /// 切换房间
    func switchRoom(_ room: VoiceRoom)
}

public protocol RCSceneRoomFloatingProtocol {
    var currentRoomId: String? { get }
    var showing: Bool { get }
    
    func show(_ controller: UIViewController, superView: UIView? ,animated: Bool)
    func hide()
    
    func setSpeakingState(isSpeaking: Bool)
}
