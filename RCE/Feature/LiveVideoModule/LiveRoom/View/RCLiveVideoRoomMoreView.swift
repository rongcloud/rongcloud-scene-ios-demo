//
//  RCSceneRoomMoreView.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/15.
//

import UIKit

enum LiveVideoRoomMoreAction {
    case leave
    case quit
    case minimize
}

protocol LiveVideoRoomMoreDelegate {
    func sceneRoom(_ view: RCLiveVideoRoomMoreView, didClick action: LiveVideoRoomMoreAction)
}

class RCLiveVideoRoomMoreView: UIView {
    
    private lazy var button: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.more_icon(), for: .normal)
        instance.addTarget(self, action: #selector(buttonDidClick), for: .touchUpInside)
        return instance
    }()
    
    private var roleType = RCRTCLiveRoleType.audience
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonDidClick() {
        if roleType == .audience {
            let leaveAlertController = LiveVideoRoomLeaveViewController()
            leaveAlertController.modalTransitionStyle = .crossDissolve
            leaveAlertController.modalPresentationStyle = .overFullScreen
            leaveAlertController.delegate = self
            controller?.present(leaveAlertController, animated: true)
        } else {
            guard let delegate = controller as? LiveVideoRoomMoreDelegate else { return }
            delegate.sceneRoom(self, didClick: .quit)
        }
    }
    
    func update(_ role: RCRTCLiveRoleType) {
        self.roleType = role
        let image = role == .broadcaster ?
            R.image.live_room_close() :
            R.image.more_icon()
        button.setImage(image, for: .normal)
    }
}

extension RCLiveVideoRoomMoreView: LiveVideoRoomLeaveDelegate {
    func leaveRoomDidClick() {
        guard let delegate = controller as? LiveVideoRoomMoreDelegate else { return }
        delegate.sceneRoom(self, didClick: .leave)
    }
    
    func scaleRoomDidClick() {
        guard let delegate = controller as? LiveVideoRoomMoreDelegate else { return }
        delegate.sceneRoom(self, didClick: .minimize)
    }
}
