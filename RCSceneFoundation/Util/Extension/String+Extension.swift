//
//  String+Extension.swift
//  RCSceneRoomSetting
//
//  Created by shaoshuai on 2022/1/27.
//

import UIKit

public extension String {
    var color: UIColor? {
        return UIColor(named: self,
                       in: AssetPlugin.bundle("Colors"),
                       compatibleWith: nil)
    }
    
    var image: UIImage? {
        return UIImage(named: self,
                       in: AssetPlugin.bundle("Images"),
                       compatibleWith: nil)
    }
}


public class AssetPlugin {
    static func bundle() -> Bundle {
        return Bundle(for: self)
    }
    
    static func bundle(_ name: String) -> Bundle? {
        let bundle = AssetPlugin.bundle()
        let path = bundle.path(forResource: name, ofType: "bundle")
        return path == nil ? nil : Bundle(path: path!)
    }
}

public extension String {
    var local: String {
        return self
    }
}

public extension String {
    var intValue: Int {
        return Int(self) ?? 0
    }
    
    var cgfloatValue: CGFloat {
        return CGFloat(Float(self) ?? 0)
    }
}

public extension String {
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

public extension String {
    func decode<T: Codable>(_ empty: T) -> T {
        guard let data = data(using: .utf8) else { return empty }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return empty
        }
    }
}

