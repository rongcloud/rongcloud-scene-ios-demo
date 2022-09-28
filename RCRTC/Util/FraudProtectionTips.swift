//
//  LoginTipsManager.swift
//  RCE
//
//  Created by xuefeng on 2022/1/25.
//

import UIKit
import SVProgressHUD

class FraudProtectionTips {
    
    private static func sameDay() -> Bool {
        let today = Date()
        let day = UserDefaults.standard.fraudProtectionTriggerDate()
        UserDefaults.standard.set(fraudProtectionTriggerDate: today)
        if (day == nil) {
            return false
        }
        return Calendar.current.isDate(today, inSameDayAs: day!)
    }
    
    static func showFraudProtectionTips(_ viewController: UIViewController?) {
        guard let vc = viewController, !sameDay() else {
            return
        }
        let alert = UIAlertController(title: "重要提示", message: "您正在使用融云RTC，融云提醒您谨防诈骗，不要轻信涉钱信息", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}

