//
//  LiveVideoRoomHostController+Network.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/9.
//

import SVProgressHUD
import Reachability
import RCLiveVideoLib
import RCSceneService
import RCSceneModular

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func network_viewDidLoad() {
        m_viewDidLoad()
        
        Notification.Name
            .reachabilityChanged
            .addObserver(self, selector: #selector(networkStateChange(_:)))
    }
    
    @objc private func networkStateChange(_ notification: Notification) {
        guard let reachable = notification.object as? Reachability else { return }
        if reachable.connection == .unavailable {
            SVProgressHUD.showInfo(withStatus: "当前连接中断，请检查网络设置")
        } else {
            fetchRoomInfo()
        }
    }
    
    private func fetchRoomInfo() {
        videoRoomService.roomInfo(roomId: room.roomId) { [weak self] result in
            switch result.map(RCNetworkWapper<VoiceRoom>.self) {
            case let .success(model):
                if model.code == 30001 {
                    self?.closeRoom()
                    self?.stopPK()
                } else {
                    if let pk = RCLiveVideoEngine.shared().pkInfo {
                        self?.fetchServerPKInfo(pk)
                    }
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    private func stopPK() {
        guard
            let pk = RCLiveVideoEngine.shared().pkInfo,
            pk.roomId() == room.roomId
        else { return }
        videoRoomService.setPKStatus(roomId: pk.roomId(),
                                     toRoomId: pk.otherRoomId(),
                                     status: .close) { _ in }
    }
}
