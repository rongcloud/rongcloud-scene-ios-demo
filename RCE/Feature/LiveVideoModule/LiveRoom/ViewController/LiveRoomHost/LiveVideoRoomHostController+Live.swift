//
//  LiveVideoRoomHostController+Live.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/29.
//

import UIKit

extension LiveVideoRoomHostController {
    func layoutLiveVideoView(_ mixType: RCLiveVideoMixType) {
        setupPreviewLayout(mixType)
        setupMessageLayout(mixType)
    }
    
    private func setupPreviewLayout(_ mixType: RCLiveVideoMixType) {
        let preview = RCLiveVideoEngine.shared().previewView()
        switch mixType {
        case .default, .oneToOne:
            preview.snp.remakeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(preview.snp.height).multipliedBy(9.0 / 16)
            }
        case .oneToSix:
            preview.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide).offset(98)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            }
        default:
            preview.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide).offset(98)
                make.height.equalTo(preview.snp.width)
            }
        }
    }
    
    func setupMessageLayout(_ mixType: RCLiveVideoMixType) {
        let preview = RCLiveVideoEngine.shared().previewView()
        switch mixType {
        case .oneToOne:
            chatroomView.messageView.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalToSuperview().offset(-140.resize)
                make.bottom.equalTo(chatroomView.toolBar.snp.top)
                make.height.equalTo(320.resize)
            }
        case .oneToSix:
            chatroomView.messageView.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalToSuperview().offset(-120.resize)
                make.bottom.equalTo(chatroomView.toolBar.snp.top)
                make.height.equalTo(320.resize)
            }
        default:
            chatroomView.messageView.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalToSuperview().offset(-100)
                make.bottom.equalTo(chatroomView.toolBar.snp.top)
                make.top.equalTo(preview.snp.bottom).offset(8)
            }
        }
        DispatchQueue.main.async {
            self.chatroomView.messageView.tableView.reloadData()
        }
    }
}
