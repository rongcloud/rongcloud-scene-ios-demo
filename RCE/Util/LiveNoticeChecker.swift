//
//  LiveNoticeChecker.swift
//  RCE
//
//  Created by xuefeng on 2022/1/26.
//

import Foundation

class LiveNoticeChecker {
    static func check(_ text: String, _ completion:@escaping(Bool,String) -> Void) {
        let api = RCNetworkAPI.checkText(text: text)
        networkProvider.request(api) { result in
            switch result.map(AppResponse.self) {
            case let .success(res):
                if res.validate() {
                    completion(true,"")
                } else {
                    completion(false,res.msg ?? "文件检测未通过")
                }
            case let .failure(error):
                completion(false,"文件检测未通过")
                log.debug(error.localizedDescription)
            }
        }
    }
}
