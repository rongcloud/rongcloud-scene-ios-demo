//
//  VoiceRoomGiftListView.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/25.
//

import UIKit

fileprivate let kGiftNumberPerPage = 8

protocol VoiceRoomGiftListViewDelegate: AnyObject {
    func giftListView(_ view: VoiceRoomGiftListView, didSelected gift: VoiceRoomGift)
}

final public class VoiceRoomGiftListView: UIView {
    weak var delegate: VoiceRoomGiftListViewDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.register(cellType: VoiceRoomGiftCell.self)
        instance.backgroundColor = .clear
        instance.delegate = self
        instance.dataSource = self
        instance.isPagingEnabled = true
        instance.showsHorizontalScrollIndicator = false
        return instance
    }()
    
    private lazy var pageControl = UIPageControl()
    
    private var gifts = [VoiceRoomGift?]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(230.resize)
        }
        
        pageControl.numberOfPages = 2
        pageControl.addTarget(self, action: #selector(onPageControlValueChanged), for: .valueChanged)
        addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(collectionView.snp.bottom).offset(10.resize)
        }
        
        setupGifts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
            guard let delegate = self.delegate, let gift = self.gifts[0] else { return }
            delegate.giftListView(self, didSelected: gift)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onPageControlValueChanged() {
        let indexPath = IndexPath(item: pageControl.currentPage * kGiftNumberPerPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

public extension VoiceRoomGiftListView {
    private func setupGifts() {
        /// 初始化礼物
        gifts.append(VoiceRoomGift(id: "1", name: "小心心", icon: "gift_icon_1", price: 1))
        gifts.append(VoiceRoomGift(id: "2", name: "话筒", icon: "gift_icon_2", price: 2))
        gifts.append(VoiceRoomGift(id: "3", name: "麦克风", icon: "gift_icon_3", price: 5))
        gifts.append(VoiceRoomGift(id: "4", name: "萌小鸡", icon: "gift_icon_4", price: 10))
        gifts.append(VoiceRoomGift(id: "5", name: "手柄", icon: "gift_icon_5", price: 20))
        gifts.append(VoiceRoomGift(id: "6", name: "奖杯", icon: "gift_icon_6", price: 50))
        gifts.append(VoiceRoomGift(id: "7", name: "火箭", icon: "gift_icon_7", price: 100))
        gifts.append(VoiceRoomGift(id: "8", name: "礼花", icon: "gift_icon_8", price: 200))
        gifts.append(VoiceRoomGift(id: "9", name: "玫瑰花", icon: "gift_icon_9", price: 10))
        gifts.append(VoiceRoomGift(id: "10", name: "吉他", icon: "gift_icon_10", price: 20))
        
        /// 补全礼物，确保整页有数据
        let left = kGiftNumberPerPage - gifts.count % kGiftNumberPerPage
        (1...left).forEach { _ in
            gifts.append(nil)
        }
        
        /// UICollectionView Cell位置为上下->左右，需要调整展示位置
        /// 展示位置对应数组位置1-1,2-5,3-2,4-6,5-3,6-7,7-4,8-8
        let page = gifts.count / kGiftNumberPerPage
        (0..<page).forEach { pageIndex in
            let fi = pageIndex * kGiftNumberPerPage - 1
            gifts[(fi+1)...(fi+8)] = [
                gifts[fi + 1],
                gifts[fi + 5],
                gifts[fi + 2],
                gifts[fi + 6],
                gifts[fi + 3],
                gifts[fi + 7],
                gifts[fi + 4],
                gifts[fi + 8]
            ]
        }
    }
}

extension VoiceRoomGiftListView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifts.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(for: indexPath, cellType: VoiceRoomGiftCell.self)
            .update(gifts[indexPath.item])
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return gifts[indexPath.item] != nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let gift = gifts[indexPath.item], let delegate = delegate else {
            return
        }
        delegate.giftListView(self, didSelected: gift)
    }
}

extension VoiceRoomGiftListView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width * 0.25
        let height = collectionView.bounds.height * 0.5
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
