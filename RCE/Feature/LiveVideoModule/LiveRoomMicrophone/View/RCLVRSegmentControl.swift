//
//  RCLVRSegmentControl.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/18.
//

import UIKit
import Reusable

typealias RCLVRSegmentControlAction = (Int) -> Void

struct RCLVRSegmentItem {
    let title: String
}

class RCLVRSegmentControlCell: UICollectionViewCell, Reusable {
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .white
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? R.color.hexEF499A() : .white
        }
    }
    
    func update(_ item: RCLVRSegmentItem) -> Self {
        titleLabel.text = item.title
        return self
    }
}

class RCLVRSegmentControl: UIView {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.backgroundColor = .clear
        instance.delegate = self
        instance.dataSource = self
        instance.register(cellType: RCLVRSegmentControlCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        return instance
    }()
    private lazy var lineView: UIView = {
        let instance = UIView()
        instance.backgroundColor = R.color.hexEF499A()
        instance.layer.cornerRadius = 2
        instance.clipsToBounds = true
        return instance
    }()
    
    private let items: [RCLVRSegmentItem]
    private let action: RCLVRSegmentControlAction
    
    init(_ items:[RCLVRSegmentItem], action: @escaping RCLVRSegmentControlAction) {
        self.items = items
        self.action = action
        super.init(frame: .zero)
        buildLayout()
        DispatchQueue.main.async { self.didMove(to: 0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        addSubview(collectionView)
        addSubview(lineView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        lineView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 26.resize, height: 3.resize))
            make.top.equalTo(collectionView.snp.centerY).offset(17.resize)
            make.centerX.equalTo(collectionView).multipliedBy(1.0/3)
        }
    }
    
    private func move(_ index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        lineView.snp.remakeConstraints {
            $0.size.equalTo(CGSize(width: 26.resize, height: 3.resize))
            $0.top.equalTo(cell.snp.centerY).offset(17.resize)
            $0.centerX.equalTo(cell)
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}

extension RCLVRSegmentControl: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView
            .dequeueReusableCell(for: indexPath, cellType: RCLVRSegmentControlCell.self)
            .update(items[indexPath.item])
    }
}

extension RCLVRSegmentControl: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        move(indexPath.item)
        action(indexPath.item)
    }
}

extension RCLVRSegmentControl: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / CGFloat(items.count)
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
}

extension RCLVRSegmentControl: ScrollableHeaderProtocol {
    func didMove(to index: Int) {
        move(index)
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    func height() -> CGFloat {
        return 63
    }
    
    func offsetPercent(percent: CGFloat) {
    }
}
