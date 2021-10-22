//
//  LiveVideoUserBorderView.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/28.
//

import UIKit

class LiveVideoRoomUserView: UIView {
    
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .white
        instance.font = .systemFont(ofSize: 12.resize)
        return instance
    }()

    private var userId: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(4)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc private func handleTapGesture() {
        debugPrint("live video user did click")
        guard let userId = userId else { return }
        guard let controller = controller else { return }
        guard let delegate = controller as? RCLiveVideoDelegate else { return }
        delegate.liveVideoUserDidClick?(userId)
    }
    
    func update(_ userId: String?) {
        self.userId = userId
        
        if let userId = userId {
            UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
                self?.nameLabel.text = user.userName
            }
        } else {
            nameLabel.text = ""
        }
    }
}
