//
//  RCRoomListViewController+Feedback.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/14.
//

import UIKit

extension RCRoomListViewController {
    func showFeedbackIfNeeded() {
        guard UserDefaults.standard.shouldShowFeedback() else { return }
        navigator(.feedback)
    }
}
