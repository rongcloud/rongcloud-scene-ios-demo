//
//  HomeViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import XCoordinator
import SVProgressHUD

private struct Constants {
    static let itemPadding: CGFloat = 16.resize
    static let contentInset: CGFloat = 20.resize
    static let itemSize: CGFloat = (UIScreen.main.bounds.width - itemPadding - contentInset * 2)/2
    static let edge = UIEdgeInsets(top: contentInset,
                                   left: contentInset,
                                   bottom: contentInset,
                                   right: contentInset)
}

class HomeViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.itemPadding
        layout.minimumInteritemSpacing = Constants.itemPadding
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.register(cellType: HomeCollectionViewCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.contentInsetAdjustmentBehavior = .never
        instance.backgroundColor = .clear
        instance.contentInset = Constants.edge
        instance.dataSource = self
        instance.delegate = self
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
    private lazy var messageButton = HomeMessageButton()
    private var items = HomeItem.allCases
    private let router: UnownedRouter<HomeRouter>
    
    init(router: UnownedRouter<HomeRouter>) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
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
        RCIM.shared().connectionStatusDelegate = self
    }
    
    @objc private func userInfoUpdated(_ notification: Notification) {
        guard let user = notification.object as? User else { return }
        userButton.kf.setImage(with: URL(string: user.portraitUrl),
                               for: .normal,
                               placeholder: R.image.default_avatar())
    }
    
    @objc private func onLogin() {
        userButton.kf.setImage(with: URL(string: Environment.currentUser?.portraitUrl ?? ""),
                               for: .normal,
                               placeholder: R.image.default_avatar())
    }
    
    @objc private func onLogout() {
        if let presented = presentedViewController {
            return presented.dismiss(animated: false) { [unowned self] in onLogout() }
        }
        navigationController?.popToRootViewController(animated: true)
        navigator(.login)
        SceneRoomManager.shared.leave { _ in }
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userButton)
        userButton.addTarget(self, action: #selector(userButtonClicked), for: .touchUpInside)
        userButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        userButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        userButton.kf.setImage(with: URL(string: Environment.currentUser?.portraitUrl ?? ""),
                               for: .normal, placeholder: R.image.default_avatar())
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageButton)
        messageButton.addTarget(self, action: #selector(messageButtonClicked), for: .touchUpInside)
        messageButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.authorizationKey() == nil {
            navigator(.login)
        }
        messageButton.updateDot()
    }
    
    @objc private func messageButtonClicked() {
        navigator(.messagelist)
    }
    
    @objc private func userButtonClicked() {
        navigator(.promotionDetail)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView
            .dequeueReusableCell(for: indexPath, cellType: HomeCollectionViewCell.self)
            .updateCell(item: items[indexPath.item])
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        SceneRoomManager.scene = item
        switch item {
        case .audioRoom: router.trigger(.voiceRoom)
        case .radioRoom: router.trigger(.radioRoom)
        case .audioCall: enterCallIfAvailable(item)
        case .videoCall: enterCallIfAvailable(item)
        case .liveVideo: router.trigger(.liveVideo)
        }
        item.umengEvent.trigger()
    }
    
    private func enterCallIfAvailable(_ item: HomeItem) {
        guard RCRoomFloatingManager.shared.controller == nil else {
            return SVProgressHUD.showInfo(withStatus: "请先退出房间，再进行通话")
        }
        switch item {
        case .audioCall: router.trigger(.audioCall)
        case .videoCall: router.trigger(.videoCall)
        default: ()
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.item]
        switch item {
        case .audioRoom:
            let cellWidth = collectionView.bounds.width - Constants.contentInset * 2
            return CGSize(width: floor(cellWidth), height: floor(cellWidth / 333 * 157))
        case .audioCall, .videoCall, .radioRoom, .liveVideo:
            let cellWidth = (collectionView.bounds.width - Constants.contentInset * 2 - Constants.itemPadding)/2
            return CGSize(width: floor(cellWidth), height: floor(cellWidth / 158 * 195))
        }
    }
}

extension HomeViewController: RCIMConnectionStatusDelegate {
    func onRCIMConnectionStatusChanged(_ status: RCConnectionStatus) {
        print("status: \(status.rawValue)")
        switch status {
        case .ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:
            UserDefaults.standard.clearLoginStatus()
            onLogout()
        default: ()
        }
    }
}
