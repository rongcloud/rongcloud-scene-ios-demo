//
//  VoiceRoomGiftViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/25.
//

import UIKit
import SVProgressHUD

protocol VoiceRoomGiftViewControllerDelegate: AnyObject {
    func didSendGift(message: RCMessageContent)
}

struct VoiceRoomGiftDependency {
    let room: VoiceRoom
    let seats: [RCVoiceSeatInfo]
    let userIds: [String]
    var roomId: String { room.roomId }
    var roomUserId: String { room.userId }
}

final class VoiceRoomGiftViewController: UIViewController {
    private let dependency: VoiceRoomGiftDependency
    private weak var delegate: VoiceRoomGiftViewControllerDelegate?
    
    private lazy var gestureView = UIView()
    
    private lazy var containerView = UIView()
    private lazy var effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        return UIVisualEffectView(effect: blurEffect)
    }()
    private lazy var seatsView = VoiceRoomGiftSeatsView()
    private lazy var giftsView = VoiceRoomGiftListView()
    private lazy var sendView = VoiceRoomGiftSendView(self)
    private var gift: VoiceRoomGift? {
        didSet {
            sendView.isEnabled = gift != nil && seats.count > 0
        }
    }
    private var seats: [VoiceRoomGiftSeat] = []{
        didSet {
            sendView.isEnabled = gift != nil && seats.count > 0
        }
    }
    
    init(dependency: VoiceRoomGiftDependency, delegate: VoiceRoomGiftViewControllerDelegate) {
        self.dependency = dependency
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        setupUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        gestureView.addGestureRecognizer(tapGesture)
        
        fetchUsersInfo()
    }
    
    private func fetchUsersInfo() {
        let userIds = dependency.userIds
        var users = [VoiceRoomGiftSeat]()
        var left = userIds.count {
            didSet {
                guard left <= 0, users.count > 0 else { return }
                users[0].setSelected(true)
                seatsView.set(users)
            }
        }
        userIds.forEach { userId in
            UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
                guard let self = self else { return }
                let index = self.dependency.seats.firstIndex(where: { $0.userId == userId })
                var mark = self.dependency.room.userId == userId ? "房主" : "观众"
                if let userIndex = index {
                    mark = self.dependency.room.userId == userId ? "房主" : "\(userIndex)"
                }
                let seatUser = VoiceRoomGiftSeat(userId: user.userId,
                                                 userAvatar: user.portraitUrl,
                                                 userMark: mark,
                                                 isSelected: false)
                users.append(seatUser)
                left -= 1
            }
        }
    }
    
    @objc private func tap(_ gesture: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func send() {
        guard let gift = gift else {
            return SVProgressHUD.showError(withStatus: "请选择礼物")
        }
        let seats = seats
        guard seats.count > 0 else {
            return SVProgressHUD.showError(withStatus: "请选择您要送礼物的对象")
        }
        guard sendView.count > 0 else {
            return SVProgressHUD.showError(withStatus: "请选择礼物数量")
        }
        let count = sendView.count
        SVProgressHUD.show(withStatus: "礼物赠送中...")
        var successSeats = [VoiceRoomGiftSeat]()
        var left = seats.count
        seats.forEach { seat in
            let api = RCNetworkAPI.sendGift(roomId: dependency.roomId, giftId: gift.id, toUid: seat.userId, num: count)
            networkProvider.request(api) { [weak self] result in
                switch result {
                case let .success(res):
                    if let value = try? res.mapJSON() as? [String: Any], value["code"] as? Int == 10000 {
                        print("value: \(value)")
                        successSeats.append(seat)
                    }
                case let.failure(error):
                    print(error.localizedDescription)
                }
                left -= 1
                if left <= 0 {
                    if successSeats.count == 0 {
                        SVProgressHUD.showError(withStatus: "赠送失败")
                    } else {
                        self?.sendMessage(successSeats)
                        SVProgressHUD.showSuccess(withStatus: "赠送成功")
                    }
                }
            }
        }
    }
    
    private func sendMessage(_ seats: [VoiceRoomGiftSeat]) {
        guard let gift = gift else { return }
        guard seats.count > 0 else { return }
        guard sendView.count > 0 else { return }
        let room = dependency.room
        let count = sendView.count
        let isAll = seats.count > 1 && seats.count >= dependency.userIds.count
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
            if isAll {
                let event = RCChatroomGiftAll()
                event.userId = user.userId
                event.userName = user.userName
                event.giftId = gift.id
                event.giftName = gift.name
                event.number = count
                event.price = gift.price
                ChatroomSendMessage(event) { result in
                    switch result {
                    case .success: self?.delegate?.didSendGift(message: event)
                    case .failure: ()
                    }
                }
                RCGiftBroadcastMessage.sendMessageAllIfNeeded(event, room: room)
            } else {
                for seat in seats {
                    UserInfoDownloaded.shared.fetchUserInfo(userId: seat.userId) { [weak self] target in
                        let event = RCChatroomGift()
                        event.userId = user.userId
                        event.userName = user.userName
                        event.targetId = target.userId
                        event.targetName = target.userName
                        event.giftId = gift.id
                        event.giftName = gift.name
                        event.number = count
                        event.price = gift.price
                        ChatroomSendMessage(event) { result in
                            switch result {
                            case .success: self?.delegate?.didSendGift(message: event)
                            case .failure: ()
                            }
                        }
                        RCGiftBroadcastMessage.sendMessageIfNeeded(event, room: room)
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

extension VoiceRoomGiftViewController {
    private func setupConstraints() {
        view.addSubview(gestureView)
        view.addSubview(containerView)
        containerView.addSubview(effectView)
        containerView.addSubview(giftsView)
        containerView.addSubview(seatsView)
        containerView.addSubview(sendView)
        
        gestureView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top)
        }
        
        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-347.resize)
        }
        
        effectView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(49.resize)
        }
        
        seatsView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(49.resize)
        }
        
        giftsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(seatsView.snp.bottom)
            make.height.equalTo(249.resize)
        }
        
        sendView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12.resize)
            make.top.equalTo(giftsView.snp.bottom).offset(12.resize)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        giftsView.delegate = self
        seatsView.delegate = self
    }
}

extension VoiceRoomGiftViewController: VoiceRoomGiftListViewDelegate {
    func giftListView(_ view: VoiceRoomGiftListView, didSelected gift: VoiceRoomGift) {
        self.gift = gift
    }
}

extension VoiceRoomGiftViewController: VoiceRoomGiftSeatsViewDelegate {
    func giftSeatsView(_ view: VoiceRoomGiftSeatsView, didSelected seats: [VoiceRoomGiftSeat]) {
        self.seats = seats
    }
}

extension VoiceRoomGiftViewController: VoiceRoomGiftSendViewDelegate {
    func onGiftSendButtonClicked() {
        send()
    }
    func onGiftCountButtonClicked() {
        navigator(.giftCount(sendView: sendView))
    }
}
