//
//  RCSLiveThirdCDN.swift
//  RCRTC
//
//  Created by shaoshuai on 2022/9/5.
//

import PLPlayerKit
import RCSceneVideoRoom

class RCSLiveThirdCDN: NSObject {
    static let shared = RCSLiveThirdCDN()
    
    var pullPath: String {
        AppConfigs.ENV.CDN["BSY"]?["pull"] ?? ""
    }
    
    var pushPath: String {
        AppConfigs.ENV.CDN["BSY"]?["push"] ?? ""
    }
}

extension RCSLiveThirdCDN: RCSThirdCDNProtocol {
    func pushURLString(_ roomId: String) -> String {
        return "rtmp://\(pushPath)/scene/\(roomId)"
    }
    
    func pullURLString(_ roomId: String) -> String {
        return "rtmp://\(pullPath)/scene/\(roomId)"
    }
    
    func pullPlayer(_ roomId: String) -> RCSLivePlayerView {
        return RCSThirdPlayerView.shared
    }
}

class RCSThirdPlayerView: RCSLivePlayerView {
    static let shared = RCSThirdPlayerView()
    
    private lazy var option: PLPlayerOption = {
        let option = PLPlayerOption.default()
        option.setOptionValue(NSNumber(15), forKey: PLPlayerOptionKeyTimeoutIntervalForMediaPackets)
        option.setOptionValue(NSNumber(2000), forKey: PLPlayerOptionKeyMaxL1BufferDuration)
        option.setOptionValue(NSNumber(1000), forKey: PLPlayerOptionKeyMaxL2BufferDuration)
        option.setOptionValue(NSNumber(false), forKey: PLPlayerOptionKeyVideoToolbox)
        return option
    }()
    private var player: PLPlayer?
    
    func start(_ roomId: String) {
        player?.playerView?.removeFromSuperview()
        player?.stop()
        player = nil
        
        let pullPath = RCSLiveThirdCDN.shared.pullURLString(roomId)
        guard
            let URL = URL(string: pullPath),
            let player = PLPlayer(url: URL, option: option),
            let view = player.playerView
        else { return }
        
        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        player.play()
        
        self.player = player
    }
    
    func stop() {
        player?.stop()
        player = nil
    }
}

extension RCSThirdPlayerView: PLPlayerDelegate {
}
