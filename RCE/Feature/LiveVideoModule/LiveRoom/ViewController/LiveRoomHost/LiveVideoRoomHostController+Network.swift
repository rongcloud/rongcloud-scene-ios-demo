//
//  LiveVideoRoomHostController+Network.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/9.
//

import SVProgressHUD
import Reachability

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
            return SVProgressHUD.showInfo(withStatus: "当前连接中断，请检查网络设置")
        }
        SVProgressHUD.show(withStatus: "连接中...")
//        SceneRoomManager.shared.getCurrentPKInfo(roomId: room.roomId) { statusModel in
//            
//        }
        networkProvider.request(.roomInfo(roomId: room.roomId)) { [weak self] result in
            switch result.map(RCNetworkWapper<VoiceRoom>.self) {
            case let .success(wrapper):
                if wrapper.code == 30001 {
                    self?.navigationController?.popViewController(animated: true)
                    SVProgressHUD.showError(withStatus: "房间已关闭")
                }
            case .failure:
                self?.navigationController?.popViewController(animated: true)
                SVProgressHUD.showError(withStatus: "连接失败")
            }
        }
    }
}
