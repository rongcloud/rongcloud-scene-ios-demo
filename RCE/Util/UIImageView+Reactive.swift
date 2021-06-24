//
//  UIImageView+Reactive.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/18.
//

import Foundation
import RxSwift
import Kingfisher

extension Reactive where Base == AnimatedImageView {
    var animatedUrl: Binder<String> {
        return Binder(self.base) {
            imageView, url in
            imageView.kf.setImage(with: URL(string: url), options: [.memoryCacheExpiration(.expired)])
        }
    }
}
