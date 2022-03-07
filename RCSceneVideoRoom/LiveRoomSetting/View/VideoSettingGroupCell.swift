//
//  VideoSettingGroupCell.swift
//  RCE
//
//  Created by hanxiaoqing on 2021/11/29.
//

import UIKit
import Reusable

protocol VideoSettingGroupCellDelegate: NSObjectProtocol {
    func didSelectedInnerCollectItem(_ at: IndexPath, inCell: VideoSettingGroupCell, settingOption: VideoSettingOption?)
}

class VideoSettingGroupCell: UITableViewCell, Reusable {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.register(cellType: VideoSettingDetailedOptionCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.contentInsetAdjustmentBehavior = .never
        instance.backgroundColor = .clear
        instance.dataSource = self
        instance.delegate = self
        return instance
    }()
    
    weak var delegate: VideoSettingGroupCellDelegate? = nil
    
    private lazy var collectionItems: [(String, Bool)]  = {
        [(String, Bool)]()
    }()
    
    private lazy var indexPathCellIdMap: [String:String] = {
        [String:String]()
    }()
    
    private var itemStringValues: [String]?
    
    var settingOption: VideoSettingOption? {
        didSet {
            switch settingOption {
            case .resolutionRatios(let ratios):
                itemStringValues = ratios.map{ $0.resolutionDescription }
            case .framesPerSecond(let fps):
                itemStringValues = fps.map{ "\($0)" }
            case .bitRates(let bitRate):
                itemStringValues = ["\(bitRate)kbps"]
            case .none: do { }
            }
        }
    }
    
    private var rowItemsCountInCell: Int = 0
    private var currentSelectedCell: UICollectionViewCell?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.left.equalTo(contentView).offset(15)
            $0.right.equalTo(contentView).offset(-15)
            $0.top.height.equalTo(contentView)
        }
    }
    
    func selectItemAt(index: Int) {
        for i in 0...collectionItems.count - 1 {
            var item = collectionItems[i] as (String, Bool)
            if index == i {
                item.1 = true
            } else {
                item.1 = false
            }
            collectionItems[i] = item
        }
        collectionView.reloadData()
    }
    
    func update(values: [String]) {
        for i in 0...collectionItems.count - 1 {
            var item = collectionItems[i] as (String, Bool)
            item.0 = values[i]
            collectionItems[i] = item
        }
        collectionView.reloadData()
    }
    
    func updateContent(_ settingOption: VideoSettingOption, rowItemsCount: Int, selectIndex: IndexPath?)  {
        self.settingOption = settingOption
        guard let contentItems = itemStringValues else {
            return
        }
        
        var selectionStateItems: [(String, Bool)] = [(String, Bool)]()
        for i in 0...contentItems.count - 1 {
            if let index = selectIndex {
                if index.item == i {
                    selectionStateItems.append((contentItems[i], true))
                } else {
                    selectionStateItems.append((contentItems[i], false))
                }
            } else {
                selectionStateItems.append((contentItems[i], false))
            }
        }
        collectionItems = selectionStateItems
        rowItemsCountInCell = rowItemsCount
        collectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension VideoSettingGroupCell: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: VideoSettingDetailedOptionCell.self)
        cell.update(collectionItems[indexPath.item].0, selected: collectionItems[indexPath.item].1)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectedInnerCollectItem(indexPath, inCell: self, settingOption: settingOption)
    }
}


extension VideoSettingGroupCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if rowItemsCountInCell == 1 {
            return CGSize(width: 80.resize, height: 45.resize)
        }
        let width = (Int(collectionView.bounds.width) - (rowItemsCountInCell + 1) * 25) / rowItemsCountInCell
        return CGSize(width: width.resize, height: 45.resize)
    }
    
}
