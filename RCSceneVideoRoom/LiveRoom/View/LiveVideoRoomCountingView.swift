//
//  LiveVideoRoomCountingView.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/23.
//

import UIKit
import RCSceneService
import RCSceneModular
import RCSceneFoundation

class LiveVideoRoomCountingView: UIView {

    private(set) lazy var imageView: UIImageView = {
        let instance = UIImageView(image: R.image.room_counting())
        instance.contentMode = .scaleAspectFit
        return instance
    }()
    
    private(set) lazy var contentLabel: UILabel = {
        let instance = UILabel()
        instance.text = "0"
        instance.font = .systemFont(ofSize: 16)
        instance.textColor = .white
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleViewClick))
        tap.numberOfTouchesRequired = 1
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
    }
    
    private func buildLayout() {
        backgroundColor = UIColor.white.withAlphaComponent(0.25)
        clipsToBounds = true
        
        addSubview(imageView)
        addSubview(contentLabel)
        
        imageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(17)
            make.height.equalTo(18.5)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(6)
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func update(_ count: Int) {
        contentLabel.text = "\(count)"
    }
    
    func updateRoomUserNumber() {
        guard let room = SceneRoomManager.shared.currentRoom else { return }
        RCChatRoomClient.shared()
            .getChatRoomInfo(room.roomId, count: 0, order: .chatRoom_Member_Asc) { info in
                DispatchQueue.main.async {
                    self.contentLabel.text = "\(info.totalMemberCount)"
                    self.layoutIfNeeded()
                }
            } error: { _ in }
    }
    
    @objc func handleViewClick() {
        guard let room = SceneRoomManager.shared.currentRoom else { return }
        guard let delegate = controller as? UserOperationProtocol else { return }
        videoRouter.trigger(.userList(room: room, delegate: delegate))
    }
}
