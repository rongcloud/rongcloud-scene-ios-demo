//
//  HomeLayout.swift
//  RCE
//
//  Created by shaoshuai on 2022/3/4.
//

import UIKit

private struct Constants {
    static let itemPadding: CGFloat = 16.resize
    static let contentInset: CGFloat = 20.resize
    static let edge = UIEdgeInsets(top: contentInset,
                                   left: contentInset,
                                   bottom: contentInset,
                                   right: contentInset)
}

class HomeLayout: UICollectionViewLayout {
    private var contentHeight: CGFloat = 0
    private var items = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        
        items.removeAll()
        
        let width = collectionView?.bounds.width ?? UIScreen.main.bounds.width
        let inset = Constants.contentInset
        let space = Constants.itemPadding
        
        var startX: CGFloat = inset
        var startY: CGFloat = inset
        
        let voiceRoomWidth = (width - inset * 2 - space) * 0.5
        let voiceRoomHeight = voiceRoomWidth / 167 * 223
        let voiceRoomIndexPath = IndexPath(item: 0, section: 0)
        let voiceRoomLayout = UICollectionViewLayoutAttributes(forCellWith: voiceRoomIndexPath)
        voiceRoomLayout.frame = CGRect(x: startX,
                                       y: startY,
                                       width: voiceRoomWidth,
                                       height: voiceRoomHeight)
        items.append(voiceRoomLayout)
        
        startX = inset + voiceRoomWidth + space
        startY = inset
        
        let voiceCallWidth = voiceRoomWidth
        let voiceCallHeight = voiceCallWidth / 167 * 102
        let voiceCallIndex = IndexPath(item: 1, section: 0)
        let voiceCallLayout = UICollectionViewLayoutAttributes(forCellWith: voiceCallIndex)
        voiceCallLayout.frame = CGRect(x: startX,
                                       y: startY,
                                       width: voiceCallWidth,
                                       height: voiceCallHeight)
        items.append(voiceCallLayout)
        
        startX = inset + voiceRoomWidth + space
        startY += voiceCallHeight + inset
        
        let videoCallWidth = voiceRoomWidth
        let videoCallHeight = videoCallWidth / 167 * 102
        let videoCallIndex = IndexPath(item: 2, section: 0)
        let videoCallLayout = UICollectionViewLayoutAttributes(forCellWith: videoCallIndex)
        videoCallLayout.frame = CGRect(x: startX,
                                       y: startY,
                                       width: videoCallWidth,
                                       height: videoCallHeight)
        items.append(videoCallLayout)
        
        startX = inset
        startY += videoCallHeight + inset
        
        let videoRoomWidth = width - inset * 2
        let videoRoomHeight = videoRoomWidth / 346 * 205
        let videoRoomIndex = IndexPath(item: 3, section: 0)
        let videoRoomLayout = UICollectionViewLayoutAttributes(forCellWith: videoRoomIndex)
        videoRoomLayout.frame = CGRect(x: startX,
                                       y: startY,
                                       width: videoRoomWidth,
                                       height: videoRoomHeight)
        items.append(videoRoomLayout)
        
        startX = inset
        startY += videoRoomHeight + inset
        
        let radioRoomWidth = voiceRoomWidth
        let radioRoomHeight = radioRoomWidth / 167 * 102
        let radioRoomIndex = IndexPath(item: 4, section: 0)
        let radioRoomLayout = UICollectionViewLayoutAttributes(forCellWith: radioRoomIndex)
        radioRoomLayout.frame = CGRect(x: startX,
                                       y: startY,
                                       width: radioRoomWidth,
                                       height: radioRoomHeight)
        items.append(radioRoomLayout)
        
        contentHeight = startY + radioRoomHeight + inset
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return items.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return items[indexPath.item]
    }
    
    override var collectionViewContentSize: CGSize {
        let width = collectionView?.bounds.width ?? UIScreen.main.bounds.width
        return CGSize(width: width, height: contentHeight)
    }
}
