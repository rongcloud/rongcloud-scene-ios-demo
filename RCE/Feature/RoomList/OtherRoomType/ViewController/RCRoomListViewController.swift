//
//  RCRoomListViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

import MJRefresh
import SVProgressHUD
import RCSceneRoom
import RCSceneVoiceRoom
import RCSceneVideoRoom
import XCoordinator

final class RCRoomListViewController: UIViewController {
    
    private lazy var refreshHeader = UIRefreshControl()
    private lazy var refreshFooter = MJRefreshBackNormalFooter(refreshingTarget: self,
                                                               refreshingAction: #selector(more))

    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.register(cellType: RoomListTableViewCell.self)
        instance.backgroundView = refreshHeader
        refreshHeader.addTarget(self, action: #selector(refresh), for: .valueChanged)
        instance.mj_footer = refreshFooter
        instance.separatorStyle = .none
        instance.backgroundColor = .clear
        instance.contentInsetAdjustmentBehavior = .never
        instance.showsVerticalScrollIndicator = false
        instance.dataSource = self
        instance.delegate = self
        return instance
    }()
    private lazy var emptyView = VoiceRoomlistEmptyView()
    private lazy var plusButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.create_voice_room_icon(), for: .normal)
        instance.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
        return instance
    }()
    
    var type: Int {
        return SceneRoomManager.scene.rawValue
    }
    var items = [RCSceneRoom]() {
        didSet {
            tableView.reloadData()
            emptyView.isHidden = items.count > 0
        }
    }
    
    private var router: UnownedRouter<RCSeneRoomEntranceRoute>?
    
    init(router: UnownedRouter<RCSeneRoomEntranceRoute>? = nil) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        checkRoomInfo()

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressedHandler(_:)))
        tableView.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showFeedbackIfNeeded()
    }
    
    @objc private func refresh() {
        refreshData { [weak self] result in
            guard let self = self else { return }
            self.refreshHeader.endRefreshing()
            switch result {
            case let .success(list):
                self.items = list.rooms
                if list.totalCount == self.items.count {
                    self.refreshFooter.state = .noMoreData
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    @objc private func more() {
        moreData { [weak self] result in
            guard let self = self else { return }
            self.refreshFooter.endRefreshing()
            switch result {
            case let .success(list):
                self.items.append(contentsOf: list.rooms)
                if list.totalCount == self.items.count {
                    self.refreshFooter.state = .noMoreData
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    @objc private func plusButtonClicked() {
        /// 检测房间是否已经创建
        let api = RCNetworkAPI.checkCreatedRoom(type: type)
        SVProgressHUD.show()
        networkProvider.request(api) { [weak self] result in
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(wrapper):
                SVProgressHUD.dismiss()
                if let room = wrapper.data {
                    self?.userDidCreateRoom(room) {
                        self?.enterUserCreation(room)
                    }
                } else {
                    self?.createRoom()
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    private func enterUserCreation(_ room: RCSceneRoom) {
        guard let currentRoom = SceneRoomManager.shared.currentRoom else {
            return enter(room)
        }
        
        guard RCRoomFloatingManager.shared.showing else {
            return enter(room)
        }
        
        guard let controller = RCRoomFloatingManager.shared.controller else {
            return enter(room)
        }
        
        if currentRoom.roomId == room.roomId {
            RCRoomFloatingManager.shared.hide()
            return show(controller, sender: self)
        }
        
        controller.controller.leaveRoom({ [weak self] result in
            self?.enter(room)
        })
    }
    
    private func createRoom() {
        
        switch SceneRoomManager.scene {
        case .liveVideo:
            if RCRoomFloatingManager.shared.showing {
                SVProgressHUD.show()
                RCRoomFloatingManager.shared.controller?.controller.leaveRoom { [unowned self] _ in
                    SVProgressHUD.dismiss(withDelay: 0.3)
                    RCRoomFloatingManager.shared.hide()
                    let controller = RCVideoRoomController(beautyPlugin: RCBeautyPlugin())
                    navigationController?.pushViewController(controller, animated: true)
                }
            } else {
                let controller = RCVideoRoomController(beautyPlugin: RCBeautyPlugin())
                navigationController?.pushViewController(controller, animated: true)
            }
            
        case .audioRoom, .radioRoom:
            self.router?.trigger(.createRoom(imagelist: SceneRoomManager.shared.backgrounds, onRoomCreate: { [unowned self] roomWrapper in
                guard let room = roomWrapper.data else { return }
                if roomWrapper.isCreated() {
                    return showCreatedAlert(voiceRoom: room)
                }
                if RCRoomFloatingManager.shared.currentRoomId == nil {
                    return didCreatedRoom(room)
                }
                SVProgressHUD.show(withStatus: "正在退出房间")
                RCRoomFloatingManager.shared.controller?.controller.leaveRoom { [unowned self] _ in
                    SVProgressHUD.dismiss(withDelay: 0.3)
                    RCRoomFloatingManager.shared.hide()
                    didCreatedRoom(room)
                }
            }))
        default: ()
        }
    }
    
    private func didCreatedRoom(_ room: RCSceneRoom) {
        let controller = RCRoomContainerViewController(create: room, dataSource: self)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func showCreatedAlert(voiceRoom: RCSceneRoom) {
        if let controller = presentedViewController {
            controller.dismiss(animated: false) { [weak self] in
                self?.showCreatedAlert(voiceRoom: voiceRoom)
            }
            return
        }
        userDidCreateRoom(voiceRoom) { [unowned self] in
            let controller = RCRoomContainerViewController([voiceRoom], index: 0, dataSource: self)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func userDidCreateRoom(_ room: RCSceneRoom, onSure: @escaping () -> Void) {
        let message = "您已创建过房间，是否现在进入？"
        let controller = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "确定", style: .default, handler: { _ in onSure() })
        controller.addAction(sureAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    deinit {
        print("VRLVC deinit")
    }
}

extension RCRoomListViewController {
    private func buildLayout() {
        view.backgroundColor = UIColor(hexInt: 0xF6F8F9)
        view.addSubview(emptyView)
        view.addSubview(tableView)
        view.addSubview(plusButton)
        
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(17)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-22)
        }
    }
}

extension RCRoomListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView
            .dequeueReusableCell(for: indexPath, cellType: RoomListTableViewCell.self)
            .updateCell(room: items[indexPath.row])
    }
}

extension RCRoomListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(indexPath)
    }
    
    private func didSelect(_ indexPath: IndexPath) {
        let room = items[indexPath.row]
        if let roomId = RCRoomFloatingManager.shared.currentRoomId {
            if roomId == room.roomId {
                RCRoomFloatingManager.shared.floatingViewDidClick()
                return
            }
            SVProgressHUD.show(withStatus: "正在退出房间")
            RCRoomFloatingManager.shared.controller?.controller.leaveRoom { [unowned self] _ in
                SVProgressHUD.dismiss(withDelay: 0.3)
                RCRoomFloatingManager.shared.hide()
                enterRoomIfNeeded(items, index: indexPath.item)
            }
            return
        }
        
        enterRoomIfNeeded(items, index: indexPath.item)
    }
    
    private func enterRoomIfNeeded(_ rooms: [RCSceneRoom], index: Int) {
        let room = rooms[index]
        if room.isOwner { return enter(room) }
        if isAppStoreAccount {
            let filter: (RCSceneRoom) -> Bool = { !$0.isOwner }
            let rooms = items.filter(filter)
            let index = rooms.firstIndex(of: room) ?? 0
            return enter(rooms, index: index)
        }
        if room.isPrivate == 0 {
            let filter: (RCSceneRoom) -> Bool = { $0.switchable }
            let rooms = items.filter(filter)
            let index = rooms.firstIndex(of: room) ?? 0
            return enter(rooms, index: index)
        }
        self.router?.trigger(.inputPassword({ [weak self] password in
            guard password == room.password else {
                return SVProgressHUD.showError(withStatus: "密码错误")
            }
            self?.enter(room)
        }))
    }
}

extension RCRoomListViewController {
    @objc private func longPressedHandler(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        let controller = UIAlertController(title: "提示", message: "请选择进入方式，之后都以此方式观看", preferredStyle: .actionSheet)
        let CDNAction = UIAlertAction(title: "CDN", style: .default) { _ in
            kVideoRoomEnableCDN = true
            self.didSelect(indexPath)
        }
        let RTCAction = UIAlertAction(title: "RTC", style: .default) { _ in
            kVideoRoomEnableCDN = false
            self.didSelect(indexPath)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(CDNAction)
        controller.addAction(RTCAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
}
