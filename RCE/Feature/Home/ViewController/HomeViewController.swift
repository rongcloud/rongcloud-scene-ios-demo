//
//  HomeViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import XCoordinator
import SVProgressHUD
import UIKit

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
        NotificationNameShuMeiKickOut.addObserver(self, selector: #selector(onLogout))
        NotificationNameUserInfoUpdated.addObserver(self, selector: #selector(userInfoUpdated(_:)))
        RCIM.shared().connectionStatusDelegate = self
        RCCoreClient.shared().add(self)
        checkVersion()
    }
    
    @objc private func userInfoUpdated(_ notification: Notification) {
        guard let user = notification.object as? User else { return }
        userButton.kf.setImage(with: URL(string: user.portraitUrl),
                               for: .normal,
                               placeholder: R.image.default_avatar())
    }
    
    @objc private func onLogin() {
        RCMusicEngine.shareInstance().delegate = DelegateImpl.instance
        RCMusicEngine.shareInstance().player = PlayerImpl.instance
        RCMusicEngine.shareInstance().dataSource = DataSourceImpl.instance
        RCCoreClient.shared().messageBlockDelegate = self;
        userButton.kf.setImage(with: URL(string: Environment.currentUser?.portraitUrl ?? ""),
                               for: .normal,
                               placeholder: R.image.default_avatar())
        FraudProtectionTips.showFraudProtectionTips(self)
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
//        judgeLogin()
    }
    
    private func judgeLogin() {
        if Environment.businessToken.count == 0 {
            showBusinessToken()
        } else if UserDefaults.standard.authorizationKey() == nil {
            navigator(.login)
        }
        messageButton.updateDot()
    }
    
    private func checkVersion() {
        let api = RCNetworkAPI.checkVersion(platform: "iOS")
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(value):
                let info = try? JSONSerialization.jsonObject(with: value.data, options: .allowFragments) as? [String: Any]
                guard let dataMap = info?["data"] as? [String: Any] else {
                    return self.judgeLogin()
                }
                let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? NSString
                let latestVersion = dataMap["version"] as? String
                let downloadUrl = dataMap["downloadUrl"] as? String
                let forceUpgrade = dataMap["forceUpgrade"] as? Bool
                let releaseNote = dataMap["releaseNote"] as? String
                guard
                    let latestVersion = latestVersion,
                    let bundleVersion = bundleVersion,
                    let downloadUrl = downloadUrl else {
                        return self.judgeLogin()
                    }
                
                // 2.0.0 to 3.0.0 is ascending order, so ask user to update
                let versionCompare = bundleVersion.compare(latestVersion, options: .numeric)
                guard versionCompare == .orderedAscending else {
                    return self.judgeLogin()
                }
                let force = forceUpgrade ?? false
                let cancelAction = UIAlertAction(title: "取消", style: .cancel) { action in
                    self.judgeLogin()
                }
                let updateAction = UIAlertAction(title: "更新", style: .default) { action in
                    self.judgeLogin()
                    if let updateUrl = URL(string: downloadUrl) {
                        UIApplication.shared.open(updateUrl)
                    }
                }
                let alerVc = UIAlertController(title: "发现新的版本", message: releaseNote, preferredStyle: .alert)
                if !force {
                    alerVc.addAction(cancelAction)
                }
                alerVc.addAction(updateAction)
                self.present(alerVc, animated: true)
            case let .failure(error):
                print(error.localizedDescription)
                self.judgeLogin()
            }
        }
    }
    
    @objc private func messageButtonClicked() {
        navigator(.messagelist)
    }
    
    @objc private func userButtonClicked() {
        router.trigger(.promotionDetail)
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
            SVProgressHUD.showInfo(withStatus: "您已下线，请重新登录")
            UserDefaults.standard.clearLoginStatus()
            onLogout()
        default: ()
        }
    }
}


extension HomeViewController: RCIMClientReceiveMessageDelegate {
    func onReceived(_ message: RCMessage, left: Int32, object: Any) {
        if let loginDeviceMessage = message.content as? RCLoginDeviceMessage,
           let content = loginDeviceMessage.content,
           content.platform != "mobile" {
            SVProgressHUD.showInfo(withStatus: "您已下线，请重新登录")
            UserDefaults.standard.clearLoginStatus()
            RCCoreClient.shared().disconnect(true)
            DispatchQueue.main.async {
                self.onLogout()
            }
        } else if let _ = message.content as? RCShuMeiMessage {
            ShuMeiMessageHandler.handleMessage(message: message, object: nil)
        }
    }
}

extension HomeViewController: RCMessageBlockDelegate {

    func messageDidBlock(_ info: RCBlockedMessageInfo) {
        let string = "发送的消息(消息类型:\(info.type) 会话id:\(info.targetId) 消息id:\(info.blockedMsgUId) 拦截原因:\(info.blockType) 附加信息:\(info.extra))遇到敏感词被拦截"
        let controller = UIAlertController(title: "提示", message: string, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true)
    }
}

/// BusinessToken
extension HomeViewController {
    private func showBusinessToken() {
        let controller = UIAlertController(title: "提示", message: "您需要配置的 BusinessToken，请全局搜索 BusinessToken，可以找到 BusinessToken 获取方式。", preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default) { _ in  exit(10) }
        controller.addAction(action)
        present(controller, animated: true)
    }
}
