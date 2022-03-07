//
//  ViewAdaptiveUtil.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import UIKit

private let ScreenWidth: CGFloat = UIScreen.main.bounds.width
private let ScreenHeight: CGFloat = UIScreen.main.bounds.height
private var AdaptorScale: CGFloat = 1

public class Adaptor {
    public class func set(design size: CGSize) {
        AdaptorScale = min(ScreenWidth, ScreenHeight) / min(size.width, size.height)
    }
}

public extension Int {
    var resize: CGFloat {
        return (CGFloat(self) * AdaptorScale).pxOptimize
    }
}

public extension Double {
    var resize: CGFloat {
        return (CGFloat(self) * AdaptorScale).pxOptimize
    }
}

public extension Float {
    var resize: CGFloat {
        return (CGFloat(self) * AdaptorScale).pxOptimize
    }
}

public extension CGFloat {
    var resize: CGFloat {
        return (self * AdaptorScale).pxOptimize
    }
    
    var pxOptimize: CGFloat {
        return ceil(self)
    }
}
