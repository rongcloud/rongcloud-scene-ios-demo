//
//  HomeMessageButton.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/1.
//

import UIKit

final class HomeMessageButton: UIButton {
    
    private lazy var redDotLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(hexString: "#E92B88").cgColor
        layer.frame = CGRect(x: 24, y: 4, width: 7, height: 7)
        layer.cornerRadius = 3.5
        layer.masksToBounds = true
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(R.image.message_button_icon(), for: .normal)
        RCCoreClient.shared().add(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDot() {
        if UserDefaults.standard.authorizationKey() == nil {
            redDotLayer.removeFromSuperlayer()
            return
        }
        let num: NSNumber = NSNumber(value: RCConversationType.ConversationType_PRIVATE.rawValue)
        let count = RCIMClient.shared().getUnreadCount([num])
        if count > 0 {
            layer.addSublayer(redDotLayer)
        } else {
            redDotLayer.removeFromSuperlayer()
        }
    }
}

extension HomeMessageButton: RCIMClientReceiveMessageDelegate {
    func onReceived(_ message: RCMessage?, left nLeft: Int32, object: Any!) {
        guard let msg = message,msg.conversationType == .ConversationType_PRIVATE else {
            return
        }
        DispatchQueue.main.async {
            self.updateDot()
        }
    }
}
