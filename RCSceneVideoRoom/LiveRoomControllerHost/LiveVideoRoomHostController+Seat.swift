//
//  LiveVideoRoomHostController+Seat.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/25.
//

import UIKit

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func seat_viewDidLoad() {
        m_viewDidLoad()
    }
    
    func switchSeat(fromSeat: RCLiveVideoSeat, toSeat: RCLiveVideoSeat) {
        if fromSeat.index == toSeat.index { return }
        RCLiveVideoEngine.shared().switchLiveVideo(to: toSeat.index) { code in
            debugPrint("switchLiveVideo \(code.rawValue)")
        }
    }
}
