//
//  HomeViewController+Version.swift
//  RCE
//
//  Created by shaoshuai on 2022/2/22.
//

import UIKit

extension HomeViewController {
    private func judgeLogin() {
        if Environment.businessToken.count == 0 {
            showBusinessToken()
        } else if UserDefaults.standard.authorizationKey() == nil {
            navigator(.login)
        }
        messageButton.updateDot()
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
extension HomeViewController {
    private func showBusinessToken() {
        let controller = UIAlertController(title: "提示", message: "您需要配置的 BusinessToken，请全局搜索 BusinessToken，可以找到 BusinessToken 获取方式。", preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default) { _ in  exit(10) }
        controller.addAction(action)
        present(controller, animated: true)
    }
}
