//
//  LiveVideoRoomViewController+Network.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/9.
//

import SVProgressHUD
import Reachability

extension LiveVideoRoomViewController {
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
        }
    }
}
