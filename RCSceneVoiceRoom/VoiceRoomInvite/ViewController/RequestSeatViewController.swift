//
//  RequestSeatViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/7.
//

import UIKit
import SVProgressHUD
import RCSceneService

class RequestSeatViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.register(cellType: RequestSeatTableViewCell.self)
        instance.dataSource = self
        return instance
    }()
    private lazy var emptyView = VoiceRoomUserListEmptyView()
    private let acceptUserCallback:((String) -> Void)
    private var userIdlist = [String]()
    private var userlist = [VoiceRoomUser]() {
        didSet {
            emptyView.isHidden = userlist.count > 0
        }
    }
    
    init(callback: @escaping ((String) -> Void)) {
        self.acceptUserCallback = callback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40.resize)
            make.width.height.equalTo(160.resize)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        requestWaitinglist()
    }
    
    private func buildLayout() {
        view.backgroundColor = R.color.hex03062F()?.withAlphaComponent(0.5)
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.top.equalToSuperview().offset(220.resize)
        }
    }
    
    private func requestWaitinglist() {
        RCVoiceRoomEngine.sharedInstance().getRequestSeatUserIds { list in
            self.userIdlist = list
            self.fetchAllUserInfo()
        } error: { code, msg in
            SVProgressHUD.showError(withStatus: "获取排麦用户列表失败")
        }

    }
    
    private func fetchAllUserInfo() {
        voiceRoomService.usersInfo(id: self.userIdlist) { result in
            switch result.map(RCNetworkWapper<[VoiceRoomUser]>.self) {
            case let .success(wrapper):
                guard let list = wrapper.data else {return}
                self.userlist = list
                self.tableView.reloadData()
            case let .failure(error):
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension RequestSeatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: RequestSeatTableViewCell.self)
        cell.updateCell(user: userlist[indexPath.row])
        cell.acceptCallback = {
           [weak self] userId in
            self?.acceptUserCallback(userId)
        }
        return cell
    }
}
