//
//  RoomInfoView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import UIKit

protocol RoomInfoViewClickProtocol: AnyObject {
    func roomInfoDidClick()
}

class RoomInfoView: UIView {
    weak var delegate: RoomInfoViewClickProtocol?
    private let roomId: String
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        instance.text = "- - "
        return instance
    }()
    private lazy var idLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 9)
        instance.textColor = UIColor.white.withAlphaComponent(0.7)
        instance.text = "ID - -"
        return instance
    }()
    private lazy var yellowDotView: UIView = {
        let instance = UIView()
        instance.backgroundColor = R.color.hexF8E71C()
        instance.layer.cornerRadius = 2
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var onlineMemberLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 9)
        instance.textColor = UIColor.white.withAlphaComponent(0.7)
        instance.text = "在线 - "
        return instance
    }()
    private lazy var networkImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.network_speed_fine()
        return instance
    }()
    private lazy var networkLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 9)
        instance.textColor = .white.withAlphaComponent(0.7)
        return instance
    }()
    
    init(roomId: String, networkEnable: Bool = true) {
        self.roomId = roomId
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        addSubview(nameLabel)
        addSubview(idLabel)
        addSubview(yellowDotView)
        addSubview(onlineMemberLabel)
        backgroundColor = UIColor.white.withAlphaComponent(0.25)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleViewClick))
        addGestureRecognizer(tap)
        nameLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(12.resize)
            $0.top.equalToSuperview().offset(6.resize)
        }
        
        idLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(1)
            $0.left.equalTo(nameLabel)
            $0.bottom.equalToSuperview().inset(6.resize)
        }
        
        yellowDotView.snp.makeConstraints {
            $0.centerY.equalTo(idLabel)
            $0.size.equalTo(CGSize(width: 4, height: 4))
            $0.left.equalTo(idLabel.snp.right).offset(10.resize)
        }
        
        if networkEnable {
            onlineMemberLabel.snp.makeConstraints {
                $0.centerY.equalTo(yellowDotView)
                $0.left.equalTo(yellowDotView.snp.right).offset(3)
            }
            
            addSubview(networkImageView)
            addSubview(networkLabel)
            
            networkImageView.snp.makeConstraints { make in
                make.left.equalTo(onlineMemberLabel.snp.right).offset(10.resize)
                make.centerY.equalTo(onlineMemberLabel)
            }
            
            networkLabel.snp.makeConstraints { make in
                make.left.equalTo(networkImageView.snp.right).offset(3)
                make.centerY.equalTo(networkImageView)
                make.right.equalToSuperview().inset(27.resize)
            }
        } else {
            onlineMemberLabel.snp.makeConstraints {
                $0.centerY.equalTo(yellowDotView)
                $0.left.equalTo(yellowDotView.snp.right).offset(3)
                $0.right.equalToSuperview().inset(27.resize)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topRight, .bottomRight], radius: 20.0)
    }
    
    public func updateRoom(info: VoiceRoom) {
        nameLabel.text = info.roomName
        idLabel.text = "ID " + String(info.id)
        updateRoomUserNumber()
    }
    
    public func updateRoomUserNumber() {
        RCChatRoomClient.shared()
            .getChatRoomInfo(roomId, count: 0, order: .chatRoom_Member_Asc) { info in
                DispatchQueue.main.async {
                    self.onlineMemberLabel.text = "在线 \(info.totalMemberCount)"
                    self.layoutIfNeeded()
                }
            } error: { _ in }
    }
    
    @objc func handleViewClick() {
        delegate?.roomInfoDidClick()
    }
    
    public func updateNetworking(rtt: NSInteger) {
        switch rtt {
        case 0...99:
            networkImageView.image = R.image.network_speed_fine()
        case 100...200:
            networkImageView.image = R.image.network_speed_soso()
        default:
            networkImageView.image = R.image.network_speed_bad()
        }
        networkLabel.text = "\(rtt)ms"
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
