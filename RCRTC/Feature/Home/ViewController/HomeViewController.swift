//
//  HomeViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import XCoordinator
import SVProgressHUD
import RongCallLib

class HomeViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let instance = UICollectionView(frame: .zero, collectionViewLayout: HomeLayout())
        instance.register(cellType: HomeCollectionViewCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.contentInsetAdjustmentBehavior = .never
        instance.backgroundColor = .clear
        instance.dataSource = self
        instance.delegate = self
        return instance
    }()
    private lazy var logoView: UIView = {
        let instance = UIView()
        
        let imageView = UIImageView(image: R.image.logo())
        instance.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(imageView.snp.height)
        }
        
        let label = UILabel()
        label.text = "融云 RTC"
        label.textColor = UIColor(byteRed: 14, green: 24, blue: 43)
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        instance.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.right.equalToSuperview()
            make.left.equalTo(imageView.snp.right).offset(8)
        }
        
        return instance
    }()
    private(set) lazy var messageButton = HomeMessageButton()
    private lazy var items: [RCRoomType] = {
        var itemArrs = RCRoomType.allCases
        let item = itemArrs[3]
        let commonSoonItem = itemArrs[7]
        itemArrs.remove(at: 3)
        itemArrs.insert(item, at: 0) //视频直播
        itemArrs.remove(at: 7)
        itemArrs.insert(commonSoonItem,at: 6) //commSoon KTV
        return itemArrs
    }()
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
        
//        NotificationNameLogin.addObserver(self, selector: #selector(onLogin))
//        NotificationNameLogout.addObserver(self, selector: #selector(onLogout))
//        NotificationNameShuMeiKickOut.addObserver(self, selector: #selector(onLogout))
//        RCIM.shared().connectionStatusDelegate = self
//        RCCoreClient.shared().add(self)
//        checkVersion()
    }
    
//    @objc func onLogin() {
//        AppConfigs.configHiFive()
//        RCCoreClient.shared().messageBlockDelegate = self;
//        FraudProtectionTips.showFraudProtectionTips(self)
//    }
    
    @objc func onLogout() {
        if let presented = presentedViewController {
            return presented.dismiss(animated: false) { [unowned self] in onLogout() }
        }
        navigationController?.popToRootViewController(animated: false)
        navigator(.login)
        RCSensor.shared?.unset("mobile")
    }
    
    private func buildLayout() {
        view.backgroundColor = UIColor(hexInt: 0xE6F0F3)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoView)
        logoView.widthAnchor.constraint(equalToConstant: 144).isActive = true
        logoView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageButton)
        messageButton.addTarget(self, action: #selector(messageButtonClicked), for: .touchUpInside)
        messageButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    @objc private func messageButtonClicked() {
        router.trigger(.chatList)
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
        SceneRoomManager.scene = item.rawValue
        switch item {
        case .audioCall, .videoCall: enterCallIfAvailable(item)
        default: router.trigger(.roomEntrance(item))
        }
        item.umengEvent.trigger()
    }
    
    private func enterCallIfAvailable(_ item: RCRoomType) {
        guard RCRoomFloatingManager.shared.controller == nil else {
            return SVProgressHUD.showInfo(withStatus: "请先退出房间，再进行通话")
        }
        router.trigger(.call(item))
    }
}
