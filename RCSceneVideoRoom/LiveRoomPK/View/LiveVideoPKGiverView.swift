//
//  LiveVideoPKGiverView.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/30.
//

import UIKit

private struct Constants {
    static let countdown = 180
    static let leftColor = UIColor(hexString: "#E92B88")
    static let rightColor = UIColor(hexString: "#505DFF")
}

class LiveVideoPKGiverView: UIView {
    private lazy var leftStackView: UIStackView = {
        let views = (0...2).map { i in VoiceRoomPKGiftUserView(isLeft: true, rank: [3,2,1][i]) }
        let instance = UIStackView(arrangedSubviews: views)
        instance.axis = .horizontal
        instance.spacing = 12
        instance.distribution = .equalSpacing
        instance.alignment = .center
        return instance
    }()
    private lazy var rightStackView: UIStackView = {
        let views = (0...2).map { i in VoiceRoomPKGiftUserView(isLeft: false, rank: i + 1) }
        let instance = UIStackView(arrangedSubviews: views)
        instance.axis = .horizontal
        instance.spacing = 12
        instance.distribution = .equalSpacing
        instance.alignment = .center
        return instance
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(byteRed: 24, green: 25, blue: 56)
        addSubview(leftStackView)
        addSubview(rightStackView)
        
        leftStackView.snp.makeConstraints { make in
            make.left.bottom.top.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.5)
        }
        
        rightStackView.snp.makeConstraints { make in
            make.bottom.right.top.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateGiverInfo(_ model: PKGiftModel) {
        guard let PK = RCLiveVideoEngine.shared().pkInfo else { return }
        for room in model.roomScores {
            if room.userInfoList.count == 0 { continue }
            let isLeft = room.roomId == PK.roomId()
            let views = isLeft
            ? leftStackView.arrangedSubviews.reversed()
            : rightStackView.arrangedSubviews
            views.enumerated().forEach { index, view in
                guard let giftView = view as? VoiceRoomPKGiftUserView else { return }
                if index < room.userInfoList.count {
                    giftView.updateUser(user: room.userInfoList[index])
                } else {
                    giftView.updateUser(user: nil)
                }
            }
        }
    }
    
}
