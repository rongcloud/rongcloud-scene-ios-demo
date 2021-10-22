//
//  LiveVideoRoomViewController+Live.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/29.
//

import Foundation
import UIKit

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: role)
    private var live_role: RCRTCLiveRoleType {
        get { role }
        set {
            role = newValue
            if role == .audience {
                layoutLiveVideoUserLeave()
            }
        }
    }
    
    func layoutLiveVideoView(_ frameInfo: [String: NSValue]) {
        if let item = frameInfo.first {
            layoutLiveVideoUserJoin(item.key, frame: item.value.cgRectValue)
        } else {
            layoutLiveVideoUserLeave()
        }
    }
    
    private func layoutLiveVideoUserJoin(_ userId: String, frame: CGRect) {
        if frame == .zero { return }
        let offset = view.bounds.width - frame.origin.x + 8
        messageView.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-offset)
            make.bottom.equalTo(toolBarView.snp.top)
            make.height.equalTo(320.resize)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        messageView.reloadMessages()
        
        roomUserView.update(userId)
        roomUserView.frame = frame
        view.addSubview(roomUserView)
    }
    
    private func layoutLiveVideoUserLeave() {
        if messageView.superview == nil { return }
        messageView.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalTo(toolBarView.snp.top)
            make.width.equalToSuperview().multipliedBy(278.0 / 375)
            make.height.equalTo(320.resize)
        }
        messageView.reloadMessages()
        
        roomUserView.update(nil)
        roomUserView.removeFromSuperview()
    }
}
