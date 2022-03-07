//
//  LiveVideoRoomViewController+Live.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/29.
//

import UIKit

extension LiveVideoRoomViewController {
    func layoutLiveVideoView(_ mixType: RCLiveVideoMixType) {
        previewView.setupPreviewLayout(mixType)
        if floatingManager?.showing == true { return }
        setupSeatLayout(mixType)
        setupMessageLayout(mixType)
    }
    
    func setupSeatLayout(_ mixType: RCLiveVideoMixType) {
        switch mixType {
        case .default, .oneToOne:
            seatView.snp.remakeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(seatView.snp.height).multipliedBy(9.0 / 16)
            }
        case .oneToSix:
            seatView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide).offset(98)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            }
        default:
            seatView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide).offset(98)
                make.height.equalTo(seatView.snp.width)
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
    
    func floatingBack() {
        previewView.backgroundColor = .clear
        previewView.transform = .identity
        
        view.insertSubview(previewView, belowSubview: seatView)
        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setupMessageLayout(RCLiveVideoEngine.shared().currentMixType)
    }
}
