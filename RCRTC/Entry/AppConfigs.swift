//
//  AppConfigs.swift
//  RCE
//
//  Created by shaoshuai on 2022/3/24.
//

import RCSceneRoom
import RCSceneLoginKit

struct AppENV: Codable {
    let app_id: [String: String]
    let business_token: String
    let server_address: [String: String]
    let analytics: [String: [String: String]]
    let beauty: [String: [String: String]]
    let music: [String: [String: String]]
    let CDN: [String: [String: String]]
}

var isAppStoreAccount: Bool = false

class AppConfigs {
    
    static var ENV: AppENV = {
        let path = Bundle.main.url(forResource: "ENV", withExtension: "plist")
        guard let path = path else {
            fatalError("ENV.plist file is not found")
        }
        do {
            let data = try Data(contentsOf: path)
            return try PropertyListDecoder().decode(AppENV.self, from: data)
        } catch {
            fatalError("ENV.plist file decode failed")
        }
    }()
    
    static var ENVDefine: String {
#if DEBUG
        return "debug"
#elseif OVERSEA
        return "overseas"
#else
        return "release"
#endif
    }
    
    static var RCKey: String {
        return ENV.app_id[ENVDefine] ?? ""
    }
    
    static var MHBeautyKey: String {
        guard let MH = ENV.beauty["MH"] else { return "" }
        let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        switch bundleID {
        case "cn.rongcloud.rcrtc": return MH["key"] ?? ""
        case "cn.rongcloud.rcrtc.appstore": return MH["appstore"] ?? ""
        case "cn.rongcloud.rcrtc.oversea": return MH["overseas"] ?? ""
        default: return ""
        }
    }
    
    static func config() {
        configBaseURL()
        configUMengKey()
        configBuglyKey()
        configHiFive()
        configBusinessToken()
        configLoginKit()
    }
    static func configLoginKit() {
    
        RCSLoginConfig.config(withBaseUrl: ENV.server_address[ENVDefine] ?? "",
                              bussinessToken: ENV.business_token,
                              isOverSea: ENVDefine == "overseas",
                              appChannel: kAppChannel,
                              appVersion: appVersion)
    }
    
    static func configBaseURL() {
        let urlString = ENV.server_address[ENVDefine] ?? ""
        Environment.url = URL(string: urlString)!
    }
    
    static func configUMengKey() {
        guard let UM = ENV.analytics["UM"] else { return }
        /// 友盟初始化
        #warning("""
            "友盟提示:"
            "隐私协议中必须含有友盟说明，初始化必须放到用户同意隐私协议后."
            "参考:"
            "https://developer.umeng.com/docs/147377/detail/213789"
            """)
        UMConfigure.initWithAppkey(UM["key"] ?? "", channel: "App Store")
        MobClick.setAutoPageEnabled(true)
        UMConfigure.setLogEnabled(true)
    }
    
    static func configBuglyKey() {
        guard let BUGLY = ENV.analytics["BUGLY"] else { return }
        Bugly.start(withAppId: BUGLY["key"] ?? "")
    }
    
    static func configHiFive() {
        guard let HIFIVE = ENV.music["HIFIVE"] else { return }
        let config = RCSceneMusicConfig(appId: HIFIVE["app_id"] ?? "",
                                        code: HIFIVE["server_code"] ?? "",
                                        version: HIFIVE["server_version"] ?? "",
                                        clientId: Environment.currentUserId)
        RCSceneMusic.active(config)
    }
    
    /// 申请 BusinessToken：https://rcrtc-api.rongcloud.net/code
    static func configBusinessToken() {
        Environment.businessToken = ENV.business_token
    }
}

extension Environment {
    static var sensorServer: String {
        return AppConfigs.ENV.analytics["SENSOR"]?["server_address"] ?? ""
    }
    static func configChannel() -> String {
        /// add Channel.plist
        let path = Bundle.main.path(forResource: "Channel", ofType: "plist")!
        let config = NSDictionary(contentsOfFile: path)
        return config?["Channel"] as? String ?? ""
    }
}
