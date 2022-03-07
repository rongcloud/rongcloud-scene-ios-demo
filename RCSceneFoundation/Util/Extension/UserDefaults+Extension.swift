//
//  UserDefaults+Extension.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/28.
//

import Foundation

public  let RCLoginUserKey                  = "RCLoginUserKey"
private let RCRongCloudTokenKey             = "RCRongCloudTokenKey"
private let RCAuthorizationKey              = "RCAuthorizationKey"
private let RCFeedbackCountDown             = "RCFeedbackCountDown"
private let RCFeedbackCompletion            = "RCFeedbackCompletion"
private let RCFraudProtectionTriggerDateKey = "RCFraudProtectionTriggerDateKey"

public extension UserDefaults {
    func rongToken() -> String? {
        return UserDefaults.standard.string(forKey: RCRongCloudTokenKey)
    }
    
    func authorizationKey() -> String? {
        return UserDefaults.standard.string(forKey: RCAuthorizationKey)
    }
    
    func set(authorization: String) {
        UserDefaults.standard.setValue(authorization, forKey: RCAuthorizationKey)
    }
    
    func set(rongCloudToken: String) {
        UserDefaults.standard.setValue(rongCloudToken, forKey: RCRongCloudTokenKey)
    }
    
    func clearLoginStatus() {
        UserDefaults.standard.removeObject(forKey: RCAuthorizationKey)
        UserDefaults.standard.removeObject(forKey: RCRongCloudTokenKey)
        UserDefaults.standard.removeObject(forKey: RCLoginUserKey)
    }
    
    func shouldShowFeedback() -> Bool {
        if UserDefaults.standard.bool(forKey: RCFeedbackCompletion) { return false }
        return UserDefaults.standard.integer(forKey: RCFeedbackCountDown) == 3
    }
    
    func increaseFeedbackCountdown() {
        let currentCountdown = UserDefaults.standard.integer(forKey: RCFeedbackCountDown)
        UserDefaults.standard.setValue(currentCountdown + 1, forKey: RCFeedbackCountDown)
    }
    
    func feedbackCompletion() {
        UserDefaults.standard.setValue(true, forKey: RCFeedbackCompletion)
    }
  
    func clearCountDown() {
        UserDefaults.standard.setValue(0, forKey: RCFeedbackCountDown)
    }
    
    func set(fraudProtectionTriggerDate:Date) {
        UserDefaults.standard.setValue(fraudProtectionTriggerDate, forKey: RCFraudProtectionTriggerDateKey)
    }
    
    func fraudProtectionTriggerDate() -> Date? {
        return UserDefaults.standard.value(forKey: RCFraudProtectionTriggerDateKey) as? Date
    }
 }
