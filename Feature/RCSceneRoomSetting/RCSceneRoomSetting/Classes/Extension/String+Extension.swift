//
//  String+Extension.swift
//  RCSceneRoomSetting
//
//  Created by shaoshuai on 2022/1/27.
//

import UIKit

class AssetPlugin {
    static func bundle() -> Bundle {
        return Bundle(for: self)
    }
    
    static func bundle(_ name: String) -> Bundle? {
        let bundle = AssetPlugin.bundle()
        let path = bundle.path(forResource: name, ofType: "bundle")
        return path == nil ? nil : Bundle(path: path!)
    }
}

extension String {
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
