//
//  HomeViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import UIKit
import XCoordinator
import SVProgressHUD

import RCSceneVoiceRoom

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
        RCIM.shared().connectionStatusDelegate = self
        RCCoreClient.shared().add(self)
        checkVersion()
    }
    
    @objc private func onLogin() {
        RCMusicEngine.shareInstance().delegate = DelegateImpl.instance
        RCMusicEngine.shareInstance().player = PlayerImpl.instance
        RCMusicEngine.shareInstance().dataSource = DataSourceImpl.instance
        RCCoreClient.shared().messageBlockDelegate = self;
        FraudProtectionTips.showFraudProtectionTips(self)
    }
    
    @objc private func onLogout() {
        if let presented = presentedViewController {
            return presented.dismiss(animated: false) { [unowned self] in onLogout() }
        }
        navigationController?.popToRootViewController(animated: false)
        navigator(.login)
//        SceneRoomManager.shared.voice_leave { _ in }
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
