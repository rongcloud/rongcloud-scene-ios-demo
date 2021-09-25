//
//  RCRoomListViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

import MJRefresh
import SVProgressHUD

var currentSceneType: HomeItem?

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
    
    private var currentPage: Int = 1
    private var type: Int {
        return currentSceneType == .audioRoom ? 1 : 2
    }
    private var items = [VoiceRoom]() {
        didSet {
            tableView.reloadData()
            emptyView.isHidden = items.count > 0
        }
    }
    private var images = [String]() {
        didSet {
            VoiceRoomManager.shared.backgroundlist = images
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        checkRoomInfo()
    }
    
    @objc private func refresh() {
        currentPage = 1
        let api = RCNetworkAPI.roomlist(type: type, page: currentPage, size: 20)
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            self.refreshHeader.endRefreshing()
            switch result.map(VoiceRoomListWrapper.self) {
            case let .success(wrapper):
                self.currentPage += 1
                self.items = wrapper.data?.rooms ?? []
                self.images = wrapper.data?.images ?? []
                if wrapper.data?.totalCount == self.items.count {
                    self.refreshFooter.state = .noMoreData
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func more() {
        let api = RCNetworkAPI.roomlist(type: type, page: currentPage, size: 20)
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            self.refreshFooter.endRefreshing()
            switch result.map(VoiceRoomListWrapper.self) {
            case let .success(wrapper):
                self.currentPage += 1
                self.items.append(contentsOf: wrapper.data?.rooms ?? [])
                if wrapper.data?.totalCount == self.items.count {
                    self.refreshFooter.state = .noMoreData
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showFeedbackIfNeeded()
    }
    
    @objc private func plusButtonClicked() {
        if let room = RCRoomFloatingManager.shared.controller?.currentRoom, room.isOwner {
            return userDidCreateRoom(room) { RCRoomFloatingManager.shared.floatingViewDidClick() }
        }
        let controller = navigator(.createRoom(imagelist: images)) as! CreateVoiceRoomViewController
        controller.onRoomCreated = { [unowned self] roomWrapper in
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
        }
    }
    
    private func didCreatedRoom(_ room: VoiceRoom) {
        let controller = RCRoomContainerViewController(create: room, dataSource: self)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func showCreatedAlert(voiceRoom: VoiceRoom) {
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
    
    private func userDidCreateRoom(_ room: VoiceRoom, onSure: @escaping () -> Void) {
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

extension RCRoomListViewController: UITableViewDelegate, VoiceRoomInputPasswordProtocol {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    private func enterRoomIfNeeded(_ rooms: [VoiceRoom], index: Int) {
        let room = rooms[index]
        if room.userId == Environment.currentUserId {
            let controller = RCRoomContainerViewController([room], index: 0, dataSource: self)
            navigationController?.pushViewController(controller, animated: true)
            return
        }
        if isAppStoreAccount {
            let filter: (VoiceRoom) -> Bool = { !$0.isOwner }
            let rooms = items.filter(filter)
            let index = rooms.firstIndex(of: room) ?? 0
            let controller = RCRoomContainerViewController(rooms, index: index, dataSource: self)
            navigationController?.pushViewController(controller, animated: true)
            return
        }
        if room.isPrivate == 0 {
            let filter: (VoiceRoom) -> Bool = { $0.switchable }
            let rooms = items.filter(filter)
            let index = rooms.firstIndex(of: room) ?? 0
            let controller = RCRoomContainerViewController(rooms, index: index, dataSource: self)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            navigator(.inputPassword(type: .verify(room), delegate: self))
        }
    }
    
    func passwordDidVarify(_ room: VoiceRoom) {
        let controller = RCRoomContainerViewController([room], index: 0, dataSource: self)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension RCRoomListViewController {
    private func showFeedbackIfNeeded() {
        guard UserDefaults.standard.shouldShowFeedback() else { return }
        navigator(.feedback)
    }
}

extension RCRoomListViewController {
    private func checkRoomInfo() {
        guard RCRoomFloatingManager.shared.controller == nil else { return }
        let api = RCNetworkAPI.checkCurrentRoom
        networkProvider.request(api) { [weak self] result in
            switch result.map(RCNetworkWapper<VoiceRoom>.self) {
            case let .success(wrapper):
                self?.onUserComeBack(wrapper.data)
            case let .failure(error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func onUserComeBack(_ room: VoiceRoom?) {
        guard let room = room else { return }
        var isRoomType: Bool {
            if room.roomType == 1 && currentSceneType == .audioRoom { return true }
            if room.roomType == 2 && currentSceneType == .radioRoom { return true }
            return false
        }
        guard isRoomType else  { return }
        let controller = UIAlertController(title: "提示", message: "您有正在直播的房间，是否进入？", preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "进入", style: .default) { [unowned self] _ in userEnter(room) }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(sureAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    private func userEnter(_ room: VoiceRoom) {
        let controller = RCRoomContainerViewController([room], index: 0, dataSource: self)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension RCRoomListViewController: RCRoomContainerDataSource {
    func container(_ controller: RCRoomContainerViewController, refresh completion: @escaping ([VoiceRoom], Bool) -> Void) {
        currentPage = 1
        let api = RCNetworkAPI.roomlist(type: type, page: currentPage, size: 20)
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            switch result.map(VoiceRoomListWrapper.self) {
            case let .success(wrapper):
                self.currentPage += 1
                self.items = wrapper.data?.rooms ?? []
                self.images = wrapper.data?.images ?? []
                if wrapper.data?.totalCount == self.items.count {
                    self.refreshFooter.state = .noMoreData
                    completion(self.items, true)
                } else {
                    completion(self.items, false)
                }
            case let .failure(error):
                print(error.localizedDescription)
                completion([], false)
            }
        }
    }
    
    func container(_ controller: RCRoomContainerViewController, more completion: @escaping ([VoiceRoom], Bool) -> Void) {
        if refreshFooter.state == .noMoreData {
            return completion(items, true)
        }
        let api = RCNetworkAPI.roomlist(type: type, page: currentPage, size: 20)
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            switch result.map(VoiceRoomListWrapper.self) {
            case let .success(wrapper):
                self.currentPage += 1
                self.items.append(contentsOf: wrapper.data?.rooms ?? [])
                if wrapper.data?.totalCount == self.items.count {
                    self.refreshFooter.state = .noMoreData
                    completion(self.items, true)
                } else {
                    completion(self.items, false)
                }
            case let .failure(error):
                print(error.localizedDescription)
                completion([], false)
            }
        }
    }
}
