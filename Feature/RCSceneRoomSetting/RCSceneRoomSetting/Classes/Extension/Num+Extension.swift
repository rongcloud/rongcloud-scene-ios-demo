//
//  ViewAdaptiveUtil.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import Foundation

private let ScreenWidth: CGFloat = UIScreen.main.bounds.width
private let ScreenHeight: CGFloat = UIScreen.main.bounds.height
private var AdaptorScale: CGFloat = 1

class Adaptor {
    class func set(design size: CGSize) {
        AdaptorScale = min(ScreenWidth, ScreenHeight) / min(size.width, size.height)
    }
}

extension Int {
    var resize: CGFloat {
        return (CGFloat(self) * AdaptorScale).pxOptimize
    }
}

extension Double {
    var resize: CGFloat {
        return (CGFloat(self) * AdaptorScale).pxOptimize
    }
}

extension Float {
    var resize: CGFloat {
        return (CGFloat(self) * AdaptorScale).pxOptimize
    }
}

extension CGFloat {
    var resize: CGFloat {
        return (self * AdaptorScale).pxOptimize
    }
    
    var pxOptimize: CGFloat {
        return ceil(self)
    }
}
