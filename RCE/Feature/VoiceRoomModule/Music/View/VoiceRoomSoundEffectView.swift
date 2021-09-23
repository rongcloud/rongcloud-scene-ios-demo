//
//  VoiceRoomSoundEffectView.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/3.
//

import RxSwift
import RxCocoa
import RxDataSources

final class VoiceRoomSoundEffectView: UIView {
    
    var disposeBag = DisposeBag()
    
    private lazy var effectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        return UIVisualEffectView(effect: blur)
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 64.resize, height: 38.resize)
        layout.minimumLineSpacing = 15.resize
        layout.scrollDirection = .horizontal
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.backgroundColor = .clear
        instance.register(cellType: VoiceRoomMusicSoundEffectCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.contentInset = UIEdgeInsets(top: 0, left: 18.resize, bottom: 0, right: 18.resize)
        return instance
    }()
    
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<VoiceRoomSoundEffectSection> = {
        return RxCollectionViewSectionedReloadDataSource<VoiceRoomSoundEffectSection>
        { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            return collectionView
                .dequeueReusableCell(for: indexPath, cellType: VoiceRoomMusicSoundEffectCell.self)
                .update(item)
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(effectView)
        addSubview(collectionView)
        
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        layer.cornerRadius = 6.resize
        layer.masksToBounds = true
        
        let soundEffects: [AudioEffect] = AudioEffect.allCases
        Observable.just([VoiceRoomSoundEffectSection(items: soundEffects)])
            .distinctUntilChanged()
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: VoiceRoomSoundEffectView {
    var soundEffect: ControlEvent<AudioEffect> {
        return base.collectionView.rx.modelSelected(AudioEffect.self)
    }
}
