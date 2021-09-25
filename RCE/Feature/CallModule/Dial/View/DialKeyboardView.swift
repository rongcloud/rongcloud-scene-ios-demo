//
//  DialKeyboard.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/30.
//

import RxSwift
import UIKit
import ReactorKit
import RxDataSources
import RxCocoa

private struct Constants {
    static let cellWidth: CGFloat = UIScreen.main.bounds.size.width/3
    static let cellHeight: CGFloat = 60
}

class DialKeyboardView: UIView, View {
    var disposeBag: DisposeBag = DisposeBag()
    private let headerView = UIView()
    fileprivate lazy var dialLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 20)
        instance.textColor = UIColor(hexString: "#020037")
        instance.textAlignment = .center
        return instance
    }()
    fileprivate lazy var inviteLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12)
        instance.textColor = UIColor(hexString: "#BBC0CA")
        instance.isHidden = true
        instance.textAlignment = .center
        instance.text = "该用户未注册"
        return instance
    }()
    private lazy var horizonline1: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E3E5E6")
        return instance
    }()
    private lazy var horizonline2: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E3E5E6")
        return instance
    }()
    private lazy var verticalline1: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E3E5E6")
        return instance
    }()
    private lazy var verticalline2: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E3E5E6")
        return instance
    }()
    fileprivate lazy var hideButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.dial_hide_icon(), for: .normal)
        instance.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        return instance
    }()
    fileprivate lazy var dialButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.dial_calling_icon(), for: .normal)
        return instance
    }()
    private lazy var deleteButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.dial_delete_icon(), for: .normal)
        instance.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        return instance
    }()
    fileprivate lazy var inviteButton: UIButton = {
        let instance = UIButton()
        instance.setTitle("邀请", for: .normal)
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitleColor(UIColor(hexString: "#7983FE"), for: .normal)
        instance.isHidden = true
        return instance
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Constants.cellWidth, height: Constants.cellHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.backgroundColor = .white
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.isScrollEnabled = false
        instance.register(cellType: DialCollectionViewCell.self)
        return instance
    }()
    
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<DialKeyboardSection> = {
        return RxCollectionViewSectionedReloadDataSource<DialKeyboardSection> { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: DialCollectionViewCell.self)
            cell.updateCell(item: item)
            return cell
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.reactor = DialKeyboardReactor()
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(collectionView.contentSize.height)
        }
    }
    
    private func buildLayout() {
        backgroundColor = .white
        addSubview(headerView)
        headerView.addSubview(dialLabel)
        headerView.addSubview(inviteButton)
        headerView.addSubview(inviteLabel)
        addSubview(collectionView)
        addSubview(horizonline1)
        addSubview(horizonline2)
        addSubview(verticalline1)
        addSubview(verticalline2)
        addSubview(hideButton)
        addSubview(dialButton)
        addSubview(deleteButton)
        
        dialLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(100)
        }
        
        inviteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(20)
        }
        
        inviteLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(55.resize)
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(100)
        }
        
        horizonline1.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(collectionView)
        }
        
        horizonline2.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(collectionView)
        }
        
        verticalline1.snp.makeConstraints { make in
            make.top.bottom.equalTo(collectionView)
            make.width.equalTo(1)
            make.left.equalTo(self.snp.right).multipliedBy(1.0/3)
        }
        
        verticalline2.snp.makeConstraints { make in
            make.top.bottom.equalTo(collectionView)
            make.width.equalTo(1)
            make.left.equalTo(self.snp.right).multipliedBy(2.0/3)
        }
        
        dialButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(12)
            make.size.equalTo(CGSize(width: 53, height: 53))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }
        
        hideButton.snp.makeConstraints { make in
            make.centerY.equalTo(dialButton)
            make.centerX.equalTo(self.snp.right).multipliedBy(1.0/6)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalTo(dialButton)
            make.centerX.equalTo(self.snp.right).multipliedBy(5/6.0)
        }
    }
    
    func bind(reactor: DialKeyboardReactor) {
        reactor.state
            .map(\.sections)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(DialKeyboardAction.self)
            .map {
                item in
                Reactor.Action.selectKeyboard(item: item)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.inputNumber)
            .distinctUntilChanged()
            .bind(to: dialLabel.rx.text)
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .map {
                Reactor.Action.deleteItem
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base == DialKeyboardView {
    var dialNumber: Observable<String> {
        return base.dialButton.rx.tap.withLatestFrom(base.reactor!.state).map(\.inputNumber)
    }
    
    var hideDidTap: Observable<Void> {
        return base.hideButton.rx.tap.asObservable()
    }
    
    var currentInput: Observable<String> {
        return base.reactor!.state.map(\.inputNumber).distinctUntilChanged()
    }
    
    var isShowInviteButton: Binder<Bool> {
        return base.inviteButton.rx.isHidden
    }
    
    var isShowInviteLabel: Binder<Bool> {
        return base.inviteLabel.rx.isHidden
    }
    
    var inviteCurrentDidTap: Observable<String> {
        return base.inviteButton.rx.tap.withLatestFrom(base.reactor!.state).map(\.inputNumber)
    }
}
