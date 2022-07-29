//
//  RCSceneRoomPlayer.swift
//  RCRTC
//
//  Created by johankoi on 2022/7/28.
//

import Foundation
import RCSceneRadioRoom
import PLPlayerKit

class RCSceneRoomPlayer: NSObject {
    var cdnPlayer: PLPlayer?
    
    private(set) lazy var cdnPlayerOpt: PLPlayerOption = {
        let option = PLPlayerOption.default()
        option.setOptionValue(kPLPLAY_FORMAT_FLV, forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets)
        option.setOptionValue(kPLLogInfo, forKey:PLPlayerOptionKeyLogLevel)
        return option
    }()
    
    override init() {
        super.init()
    }
}

extension RCSceneRoomPlayer: RCPlayerProtocol {
    func rtmpUrl(roomId: String, isPush: Bool) -> String {
        let host = AppConfigs.thirdCDNHost(isPush: isPush)
        return "\(host)/rcrtc/\(roomId)"
    }
    
    public func play(url: String) {
        let url = URL(string: url)
        cdnPlayer = PLPlayer(liveWith: url, option: nil)
        cdnPlayer!.delegateQueue = DispatchQueue.main;
        cdnPlayer?.delegate = self
        cdnPlayer?.play()
        cdnPlayer?.setVolume(1.0)
    }

    public func pause() {
        cdnPlayer?.pause()
    }

    public func resume() {
        cdnPlayer?.resume()
    }

    public func stop() {
        cdnPlayer?.stop()
    }

    public func destory() {
        cdnPlayer = nil
    }
}

extension RCSceneRoomPlayer: PLPlayerDelegate {
    func player(_ player: PLPlayer, statusDidChange state: PLPlayerStatus) {
        
    }
    
    func player(_ player: PLPlayer, stoppedWithError error: Error?) {
        
    }
}
