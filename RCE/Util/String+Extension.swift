//
//  String+Extension.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/1.
//

import Foundation

extension String {
    var local: String {
        return self
    }
}

extension String {
    var intValue: Int {
        return Int(self) ?? 0
    }
    
    var cgfloatValue: CGFloat {
        return CGFloat(Float(self) ?? 0)
    }
}

extension String {
    var rectValue: CGRect {
        let tmp = self
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: " ", with: "")
        let items = tmp.components(separatedBy: ",")
        if items.count != 4 { return .zero }
        let x = CGFloat(Float(items[0]) ?? 0)
        let y = CGFloat(Float(items[1]) ?? 0)
        let w = CGFloat(Float(items[2]) ?? 0)
        let h = CGFloat(Float(items[3]) ?? 0)
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
