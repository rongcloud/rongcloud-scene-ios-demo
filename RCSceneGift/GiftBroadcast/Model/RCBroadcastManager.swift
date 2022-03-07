//
//  RCBroadcastManager.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/23.
//

import UIKit
import RCSceneService

fileprivate let kRCBroadcastDuration: TimeInterval = 5

public class RCBroadcastManager: NSObject {
    public static let shared = RCBroadcastManager()
    
    public weak var delegate: RCRTCBroadcastDelegate?
    
    private(set) lazy var messages = [RCGiftBroadcast]() {
        didSet {
            guard
                oldValue.count == 0,
                messages.count > 0,
                currentView == nil
            else { return }
            displayNext()
        }
    }
    public var currentView: RCRTCGiftBroadcastView?
    
    public func add(_ message: RCGiftBroadcastMessage) {
        guard let content = message.content else { return }
        messages.append(content)
    }
    
    private func displayNext() {
        guard messages.count > 0 else { return }
        currentView = RCRTCGiftBroadcastView(messages.removeFirst(), delegate: self)
        currentView?.alpha = 0
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut) {
                currentView?.alpha = 1
            } completion: { _ in }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + kRCBroadcastDuration) { [unowned self] in
            UIView.animate(withDuration: 0.3) {
                currentView?.alpha = 0
            } completion: { _ in
                currentView?.removeFromSuperview()
                currentView = nil
                displayNext()
            }
        }
        delegate?.broadcastViewDidLoad(currentView!)
    }
}

extension RCBroadcastManager: RCRTCBroadcastDelegate {
    public func broadcastViewDidLoad(_ view: RCRTCGiftBroadcastView) {
        delegate?.broadcastViewDidLoad(view)
    }
    
    public func broadcastViewWillAppear(_ view: RCRTCGiftBroadcastView) {
        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
        }
    }
    
    public func broadcastViewAccessible(_ room: VoiceRoom) -> Bool {
        delegate?.broadcastViewAccessible(room) ?? false
    }
    
    public func broadcastViewDidClick(_ room: VoiceRoom) {
        delegate?.broadcastViewDidClick(room)
    }
}
