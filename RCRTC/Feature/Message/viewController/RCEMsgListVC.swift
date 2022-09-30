//
//  RCEMsgListVC.swift
//  RCE
//
//  Created by dev on 2022/6/9.
//

import RCSceneCommunity

class RCEMsgListVC: RCSCMessageListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationNameLogin.addObserver(self, selector: #selector(onLogin))
    }
    
    @objc func onLogin() {
        super.resetLoad()
    }
}
