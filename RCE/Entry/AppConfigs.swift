//
//  AppConfigs.swift
//  RCE
//
//  Created by shaoshuai on 2022/3/24.
//

class AppConfigs {
    static func config() {
        configRCKey()
        configBaseURL()
        configUMengKey()
        configBuglyKey()
        configMHBeautyKey()
        configHiFive()
        configBusinessToken()
    }
    
    static func configRCKey() {
        Environment.rcKey = "pvxdm17jpw7ar"
    }
    
    static func configBaseURL() {
        Environment.url = URL(string: "https://rcrtc-api.rongcloud.net/")!
    }
    
    static func configUMengKey() {
        Environment.umengKey = ""
    }
    
    static func configBuglyKey() {
        Environment.buglyKey = ""
    }
    
    static func configMHBeautyKey() {
        Environment.MHBeautyKey = ""
    }
    
    static func configHiFive() {
        Environment.hiFiveAppId = ""
        Environment.hiFiveServerCode = ""
        Environment.hiFiveServerVersion = ""
    }
    
    /// 申请 BusinessToken：https://rcrtc-api.rongcloud.net/code
    static func configBusinessToken() {
        Environment.businessToken = ""
    }
}
