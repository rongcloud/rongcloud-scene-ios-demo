//
//  FriendListViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/2.
//

import SVProgressHUD
import MJRefresh

import RCSceneVoiceRoom

enum FriendType: Int {
    case follow = 1
    case fans = 2
}

final class FriendListViewController: UIViewController {
    
    private lazy var header = MJRefreshNormalHeader(refreshingTarget: self,
                                                    refreshingAction: #selector(refreshList))
    private lazy var footer = MJRefreshBackNormalFooter(refreshingTarget: self,
                                                        refreshingAction: #selector(loadMore))
    
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.register(cellType: FriendCell.self)
        instance.separatorStyle = .none
        instance.backgroundColor = .clear
        instance.contentInsetAdjustmentBehavior = .never
        instance.showsVerticalScrollIndicator = false
        instance.dataSource = self
        instance.delegate = self
        instance.mj_header = header
        instance.mj_footer = footer
        return instance
    }()
    private var items: [RCSceneRoomUser] = [] {
        didSet {
            emptyLabel.isHidden = items.count > 0
            tableView.reloadData()
        }
    }
    private lazy var emptyLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .lightGray
        instance.text = "列表为空"
        instance.font = .systemFont(ofSize: 16)
        return instance
    }()
    
    private var currentPage: Int = 1
    
    private let type: FriendType
    init(_ type: FriendType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstriants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        header.beginRefreshing()
        refreshList()
    }
    
    @objc func refreshList() {
        currentPage = 1
        friendListNetService.followList(page: currentPage, type: type.rawValue) { [weak self] result in
            self?.header.endRefreshing()
            switch result.map(FriendListWrapper.self) {
            case let .success(wrapper):
                self?.currentPage += 1
                var list = [RCSceneRoomUser]()
                for var user in wrapper.data.list {
                    user.relation = user.status
                    list.append(user)
                }
                self?.items = list
                if wrapper.data.total >= wrapper.data.list.count {
                    self?.footer.state = .noMoreData
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    @objc private func loadMore() {
        friendListNetService.followList(page: currentPage, type: type.rawValue) { [weak self] result in
            self?.footer.endRefreshing()
            switch result.map(FriendListWrapper.self) {
            case let .success(wrapper):
                self?.currentPage += 1
                var list = [RCSceneRoomUser]()
                for var user in wrapper.data.list {
                    user.relation = user.status
                    list.append(user)
                }
                self?.items.append(contentsOf: list)
                if wrapper.data.list.count == 0 {
                    self?.footer.state = .noMoreData
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}

extension FriendListViewController {
    private func setupConstriants() {
        view.backgroundColor = UIColor(red: 0.965, green: 0.973, blue: 0.976, alpha: 1)
        view.addSubview(emptyLabel)
        view.addSubview(tableView)
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension FriendListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView
            .dequeueReusableCell(for: indexPath, cellType: FriendCell.self)
            .update(items[indexPath.row], type: type, delegate: self)
    }
}

extension FriendListViewController: UITableViewDelegate {
    
}

extension FriendListViewController: FriendCellDelegate {
    func didClickAvatar(_ user: RCSceneRoomUser) {
        let controller = FriendCardViewController(user.userId)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true, completion: nil)
    }
    
    /// 回关
    func didClickFollow(_ user: RCSceneRoomUser, value: Int) {
        SVProgressHUD.show()
        friendListNetService.follow(userId: user.userId) { [weak self] result in
            switch result.map(RCSceneResponse.self) {
            case let .success(res):
                if res.validate() {
                    SVProgressHUD.dismiss(withDelay: 0.3)
                    self?.onFollow(user, value: value)
                } else {
                    SVProgressHUD.showError(withStatus: "网络请求失败")
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    private func onFollow(_ user: RCSceneRoomUser, value: Int) {
        guard let index = items.firstIndex(where: { $0.userId == user.userId }) else {
            return
        }
        items[index].set(value)
        RCSceneUserManager.shared.updateLocalCache(items[index])
    }
}
