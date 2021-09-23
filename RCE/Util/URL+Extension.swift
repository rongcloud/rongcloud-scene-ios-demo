//
//  URL+Extension.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/6.
//

import Foundation

extension URL {
    static func potraitURL(portrait: String) -> URL? {
        if portrait.count > 0 {
            return URL(string: Environment.current.url.absoluteString + "/file/show?path=" + portrait)
        }
        return URL(string: "https://cdn.ronghub.com/demo/default/rce_default_avatar.png")
    }
}
