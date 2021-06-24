//
//  UIImageView+Kingfisher.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/10.
//

import UIKit
import Kingfisher

extension UIImageView {
    ///描述：加载大图文件只缓存磁盘，不缓存内存
    ///实现：optinos中加入memoryCacheExpiration，并设置过期
    ///case expired Indicates the item is already expired. Use this to skip cache.
    func kf_setOnlyDiskCacheImage(_ resource: Resource?, to targetSize: CGSize? = nil) {
        guard let resource = resource else { return }
        kf.setImage(with: resource, options: [.memoryCacheExpiration(.expired)]) { result in
            guard let targetSize = targetSize, case let .success(wrapper) = result else { return }
            DispatchQueue.global().async {
                let targetImage = wrapper.image.resizeAspectFillImage(to: targetSize)
                DispatchQueue.main.async { [weak self] in
                    self?.image = targetImage
                }
            }
        }
    }
}
