//
//  RCGameSelectView.swift
//  RCE
//
//  Created by johankoi on 2022/5/12.
//

import UIKit

public protocol RCGameSelectViewDelegate: AnyObject {
    func didSelect(game: RCSceneGameResp)
}

class RCGameSelectView: UIView{
    
    var gameModels = [RCSceneGameResp]()
    
    private weak var delegate: RCGameSelectViewDelegate?
     
    private lazy var titleImageView: UIImageView = {
        let instance = UIImageView()
        instance.image = R.image.groom_rocket_icon()
        return instance
    }()

    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = UIColor(hexString: "#FF505E")
        instance.font = .boldSystemFont(ofSize: 14)
        instance.text = "快速来一局"
        return instance
    }()
    
    private lazy var gamesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 74.resize, height: 74.resize)
        flowLayout.minimumInteritemSpacing=7

        let instance = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        instance.backgroundColor = UIColor(hexString: "#E8F0F3")
        instance.showsHorizontalScrollIndicator = false
        instance.showsVerticalScrollIndicator = false
        instance.delegate = self
        instance.dataSource = self
        
        instance.contentInset = UIEdgeInsets(top: 0, left: 24.resize, bottom: 0, right: 24.resize)

        instance.register(RCGameSelectCell.self, forCellWithReuseIdentifier: "SELECT_CELL")
        return instance
    }()
    
    
    convenience init(frame: CGRect, delete: RCGameSelectViewDelegate?) {
        self.init(frame: frame)
        self.delegate = delete
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleImageView)
        self.addSubview(titleLabel)
        self.addSubview(gamesCollectionView)
        
        titleImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 18, height: 18))
            make.top.equalToSuperview().inset(20.resize)
            make.left.equalToSuperview().offset(15.resize)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 21))
            make.top.equalTo(titleImageView.snp.top).offset(-1.resize)
            make.left.equalTo(titleImageView.snp.right).offset(5.resize)
        }
        
        gamesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(15)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(105.resize)
        }
    }
    
    public func update(gameModels: [RCSceneGameResp]) {
        // reload gamesCollectionView
        self.gameModels = gameModels
        gamesCollectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension RCGameSelectView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameModels.count
    }
}

extension RCGameSelectView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =
        collectionView.dequeueReusableCell(withReuseIdentifier: "SELECT_CELL", for: indexPath) as! RCGameSelectCell
        return cell.updateCell(game: gameModels[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(game: gameModels[indexPath.row])
    }
}
