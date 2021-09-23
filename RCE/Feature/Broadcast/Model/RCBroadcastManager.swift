//
//  RCBroadcastManager.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/23.
//

import Foundation

fileprivate let kRCBroadcastDuraion: TimeInterval = 5

class RCBroadcastManager: NSObject {
    static let shared = RCBroadcastManager()
    
    weak var delegate: RCRTCBroadcastDelegate?
    
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
    private var currentView: RCRTCGiftBroadcastView?
    
    func add(_ message: RCGiftBroadcastMessage) {
        guard let content = message.content else { return }
        messages.append(content)
    }
    
    private func displayNext() {
        guard messages.count > 0 else { return }
        currentView = RCRTCGiftBroadcastView(messages.removeFirst(), delegate: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + kRCBroadcastDuraion) { [unowned self] in
            UIView.animate(withDuration: 0.3, animations: {
                currentView?.alpha = 0
            }, completion: { _ in
                currentView?.removeFromSuperview()
                currentView = nil
                displayNext()
            })
        }
        delegate?.broadcastViewDidLoad(currentView!)
    }
}

extension RCBroadcastManager: RCRTCBroadcastDelegate {
    func broadcastViewDidLoad(_ view: RCRTCGiftBroadcastView) {
        delegate?.broadcastViewDidLoad(view)
    }
    
    func broadcastViewWillAppear(_ view: RCRTCGiftBroadcastView) {
        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
        }
    }
    
    func broadcastViewAccessible(_ room: VoiceRoom) -> Bool {
        delegate?.broadcastViewAccessible(room) ?? false
    }
    
    func broadcastViewDidClick(_ room: VoiceRoom) {
        delegate?.broadcastViewDidClick(room)
    }
}
