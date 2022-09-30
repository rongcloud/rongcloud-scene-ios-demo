//
//  UICollectionView+Reusable.swift
//  RCE
//
//  Created by shaoshuai on 2021/7/2.
//

import Reusable

extension UICollectionView {
    func cellForItem<T: UICollectionViewCell>(_ indexPath: IndexPath, cellType: T.Type) -> T? where T: Reusable {
        return cellForItem(at: indexPath) as? T
    }
}
