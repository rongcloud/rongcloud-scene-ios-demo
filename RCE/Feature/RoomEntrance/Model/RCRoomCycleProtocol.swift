//
//  RCRoomCycleProtocol.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/24.
//

import Foundation

protocol RCRoomCycleProtocol where Self: UIViewController {
    func joinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void)
    func leaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void)
    func descendantViews() -> [UIView]
}

extension RCRoomCycleProtocol {
    func joinRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {}
    func leaveRoom(_ completion: @escaping (Result<Void, ReactorError>) -> Void) {}
    func descendantViews() -> [UIView] { [] }
}
