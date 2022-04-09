//
//  VoiceRoomContainerViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/7/1.
//

import SVProgressHUD
import MJRefresh
import RCSceneVoiceRoom

import UIKit
import RCSceneCallKit

protocol RCRoomContainerDataSource: AnyObject {
    func container(_ controller: RCRoomContainerViewController, refresh completion: @escaping ([RCSceneRoom], Bool) -> Void)
    func container(_ controller: RCRoomContainerViewController, more completion: @escaping ([RCSceneRoom], Bool) -> Void)
}

final class RCRoomContainerViewController: UIViewController {
    
    private lazy var header = RCRefreshStateHeader { [weak self] in self?.refresh() }
    private lazy var footer = MJRefreshBackNormalFooter { [weak self] in self?.more() }
    private(set) lazy var collectionView: RCRoomContainerCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = UIScreen.main.bounds.size
        let instance = RCRoomContainerCollectionView(frame: .zero, collectionViewLayout: layout)
        instance.register(cellType: VoiceRoomContainerCell.self)
        instance.dataSource = self
        instance.delegate = self
        instance.mj_header = header
        instance.mj_footer = footer
        footer.state = .noMoreData
        instance.scrollable = roomList[currentIndex].switchable
        return instance
    }()
    
    private(set) var controller: RCRoomCycleProtocol {
        didSet {
            collectionView.descendantViews = controller.descendantViews()
        }
    }
    var currentIndex: Int {
        didSet {
            if currentIndex == oldValue { return }
            switchRoom()
        }
    }
    
    var currentRoomId: String { roomList[currentIndex].roomId }
    var currentRoom: RCSceneRoom { roomList[currentIndex] }
    var currentScene: HomeItem {
        switch roomList[currentIndex].roomType {
        case 1: return .audioRoom
        case 2: return .radioRoom
        case 3: return .liveVideo
        default: return .audioRoom
        }
    }
    
    public var roomList: [RCSceneRoom]
    private weak var dataSource: RCRoomContainerDataSource?
    init(create room: RCSceneRoom, dataSource: RCRoomContainerDataSource? = nil) {
        self.roomList = [room]
        self.currentIndex = 0
        self.dataSource = dataSource
        self.controller = room.controller(true)
        super.init(nibName: nil, bundle: nil)
        self.controller.setRoomContainerAction(action: self)
        self.controller.setRoomFloatingAction(action: RCRoomFloatingManager.shared)
    }
    
    init(_ roomList: [RCSceneRoom], index: Int, dataSource: RCRoomContainerDataSource? = nil) {
        self.roomList = roomList
        self.currentIndex = index
        self.dataSource = dataSource
        self.controller = roomList[index].controller()
        super.init(nibName: nil, bundle: nil)
        self.controller.setRoomContainerAction(action: self)
        self.controller.setRoomFloatingAction(action: RCRoomFloatingManager.shared)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
        addChild(controller)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        controller.didMove(toParent: self)
        
        collectionView.descendantViews = controller.descendantViews()
        
        DispatchQueue.main.async { [unowned self] in
            setupCollectionViewPosition()
        }
        
        navigationController?.delegate = self
        
        RCCall.shared().canIncomingCall = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        header.mj_h += view.safeAreaInsets.top
    }
    
    private func setupCollectionViewPosition() {
        collectionView.scrollToItem(at: IndexPath(row: currentIndex, section: 0),
                                    at: .centeredVertically,
                                    animated: false)
        view.layoutIfNeeded()
        
        let indexPath = IndexPath(row: currentIndex, section: 0)
        collectionView
            .cellForItem(indexPath, cellType: VoiceRoomContainerCell.self)?
            .update(roomList[currentIndex])
            .setup(controller.view)
    }
    
    public func switchRoom() {
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        controller.leaveRoom { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.joinRoom()
                }
            case let .failure(error):
                debugPrint(error.localizedDescription)
//                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    private func joinRoom() {
        controller = roomList[currentIndex].controller()
        let indexPath = IndexPath(row: currentIndex, section: 0)
        collectionView
            .cellForItem(indexPath, cellType: VoiceRoomContainerCell.self)?
            .setup(controller.view)
        addChild(controller)
        controller.didMove(toParent: self)
        controller.setRoomContainerAction(action: self)
        controller.setRoomFloatingAction(action: RCRoomFloatingManager.shared)
    }
    
    deinit {
        RCCall.shared().canIncomingCall = true
    }
}

