//
//  RCMHBeautyView.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/2.
//

import UIKit

enum RCMHBeautyAction: String, CaseIterable {
    case switchCamera = "翻转"
    case sticker = "贴纸"
    case retouch = "美颜"
    case makeup = "美妆"
    case effect = "特效"
}

protocol RCMHBeautyViewDelegate: AnyObject {
    func didClickBeautyAction(_ action: RCMHBeautyAction)
}

class RCMHBeautyView: UIView {
    
    weak var delegate: RCMHBeautyViewDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.backgroundColor = .clear
        instance.delegate = self
        instance.dataSource = self
        instance.register(cellType: RCMHBeautyActionCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        return instance
    }()
    
    private lazy var items = RCMHBeautyAction.allCases
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("RCMHBV deinit")
    }
}

extension RCMHBeautyView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView
            .dequeueReusableCell(for: indexPath, cellType: RCMHBeautyActionCell.self)
            .update(items[indexPath.item])
    }
}

extension RCMHBeautyView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didClickBeautyAction(items[indexPath.item])
    }
}

extension RCMHBeautyView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 40) / CGFloat(items.count)
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}
