//
//  OnlineRoomCreatorViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/9.
//

import UIKit
import SVProgressHUD
import RCSceneService

protocol OnlineRoomCreatorDelegate: AnyObject {
    func userDidInvite(userId: String, from roomId: String)
    func selectedUserDidClick(userId: String, from roomId: String)
}

class OnlineRoomCreatorViewController: UIViewController {
    weak var delegate: OnlineRoomCreatorDelegate?
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 22
        instance.clipsToBounds = true
        return instance
    }()
    private var onlineCreators = [VoiceRoomUser]()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.register(cellType: OnlineCreatorTableViewCell.self)
        instance.dataSource = self
        instance.delegate = self
        return instance
    }()
    private lazy var emptyView = VoiceRoomUserListEmptyView()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17)
        instance.textColor = .white
        instance.text = "在线房主"
        return instance
    }()
    private var roomlist = [VoiceRoom]() {
        didSet {
            emptyView.isHidden = roomlist.count > 0
        }
    }
    private var selectingUser: String?
    
    init(selectingUserId: String?, delegate: OnlineRoomCreatorDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.selectingUser = selectingUserId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        fetchOnlineCreator()
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(nameLabel)
        container.addSubview(emptyView)
        container.addSubview(tableView)
        
        container.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.67)
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.width.height.equalTo(190.resize)
        }
    }
}

extension OnlineRoomCreatorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OnlineCreatorTableViewCell.self)
        cell.updateCell(user: roomlist[indexPath.row].createUser, selectingUserId: selectingUser)
        return cell
    }
}

extension OnlineRoomCreatorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = roomlist[indexPath.row]
        if room.userId == selectingUser {
            delegate?.selectedUserDidClick(userId: room.userId, from: room.roomId)
        } else {
            delegate?.userDidInvite(userId: room.userId, from: room.roomId)
            dismiss(animated: true, completion: nil)
        }
    }
}

extension OnlineRoomCreatorViewController {
    func fetchOnlineCreator() {
        voiceRoomService.onlineCreator { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                if let model = try? JSONDecoder().decode(OnlineRoomList.self, from: response.data) {
                    self.roomlist = model.data
                    self.tableView.reloadData()
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}
