//
//  RCECommunityVC.swift
//  RCE
//
//  Created by dev on 2022/5/19.
//

import RCSceneCommunity

class RCECommunityVC:RCSCHomeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationNameLogin.addObserver(self, selector: #selector(onLogin))
        NotificationNameLogout.addObserver(self, selector: #selector(onLogout))
        NotificationNameShuMeiKickOut.addObserver(self, selector: #selector(onLogout))
        RCIM.shared().connectionStatusDelegate = self
        RCCoreClient.shared().add(self)
        checkVersion()
    }
    
    
    @objc func onLogin() { //FIMXE: 暂时留空,这里暂时留空

        guard let user = RCSCUser.RCSCGetUser() else {
            SVProgressHUD.showInfo(withStatus: "RCSCUser.ueser,为空")
            //重新登录
            onLogout()
            return
        }
        print("RCSCUser.user.authorization -> \(user.authorization)")
        
        super.fetchCommunityListData()
        
        AppConfigs.configHiFive()
        RCCoreClient.shared().messageBlockDelegate = self;
        FraudProtectionTips.showFraudProtectionTips(self)
    }
    
    @objc func onLogout() {
        if let presented = presentedViewController {
            return presented.dismiss(animated: false) { [unowned self] in onLogout() }
        }
        navigationController?.popToRootViewController(animated: false)
        navigator(.login)
    }
    
}



extension RCECommunityVC {
    private func judgeLogin() {
        if Environment.businessToken.count == 0 {
            showBusinessToken()
        } else if UserDefaults.standard.authorizationKey() == nil {
            navigator(.login)
        } else {
            let userId = Environment.currentUserId
            RCSensor.shared?.login(withKey: "$identity_login_id", loginId: userId)
        }
//        messageButton.updateDot() //FIXME: 后期可扩展tab 的小红点
    }
    
    func checkVersion() {
        let api = RCNetworkAPI.checkVersion(platform: "iOS")
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(value):
                let info = try? JSONSerialization.jsonObject(with: value.data, options: .allowFragments) as? [String: Any]
                guard let dataMap = info?["data"] as? [String: Any] else {
                    return self.judgeLogin()
                }
                let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? NSString
                let latestVersion = dataMap["version"] as? String
                let downloadUrl = dataMap["downloadUrl"] as? String
                let forceUpgrade = dataMap["forceUpgrade"] as? Bool
                let releaseNote = dataMap["releaseNote"] as? String
                guard
                    let latestVersion = latestVersion,
                    let bundleVersion = bundleVersion,
                    let downloadUrl = downloadUrl else {
                        return self.judgeLogin()
                    }
                
                // 2.0.0 to 3.0.0 is ascending order, so ask user to update
                let versionCompare = bundleVersion.compare(latestVersion, options: .numeric)
                guard versionCompare == .orderedAscending else {
                    return self.judgeLogin()
                }
                let force = forceUpgrade ?? false
                let cancelAction = UIAlertAction(title: "取消", style: .cancel) { action in
                    self.judgeLogin()
                }
                let updateAction = UIAlertAction(title: "更新", style: .default) { action in
                    self.judgeLogin()
                    if let updateUrl = URL(string: downloadUrl) {
                        UIApplication.shared.open(updateUrl)
                    }
                }
                let alerVc = UIAlertController(title: "发现新的版本", message: releaseNote, preferredStyle: .alert)
                if !force {
                    alerVc.addAction(cancelAction)
                }
                alerVc.addAction(updateAction)
                self.present(alerVc, animated: true)
            case let .failure(error):
                print(error.localizedDescription)
                self.judgeLogin()
            }
        }
    }
}

/// BusinessToken
extension RCECommunityVC {
    private func showBusinessToken() {
        let controller = UIAlertController(title: "提示", message: "您需要配置的 BusinessToken，请全局搜索 BusinessToken，可以找到 BusinessToken 获取方式。", preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default) { _ in  exit(10) }
        controller.addAction(action)
        present(controller, animated: true)
    }
}



extension RCECommunityVC: RCIMConnectionStatusDelegate, RCIMClientReceiveMessageDelegate, RCMessageBlockDelegate {
    func onRCIMConnectionStatusChanged(_ status: RCConnectionStatus) {
        print("status: \(status.rawValue)")
        switch status {
        case .ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:
            SVProgressHUD.showInfo(withStatus: "您已下线，请重新登录")
            UserDefaults.standard.clearLoginStatus()
            onLogout()
        default: ()
        }
    }
    
    func onReceived(_ message: RCMessage, left: Int32, object: Any?) {
        if let loginDeviceMessage = message.content as? RCLoginDeviceMessage,
           let content = loginDeviceMessage.content,
           content.platform != "mobile" {
            SVProgressHUD.showInfo(withStatus: "您已下线，请重新登录")
            UserDefaults.standard.clearLoginStatus()
            RCCoreClient.shared().disconnect(true)
            DispatchQueue.main.async {
                self.onLogout()
            }
        } else if let _ = message.content as? RCShuMeiMessage {
            ShuMeiMessageHandler.handleMessage(message: message, object: nil)
        }
    }
    
    func messageDidBlock(_ info: RCBlockedMessageInfo) {
        let string = "发送的消息(消息类型:\(info.type) 会话id:\(info.targetId) 消息id:\(info.blockedMsgUId) 拦截原因:\(info.blockType) 附加信息:\(info.extra))遇到敏感词被拦截"
        let controller = UIAlertController(title: "提示", message: string, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true)
//        item.umengEvent.trigger()
//        item.sensorTrigger()
//        item.trigger(router)
    }
}
