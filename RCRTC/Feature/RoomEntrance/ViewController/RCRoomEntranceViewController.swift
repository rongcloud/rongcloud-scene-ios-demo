//
//  RCRoomEntranceViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

import UIKit
import XCoordinator
import RCSceneRoom

final class RCRoomEntranceViewController: UIViewController {
    
    private var router: UnownedRouter<RCSeneRoomEntranceRoute>?
    
    var fromHomeItem: RCRoomType
    
    private lazy var titleView = RCEntranceTitleView()
    
    private lazy var backButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.back_indicator_image(), for: .normal)
        instance.addTarget(self, action: #selector(back), for: .touchUpInside)
        return instance
    }()
    
    private lazy var infoButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.exclamation_point_icon(), for: .normal)
        instance.addTarget(self, action: #selector(info), for: .touchUpInside)
        return instance
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        instance.showsHorizontalScrollIndicator = false
        instance.contentInsetAdjustmentBehavior = .never
        instance.isPagingEnabled = true
        instance.dataSource = self
        instance.delegate = self
        instance.backgroundColor = .clear
        instance.bounces = false
        return instance
    }()
    
    private lazy var otherRoomListController: RCRoomListViewController = {
        let roomList = RCRoomListViewController(router: self.router)
        return roomList
    }()
    
    private lazy var gameRoomListController: RCGameRoomListViewController = {
        let roomList = RCGameRoomListViewController(router: self.router)
        return roomList
    }()
    
    private lazy var friendController = FriendViewController()

    init(router: UnownedRouter<RCSeneRoomEntranceRoute>? = nil, fromHomeItem: RCRoomType) {
        self.fromHomeItem = fromHomeItem
        self.router = router
        super.init(nibName: nil, bundle: nil)
//        NotificationNameRoomShowMessageList.addObserver(self, selector: #selector(showMessageList(_:)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.965, green: 0.973, blue: 0.976, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        if self.fromHomeItem != .gameRoom {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        }
        navigationItem.titleView = titleView
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        titleView.set(0)
        titleView.currentIndexDidChanged = { [weak self] index in
            self?.itemSelected(index)
        }
    }
    
    deinit {
        print("Entrance deinit")
    }

    @objc private func back() {
        guard let router = self.router else {
            navigationController?.popViewController(animated: true)
            return
        }
        router.trigger(.back)
    }
     
    
    @objc private func onRoomPrivateChat(_ notification: Notification) {
        guard let info = notification.object as? String else { return }
        self.router?.trigger(.chat(userId: info))
    }
    
    @objc private func showMessageList(_ notification: Notification) {
        self.router?.trigger(.chatList)
    }
    
    
    @objc private func info() {
        var URLString = "https://doc.rongcloud.cn/voiceroom/IOS/2.X/overview"
        if SceneRoomManager.scene == RCRoomType.liveVideo.rawValue {
            URLString = "https://doc.rongcloud.cn/livevideoroom/IOS/2.X/guides/intro"
        }
        UIApplication.shared.open(URL(string: URLString)!)
    }
    
    
    private func itemSelected(_ index: Int) {
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0),
                                    at: .centeredHorizontally,
                                    animated: true)
    }
}

extension RCRoomEntranceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        var vcInCell: UIViewController?
        if indexPath.row == 0 {
            if self.fromHomeItem == .gameRoom {
                vcInCell = gameRoomListController
            } else {
                vcInCell = otherRoomListController
            }
        } else {
            vcInCell = friendController
        }
        guard let vcInCell = vcInCell else { return cell }
        setup(cell, controller:vcInCell)
        return cell
    }
    
    private func setup(_ cell: UICollectionViewCell, controller: UIViewController) {
        cell.contentView.addSubview(controller.view)
        controller.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addChild(controller)
    }
}

extension RCRoomEntranceViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        titleView.set(Int(scrollView.contentOffset.x / scrollView.bounds.width))
    }
}

extension RCRoomEntranceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
