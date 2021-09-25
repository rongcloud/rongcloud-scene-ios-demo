//
//  RCRTCBroadcastView.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/20.
//

import UIKit

protocol RCRTCBroadcastDelegate: AnyObject {
    func broadcastViewDidLoad(_ view: RCRTCGiftBroadcastView)
    func broadcastViewWillAppear(_ view: RCRTCGiftBroadcastView)
    func broadcastViewAccessible(_ room: VoiceRoom) -> Bool
    func broadcastViewDidClick(_ room: VoiceRoom)
}

extension RCRTCBroadcastDelegate {
    func broadcastViewWillAppear(_ view: RCRTCGiftBroadcastView) {}
}

class RCRTCGiftBroadcastView: UIView {
    private lazy var contentLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12)
        instance.textColor = .white
        instance.setContentHuggingPriority(.defaultLow, for: .horizontal)
        instance.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return instance
    }()
    private lazy var roomButton: UIButton = {
        let instance = UIButton()
        instance.setTitle("点击进入房间围观", for: .normal)
        instance.setTitleColor(UIColor(byteRed: 255, green: 235, blue: 97), for: .normal)
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.addTarget(self, action: #selector(onButtonClicked), for: .touchUpInside)
        instance.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        instance.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return instance
    }()
    private var room: VoiceRoom?
    private let broadcast: RCGiftBroadcast
    private let delegate: RCRTCBroadcastDelegate
    init(_ broadcast: RCGiftBroadcast, delegate: RCRTCBroadcastDelegate) {
        self.broadcast = broadcast
        self.delegate = delegate
        super.init(frame: .zero)
        isHidden = true
        backgroundColor = UIColor(byteRed: 73, green: 60, blue: 152)
        
        addSubview(contentLabel)
        addSubview(roomButton)
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.centerY.equalToSuperview()
        }
        
        roomButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(contentLabel.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().inset(8)
        }
        
        fetchRoomInfo()
        setupContent(broadcast)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchRoomInfo() {
        let api = RCNetworkAPI.roomInfo(roomId: broadcast.roomId)
        networkProvider.request(api) { [weak self] result in
            guard let self = self else { return }
            switch result.map(RCNetworkWapper<VoiceRoom>.self) {
            case let .success(wrapper):
                self.room = wrapper.data
                self.delegate.broadcastViewWillAppear(self)
                self.isHidden = false
            case let .failure(error):
                print(error.localizedDescription)
                self.removeFromSuperview()
            }
        }
    }
    
    private func setupContent(_ broadcast: RCGiftBroadcast) {
        let content = NSMutableAttributedString()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.65)
        ]
        let senderAttributeString = NSAttributedString(string: broadcast.userName, attributes: attributes)
        content.append(senderAttributeString)
        
        let sendAttributeString = NSAttributedString(string: " 送给 ")
        content.append(sendAttributeString)
        
        let receiverAttributeString = NSAttributedString(string: broadcast.targetName, attributes: attributes)
        content.append(receiverAttributeString)
        
        let giftAttributeString = NSAttributedString(string: " \(broadcast.giftName)x\(broadcast.giftCount)")
        content.append(giftAttributeString)
        
        contentLabel.attributedText = content
    }
    
    @objc private func onButtonClicked() {
        guard let room = room else { return }
        guard delegate.broadcastViewAccessible(room) else { return }
        if room.isPrivate == 1 {
            let controller = UIApplication.shared.keyWindow()?.rootViewController
            controller?.navigator(.inputPassword(type: .verify(room), delegate: self))
        } else {
            delegate.broadcastViewDidClick(room)
        }
    }
}

extension RCRTCGiftBroadcastView: VoiceRoomInputPasswordProtocol {
    func passwordDidVarify(_ room: VoiceRoom) {
        delegate.broadcastViewDidClick(room)
    }
}
