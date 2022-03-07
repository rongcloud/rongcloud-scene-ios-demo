//
//  VoiceRoomViewController+Message.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/22.
//

import SVProgressHUD

extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func setupChatModule() {
        setupModules()
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func chat_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard message.conversationType == .ConversationType_PRIVATE else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.messageButton.refreshMessageCount()
        }
    }
}
