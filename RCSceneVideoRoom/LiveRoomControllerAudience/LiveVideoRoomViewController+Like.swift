//
//  LiveVideoRoomViewController+Like.swift
//  RCE
//
//  Created by shaoshuai on 2021/10/8.
//

import Foundation
import RCSceneMessage

fileprivate final class RCLikeTapGesture: UITapGestureRecognizer, UIGestureRecognizerDelegate {
    private let descendantViews: [UIView]
    private var lastTapTime: TimeInterval = 0
    var tapInterval: TimeInterval = 0.25
    
    init(target: Any?, action: Selector?, descendant views: [UIView]) {
        self.descendantViews = views
        super.init(target: target, action: action)
        delegate = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchView = touch.view else {
            return false
        }
        if descendantViews.contains(where: { touchView.isDescendant(of: $0) }) {
            return false
        }
        /// double tap会阻塞主线程，比如：按钮点击后会卡0.2s左右。这里采用自定义延时，不阻塞主线程。
        let time = Date().timeIntervalSince1970
        if time - lastTapTime > tapInterval {
            lastTapTime = time
            return false
        }
        lastTapTime = 0
        return true
    }
}

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func like_viewDidLoad() {
        m_viewDidLoad()
        let likeGesture = RCLikeTapGesture(target: self,
                                           action: #selector(onLikeClicked(_:)),
                                           descendant: [])
        view.addGestureRecognizer(likeGesture)
    }
    
    @objc func onLikeClicked(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        showTapIcon(point)
        showLikeIcons()
        ChatroomSendMessage(RCChatroomLike())
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func like_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard
            message.conversationType == .ConversationType_CHATROOM,
            message.targetId == room.roomId,
            message.content.isKind(of: RCChatroomLike.self)
        else { return }
        showLikeIcons()
    }
    
    private func showTapIcon(_ point: CGPoint) {
        let layer = VoiceRoomLikeIconLayer("tap")
        view.layer.addSublayer(layer)
        
        let width = 45.resize
        let height = 45.resize
        let x = point.x - width * 0.5
        let y = point.y - height * 1.2
        layer.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.startTapAnimation()
    }
    
    private func showLikeIcons() {
        let layers = view.layer.sublayers?.filter({ $0.name == "like" }) ?? []
        guard layers.count <= 10 else { return }
        
        let layer = VoiceRoomLikeIconLayer("like")
        view.layer.addSublayer(layer)
        
        let tempFrame = view.convert(messageButton.frame, from: messageButton.superview)
        let width = tempFrame.width
        let height = tempFrame.height
        let x = tempFrame.midX - width * 0.5
        let y = tempFrame.minY - 8.resize - height
        layer.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.startAniamtion()
    }
}
