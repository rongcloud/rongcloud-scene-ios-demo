//
//  MusicSheetListView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/10/9.
//

import UIKit
import RxSwift
import RxDataSources

class MusicSheetListView: UIView {
    private var disposeBag = DisposeBag()
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.register(cellType: MusicSheetCollectionViewCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.backgroundColor = .clear
        instance.contentInset = UIEdgeInsets(top: 0, left: 23, bottom: 0, right: 23)
        return instance
    }()
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<MusicChannelSection> = {
        return RxCollectionViewSectionedReloadDataSource<MusicChannelSection> { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MusicSheetCollectionViewCell.self)
            cell.updateCell(channel: item)
            return cell
        }
    }()
    let subject = PublishSubject<[MusicChannelSection]>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
        subject.asObservable().bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension Reactive where Base == MusicSheetListView {
    var channelDidSelect: Observable<MusicChannel> {
        return base.collectionView.rx.modelSelected(MusicChannel.self).asObservable()
    }
}