extension RCRoomContainerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView
            .dequeueReusableCell(for: indexPath, cellType: VoiceRoomContainerCell.self)
            .update(roomList[indexPath.row])
    }
}

extension RCRoomContainerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let currentIndexPath = collectionView.indexPathsForVisibleItems.first else {
            return
        }
        currentIndex = currentIndexPath.row
        (cell as? VoiceRoomContainerCell)?.stopGiftAnimation()
    }
}

extension RCRoomContainerViewController {
    private func refresh() {
        guard currentScene == SceneRoomManager.scene else { return header.endRefreshing() }
        guard let dataSource = dataSource else { return header.endRefreshing() }
        dataSource.container(self, refresh: { [weak self] items, end in
            self?.roomListDidRefresh(items)
            if end { self?.footer.state = .noMoreData }
            self?.header.endRefreshing()
        })
    }
    
    /// 触发刷新:
    /// 必然不是房主
    /// currentIndex必然是0
    /// 如果index不是0，则上滑
    /// 如果下一个是0，则刷新
    /// 如果下一个不是0，则滚动
    private func roomListDidRefresh(_ items: [RCSceneRoom]) {
        let items = items.filter { $0.switchable }
        if items.count == 0 {
            navigationController?.popViewController(animated: true)
            return SVProgressHUD.showInfo(withStatus: "获取房间信息为空")
        }
        let room = roomList[currentIndex]
        guard isRoomListChange(items) else { return roomList = items }
        roomList = items
        collectionView.reloadData()
        let index = items.firstIndex(where: { $0.id == room.id }) ?? 0
        if index == 0 { return switchRoom() }
        let nextIndex = index - 1
        if nextIndex == 0 { return switchRoom() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(item: nextIndex, section: 0)
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
            self.currentIndex = nextIndex
        }
    }
    
    private func more() {
        guard currentScene == SceneRoomManager.scene else { return header.endRefreshing() }
        guard let dataSource = dataSource else { return }
        dataSource.container(self, more: { [weak self] items, end in
            self?.roomListDidMore(items)
            if end { self?.footer.state = .noMoreData }
        })
    }
    
    /// 触发更多:
    /// 必然不是房主
    /// currentIndex必然是roomList.count - 1
    /// 如果index不是item.count - 1，则下滑
    private func roomListDidMore(_ items: [RCSceneRoom]) {
        var tmp: [String: Int] = [:]
        let items: [RCSceneRoom] = items
            .compactMap {
                if tmp[$0.roomId] != nil { return nil }
                tmp[$0.roomId] = 1
                if $0.switchable { return $0 }
                return nil
            }
        if items.count == 0 {
            navigationController?.popViewController(animated: true)
            return SVProgressHUD.showInfo(withStatus: "获取房间信息为空")
        }
        let room = roomList[currentIndex]
        guard isRoomListChange(items) else { return roomList = items }
        roomList = items
        collectionView.reloadData()
        let index = items.firstIndex(where: { $0.id == room.id }) ?? (items.count - 1)
        let nextIndex = min(index + 1, roomList.count - 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(item: nextIndex, section: 0)
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
            if self.currentIndex == nextIndex {
                self.switchRoom()
            } else {
                self.currentIndex = nextIndex
            }
        }
    }
    
    private func fixCollectionViewPosition() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: self.currentIndex, section: 0)
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        }
    }
    
    private func isRoomListChange(_ items: [RCSceneRoom]) -> Bool {
        guard items.count == roomList.count else { return true }
        for index in (0..<items.count) {
            if items[index].id == roomList[index].id { continue }
            return true
        }
        return false
    }
}

fileprivate extension RCErrorCode {
    var desc: String {
        switch self {
        case .RC_SUCCESS: return ""
        case .RC_CHATROOM_NOT_EXIST: return "该房间直播已结束"
        default: return "获取房间信息失败"
        }
    }
}

extension RCRoomContainerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let _ = navigationController.visibleViewController as? RCRoomEntranceViewController else {
            return
        }
        guard let coordinator = navigationController.topViewController?.transitionCoordinator else {
            return
        }
        coordinator.notifyWhenInteractionChanges { context in
            if !context.isCancelled {
                RCRoomFloatingManager.shared.show(self, superView: self.view, animated: false)
            }
        }
    }
}
