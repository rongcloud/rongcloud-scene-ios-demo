//
//  RCGameRoomListViewController.swift
//  RCE
//
//  Created by johankoi on 2022/5/14.
//

import MJRefresh
import SVProgressHUD
import RCSceneRoom
import RCSceneGameRoom
import XCoordinator
import UIKit
import Kingfisher

final class RCGameRoomListViewController: UIViewController, CreateGameRoomProtocol {
    
    private lazy var headerView: RCGameSelectView = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 146)
        let instance = RCGameSelectView(frame: frame, delete: self)
        instance.backgroundColor = UIColor(hexString: "#E8F0F3")
        return instance
    }()
    
    var genderDatas = ["不限男女","男", "女"]

    private lazy var dropMenuView: RCDropMenuView = {
        let instance = RCDropMenuView(menuOrigin: CGPoint(x: 0, y: 146), menuHeight: 45)
        instance.dataSource = self
        instance.delegate = self
        instance.backgroundColor = UIColor(hexString: "#E8F0F3")
        return instance
    }()
    
    private lazy var refreshHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
    private lazy var refreshFooter = MJRefreshBackNormalFooter(refreshingTarget: self,
                                                               refreshingAction: #selector(more))

    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.register(cellType: RCGameTableViewCell.self)
        instance.mj_header = refreshHeader
        instance.mj_footer = refreshFooter
        instance.separatorStyle = .none
        instance.backgroundColor = .clear
        instance.contentInsetAdjustmentBehavior = .never
        instance.showsVerticalScrollIndicator = false
        instance.dataSource = self
        instance.delegate = self
        if #available(iOS 15.0, *) {
            instance.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        };
        return instance
    }()
    private lazy var emptyView = GameRoomlistEmptyView()
    
    private lazy var plusButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.create_voice_room_icon(), for: .normal)
        instance.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
        return instance
    }()
    
    var gameItems = [RCSceneGameResp]()
    
    var type: Int {
        return 4
    }
    
    var gender: String = ""
    var gameId: String = ""
    
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
        let isDebug = AppConfigs.ENVDefine == "debug"
        RCGameEngineInit(isDebug:isDebug)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false;
        getGameInfo()
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        showFeedbackIfNeeded()
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

    func serverCreateRoomOver(roomInfo: RCSceneRoom) {
        guard let backgroundUrl = URL(string: roomInfo.gameResp?.loadingPic ?? "")  else {
            return
        }
        SVProgressHUD.show()
        KingfisherManager.shared.downloader.downloadImage(with: backgroundUrl, options: [.memoryCacheExpiration(.expired)]) { result in
            switch result {
            case let .success(imageLoadingResult):
                SVProgressHUD.dismiss()
                let controller = RCGameRoomController(room: roomInfo, creation: true, preloadBgImage: imageLoadingResult.image)
                self.navigationController?.navigationBar.isHidden = true;
                self.navigationController?.pushViewController(controller, animated: true)
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.errorDescription)
            }
        }
    }
    
    
    private func enterExsit(roomInfo: RCSceneRoom) {
        // 刷新房间信息
        roomProvider.request(.roomInfo(roomId: roomInfo.roomId)) { result in
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(wrapper):
                if let info = wrapper.data {
                    guard let backgroundUrl = URL(string: info.gameResp?.loadingPic ?? "")  else {
                        return
                    }
                    SVProgressHUD.show()
                    KingfisherManager.shared.downloader.downloadImage(with: backgroundUrl, options: [.memoryCacheExpiration(.expired)]) { result in
                        switch result {
                        case let .success(imageLoadingResult):
                            SVProgressHUD.dismiss()
                            let controller = RCGameRoomController(room: info, creation: false, preloadBgImage: imageLoadingResult.image)
                            self.navigationController?.navigationBar.isHidden = true;
                            self.navigationController?.pushViewController(controller, animated: true)
                            
                        case let .failure(error):
                            SVProgressHUD.showError(withStatus: error.errorDescription)
                        }
                    }
                } else {
                    SVProgressHUD.showError(withStatus: "房间不存在，请刷新")
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
        
    
    
    
    @objc private func plusButtonClicked() {
        // 检测房间是否已经创建
        let api = RCNetworkAPI.checkCreatedRoom(type: 4)
        SVProgressHUD.show()
        networkProvider.request(api) { result in
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(wrapper):
                SVProgressHUD.dismiss()
                if let room = wrapper.data {
                    self.didCreateAlert(room)
                } else {
                    self.presentCreateVc()
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    private func presentCreateVc() {
        let controller = CreateGameRoomViewController()
        controller.delegate = self
        navigationController?.present(controller, animated: true)
    }
    
    private func didCreateAlert(_ room: RCSceneRoom) {
        let message = "您已有游戏房间，是否现在进入？"
        let controller = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "确定", style: .default) { UIAlertAction in
            self.enterExsit(roomInfo: room)
        }
        controller.addAction(sureAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    deinit {
        print("VRLVC deinit")
    }
}

extension RCGameRoomListViewController {
    private func buildLayout() {
        view.backgroundColor = UIColor(hexString: "#E8F0F3")
        view.addSubview(emptyView)
        view.addSubview(tableView)
        view.addSubview(plusButton)
        
        tableView.tableHeaderView = headerView
        
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyView.isHidden = true
        
        plusButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(17)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-22)
        }
    }
    
    func getGameInfo() {
        getGameList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(list):
                let unlimitResp = RCSceneGameResp(gameId: "", gameDesc: "", gameMode: -1, gameName: "不限游戏", loadingPic: "", maxSeat: -1, minSeat: -1, thumbnail: "")
                let resultList = [unlimitResp] + list
                self.gameItems = resultList
                self.headerView.update(gameModels: list)
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}

extension RCGameRoomListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dropMenuView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView
            .dequeueReusableCell(for: indexPath, cellType: RCGameTableViewCell.self)
            .updateCell(room: items[indexPath.row])
    }
}

extension RCGameRoomListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let roomInfo = items[indexPath.row]
        if roomInfo.isPrivate == 1 {
            if roomInfo.userId == Environment.currentUserId { // 房主不需要密码
                self.enterExsit(roomInfo: roomInfo)
            } else {
                self.router?.trigger(.inputPassword({ [weak self] password in
                    guard password == roomInfo.password else {
                        return SVProgressHUD.showError(withStatus: "密码错误")
                    }
                    self?.enterExsit(roomInfo: roomInfo)
                }))
            }
        } else {
            self.enterExsit(roomInfo: roomInfo)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
}

extension RCGameRoomListViewController: RCDropMenuViewDelegate {
    func menu(_ menu: RCDropMenuView, didSelectRowAtIndexPath index: RCDropMenuView.Index) {
        print(index.column, index.row)
        tableView.isScrollEnabled = true
        plusButton.isEnabled = true
        if index.column == 0 {
            gender = genderDatas[index.row]
        } else {
            gameId = gameItems[index.row].gameId
        }
        refresh()
    }
}


extension RCGameRoomListViewController: RCGameSelectViewDelegate {
    func didSelect(game: RCSceneGameResp) {
        gameRoomProvider.request(.fastJoin(gameId: game.gameId)) { result in
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(wrapper):
                if let roomInfo = wrapper.data { // 存在游戏对应的房间
                    self.enterExistRoomForFastSelectGame(roomInfo: roomInfo)
                } else { // 不存在游戏对应的房间
                    self.findRoomForFastJoin(game: game)
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    func enterExistRoomForFastSelectGame(roomInfo: RCSceneRoom) {
        // 刷新房间信息
        roomProvider.request(.roomInfo(roomId: roomInfo.roomId)) { result in
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(wrapper):
                if let info = wrapper.data {
                    guard let backgroundUrl = URL(string: info.gameResp?.loadingPic ?? "")  else {
                        return
                    }
                    SVProgressHUD.show()
                    KingfisherManager.shared.downloader.downloadImage(with: backgroundUrl, options: [.memoryCacheExpiration(.expired)]) { result in
                        switch result {
                        case let .success(imageLoadingResult):
                            SVProgressHUD.dismiss()
                            let controller = RCGameRoomController(room: info, creation: false, preloadBgImage: imageLoadingResult.image, isFastIn: true)
                            self.navigationController?.navigationBar.isHidden = true;
                            self.navigationController?.pushViewController(controller, animated: true)
                            
                        case let .failure(error):
                            SVProgressHUD.showError(withStatus: error.errorDescription)
                        }
                    }
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    
    func findRoomForFastJoin(game: RCSceneGameResp) {
        gameRoomProvider.request(.createGameRoom(name: "快来和我一起互动吧!", themePictureUrl: "", backgroundUrl: "", kv: [], isPrivate: 0, password: "", roomType: 4, gameId: game.gameId)) { result in
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(wrapper):
                if let roomInfo = wrapper.data {
                    if wrapper.code == 30016 { // 登陆用户已经有创建的房间
                        self.existRoomForFastJoin(roomInfo: roomInfo, newGame: game)
                    } else { // 房间不存在
                        self.createNewRoomForFastJoin(roomInfo: roomInfo)
                    }
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    func existRoomForFastJoin(roomInfo: RCSceneRoom, newGame: RCSceneGameResp) {
        guard let backgroundUrl = URL(string: newGame.loadingPic)  else {
            return
        }
        SVProgressHUD.show()
        KingfisherManager.shared.downloader.downloadImage(with: backgroundUrl, options: [.memoryCacheExpiration(.expired)]) { result in
            switch result {
            case let .success(imageLoadingResult):
                SVProgressHUD.dismiss()
                let controller = RCGameRoomController(room: roomInfo, creation: false, preloadBgImage: imageLoadingResult.image, isFastIn: true, switchNewGame: newGame)
                self.navigationController?.navigationBar.isHidden = true;
                self.navigationController?.pushViewController(controller, animated: true)
                
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.errorDescription)
            }
        }
    }
    
    func createNewRoomForFastJoin(roomInfo: RCSceneRoom) {
        guard let backgroundUrl = URL(string: roomInfo.gameResp?.loadingPic ?? "")  else {
            return
        }
        SVProgressHUD.show()
        KingfisherManager.shared.downloader.downloadImage(with: backgroundUrl, options: [.memoryCacheExpiration(.expired)]) { result in
            switch result {
            case let .success(imageLoadingResult):
                SVProgressHUD.dismiss()
                let controller = RCGameRoomController(room: roomInfo, creation: true, preloadBgImage: imageLoadingResult.image, isFastIn: true)
                self.navigationController?.navigationBar.isHidden = true;
                self.navigationController?.pushViewController(controller, animated: true)
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.errorDescription)
            }
        }
    }
    
}

extension RCGameRoomListViewController: RCDropMenuViewDataSource {
    func numberOfColumns(in menu: RCDropMenuView) -> Int {
        return 2
    }

    func menu(_ menu: RCDropMenuView, numberOfRowsInColumn column: Int) -> Int {
        if column == 0 {
            return genderDatas.count
        } else if column == 1 {
            return gameItems.count
        }
        return 0
    }

    func menu(_ menu: RCDropMenuView, titleForRowsInIndePath index: RCDropMenuView.Index) -> String {
        switch index.column {
        case 0:
            return genderDatas[index.row]
        case 1:
            return gameItems[index.row].gameName
        default:
            return ""
        }
    }

    func menu(_ menu: RCDropMenuView, numberOfItemsInRow row: Int, inColumn: Int) -> Int {
        return 0
    }

    func menu(_ menu: RCDropMenuView, titleForItemInIndexPath indexPath: RCDropMenuView.Index) -> String {
        switch indexPath.column {
        case 0:
            return genderDatas[indexPath.row]
        case 1:
            return gameItems[indexPath.row].gameName
        default:
            return ""
        }
    }
    
    func menu(_ menu: RCDropMenuView, didClickTitleBtn column: Int, isShow: Bool) {
        tableView.contentOffset.y = headerView.height
        tableView.isScrollEnabled = false
        emptyView.isHidden = true
        plusButton.isEnabled = isShow ? false : true
    }
    
    func menu(_ menu: RCDropMenuView, cancelClickTitleBtn column: Int) {
        tableView.isScrollEnabled = true
        plusButton.isEnabled = true
        refresh()
    }
}
