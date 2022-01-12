//
//  RCLiveVideoSeatView.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/7.
//

import UIKit

class RCLiveVideoSeatView: UIView {

    private var views = [Int: RCLiveVideoSeatItemView]()

}

extension RCLiveVideoSeatView: RCLiveVideoMixDataSource {
//    func liveVideoSeatView(with seatInfo: RCLiveVideoSeat) -> UIView {
//        guard let room = room else { return UIView() }
//        if RCLiveVideoEngine.shared().currentMixType == .oneToOne {
//            if seatInfo.userId.count == 0 { return UIView() }
//        }
//        return RCLiveVideoSeatItemView(room, seatInfo: seatInfo)
//    }
}

extension RCLiveVideoSeatView: RCLiveVideoMixDelegate {
    func liveVideoDidLayout(_ seat: RCLiveVideoSeat, withFrame frame: CGRect) {
        
    }
}
