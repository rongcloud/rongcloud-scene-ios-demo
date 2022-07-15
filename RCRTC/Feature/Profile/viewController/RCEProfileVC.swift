//
//  RCEProfileVC.swift
//  RCE
//
//  Created by dev on 2022/5/23.
//

import RCSceneCommunity

class RCEProfileVC:RCSCProfileViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationNameLogin.addObserver(self, selector: #selector(onLogin))
    }
    
    @objc func onLogin() { //FIMXE: 暂时留空,这里暂时留空

        guard let user = RCSCUser.RCSCGetUser() else {
            SVProgressHUD.showInfo(withStatus: "RCSCUser.ueser,为空")
            //重新登录
            logout()
            return
        }
        print("RCSCUser.user.authorization -> \(user.authorization)")
        
        super.reloadHeader()
    }
    
 
 
    override func logout() {
        super.logout()
//
        UserDefaults.standard.clearLoginStatus()
        RCCoreClient.shared().disconnect(true)
        dismiss(animated: true) {
            self.tabBarController?.selectedIndex = 0
            NotificationNameLogout.post()
        }
        
    }
}
