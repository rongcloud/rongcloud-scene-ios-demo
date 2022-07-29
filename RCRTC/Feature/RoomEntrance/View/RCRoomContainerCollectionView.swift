//
//  RCRoomContainerCollectionView.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/30.
//

import UIKit

class RCRoomContainerCollectionView: UICollectionView {
    var scrollable: Bool = false
    var descendantViews: [UIView] = [] {
        didSet {
            descendantViews.compactMap { $0 as? UIScrollView }
                .forEach { $0.isExclusiveTouch = true }
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        isPagingEnabled = true
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hint = super.hitTest(point, with: event)
        isScrollEnabled = scrollable && !descendantViews.contains(where: { [unowned self] view in
            guard let tmp = hint else { return false }
            guard view.contain(tmp) else { return false }
            var frame = convert(view.frame, from: view.superview)
            frame.size.width = frame.width / 375 * 300
            return frame.contains(point)
        })
        return hint
    }
}

extension UIView {
    fileprivate func contain(_ view: UIView) -> Bool {
        if self == view { return true }
        for subview in subviews {
            if subview.contain(view) {
                return true
            }
        }
        return false
    }
}
