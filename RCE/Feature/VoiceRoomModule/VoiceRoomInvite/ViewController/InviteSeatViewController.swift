//
//  InviteSeatViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/10.
//

import UIKit
import RxSwift

class InviteSeatViewController: UIViewController {
    private let roomId: String
    private var disposeBag = DisposeBag()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.register(cellType: InviteSeatTableViewCell.self)
        instance.dataSource = self
        return instance
    }()
    private lazy var emptyView = VoiceRoomUserListEmptyView()
    private var userIdlist = [String]()
    private var userlist = [VoiceRoomUser](){
        didSet {
            emptyView.isHidden = userlist.count > 0
        }
    }
    private let inviteUserCallback:((String) -> Void)
    private let onSeatUserlist: [String]
    
    init(roomId: String, onSeatUserList: [String], callback: @escaping ((String) -> Void)) {
        self.roomId = roomId
        self.inviteUserCallback = callback
        self.onSeatUserlist = onSeatUserList
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
        fetchRoomUserlist()
    }
    
    private func buildLayout() {
        view.backgroundColor = R.color.hex03062F()?.withAlphaComponent(0.5)
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.top.equalToSuperview().offset(220.resize)
        }
    }
    
    private func fetchRoomUserlist() {
        networkProvider.rx
            .request(.roomUsers(roomId: roomId))
            .asObservable()
            .filterSuccessfulStatusCodes()
            .map([VoiceRoomUser].self, atKeyPath: "data")
            .subscribe(onNext: {
                [weak self] list in
                guard let self = self else { return }
                self.userlist = list.filter({ user in
                    user.userId != Environment.currentUserId && !self.onSeatUserlist.contains(user.userId)
                })
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
    }
}

extension InviteSeatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: InviteSeatTableViewCell.self)
        cell.updateCell(user: userlist[indexPath.row])
        cell.inviteCallback = {
            [weak self] userId in
            self?.inviteUserCallback(userId)
        }
        return cell
    }
}
