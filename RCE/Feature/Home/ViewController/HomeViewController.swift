//
//  HomeViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import UIKit
import ReactorKit
import RxDataSources
import RxCocoa

private struct Constants {
    static let itemPadding: CGFloat = 16.resize
    static let contentInset: CGFloat = 20.resize
    static let itemSize: CGFloat = (UIScreen.main.bounds.width - itemPadding - contentInset * 2)/2
}

class HomeViewController: UIViewController, View {
    
    typealias Reactor = HomeReactor
    var disposeBag: DisposeBag = DisposeBag()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.itemPadding
        layout.minimumInteritemSpacing = Constants.itemPadding
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.register(cellType: HomeCollectionViewCell.self)
        instance.register(cellType: HomeMainCollectionViewCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.contentInsetAdjustmentBehavior = .never
        instance.backgroundColor = .clear
        instance.contentInset = UIEdgeInsets(top: 37, left: Constants.contentInset, bottom: 0, right: Constants.contentInset)
        return instance
    }()
    private lazy var userButton: UIButton = {
        let instance = UIButton()
        instance.frame = CGRect(origin: .zero, size: CGSize(width: 32, height: 32))
        instance.layer.cornerRadius = 16
        instance.clipsToBounds = true
        instance.imageView?.contentMode = .scaleAspectFill
        return instance
    }()
    private lazy var messageButton = HomeMessageButton(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<HomeSection> = {
        return RxCollectionViewSectionedReloadDataSource<HomeSection> { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: HomeMainCollectionViewCell.self)
                cell.updateCell(item: item)
                return cell
            }
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: HomeCollectionViewCell.self)
            cell.updateCell(item: item)
            return cell
        }
    }()
    init() {
        super.init(nibName: nil, bundle: nil)
        self.reactor = HomeReactor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        NotificationNameLogin.addObserver(self, selector: #selector(onLogin))
        NotificationNameLogout.addObserver(self, selector: #selector(onLogout))
        NotificationNameUserInfoUpdated.addObserver(self, selector: #selector(userInfoUpdated(_:)))
        RCCoreClient.shared().setRCConnectionStatusChangeDelegate(self)
    }
    
    @objc private func userInfoUpdated(_ notification: Notification) {
        guard let user = notification.object as? User else {
            return
        }
        userButton.kf.setImage(with: URL(string: user.portraitUrl),
                               for: .normal,
                               placeholder: R.image.default_avatar())
    }
    
    @objc private func onLogin() {
        userButton.kf.setImage(with: URL(string: Environment.currentUser?.portraitUrl ?? ""), for: .normal, placeholder: R.image.default_avatar())
    }
    
    @objc private func onLogout() {
        if let presented = presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.onLogout()
            }
            return
        }
        navigationController?.popToRootViewController(animated: true)
        navigator(.login)
        RCVoiceRoomEngine.sharedInstance().leaveRoom({}, error: { _, _ in})
    }
    
    private func buildLayout() {
        title = "融云RTC"
        view.backgroundColor = UIColor(hexInt: 0xF6F8F9)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        userButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        userButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageButton)
        userButton.kf.setImage(with: URL(string: Environment.currentUser?.portraitUrl ?? ""), for: .normal, placeholder: R.image.default_avatar())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.authorizationKey() == nil {
            navigator(.login)
        }
        messageButton.updateDot()
    }
    
    func bind(reactor: HomeReactor) {
        reactor.state
            .map(\.sections)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: {
            [weak self] value in
            guard let self = self else { return }
            if value.row == 0 {
                self.navigator(.voiceRoomList)
            }
        }).disposed(by: disposeBag)
        
        messageButton.rx.tap.subscribe(onNext: {
            [weak self] value in
            guard let self = self else { return }
            self.navigator(.messagelist)
        }).disposed(by: disposeBag)

        userButton.rx
            .tap
            .subscribe(onNext: { [weak self] in
                self?.navigator(.userInfoEdit)
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            let cellWidth = UIScreen.main.bounds.width - Constants.contentInset * 2
            return CGSize(width: cellWidth, height: cellWidth * 173 / 335)
        }
        let cellWidth = (UIScreen.main.bounds.width - Constants.contentInset * 2 - Constants.itemPadding)/2
        return CGSize(width: cellWidth, height: cellWidth * 225 / 160)
    }
}

extension HomeViewController: RCConnectionStatusChangeDelegate {
    func onConnectionStatusChanged(_ status: RCConnectionStatus) {
        print("status: \(status.rawValue)")
        switch status {
        case .ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:
            onLogout()
        default: ()
        }
    }
}
