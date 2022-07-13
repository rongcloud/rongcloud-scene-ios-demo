//
//  AppStyle.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/21.
//

import Foundation
import UIKit

final class AppStyle {
    static func defaultApperance() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().backIndicatorImage = R.image.back_indicator_image()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = R.image.back_indicator_image()
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor.black]
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().barTintColor = .white
    }
}
