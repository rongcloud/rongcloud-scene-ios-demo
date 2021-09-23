//
//  RCVRMMessageCell.swift
//  RCVoiceRoomMessage
//
//  Created by shaoshuai on 2021/8/10.
//

import UIKit

class ChatShapeLayer: CAShapeLayer {
    override var frame: CGRect {
        didSet {
            path = chatPath()
        }
    }
    
    private func chatPath() -> CGPath? {
        let ltR: CGFloat = 1, nR: CGFloat = 6
        let width: CGFloat = frame.width, height = frame.height
        let path = UIBezierPath()
        path.move(to: CGPoint(x: ltR, y: 0))
        let arces: [(CGPoint, CGFloat, CGFloat, CGFloat)] = [
            (CGPoint(x: ltR, y: ltR), ltR, .pi, .pi * 1.5),
            (CGPoint(x: width - nR, y: nR), nR, -.pi * 0.5, 0),
            (CGPoint(x: width - nR, y: height - nR), nR, 0, .pi * 0.5),
            (CGPoint(x: nR, y: height - nR), nR, .pi * 0.5, .pi),
        ]
        arces.forEach {
            path.addArc(withCenter: $0.0, radius: $0.1, startAngle: $0.2, endAngle: $0.3, clockwise: true)
        }
        path.close()
        return path.cgPath
    }
}

protocol RCVRMMessageCellProtocol: AnyObject {
    func onUserClicked(_ userId: String)
}

class RCVRMMessageCell: UITableViewCell {
    
    private weak var delegate: RCVRMMessageCellProtocol?
    
    private(set) lazy var containerView = UIView()
    private lazy var shapeLayer = ChatShapeLayer()
    
    private(set) lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tracks = [RCVRMMessageTrack]()
    
    var messageLableRightConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12).isActive = true
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3).isActive = true
        containerView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 278.0 / 375).isActive = true
        
        containerView.layer.addSublayer(shapeLayer)
        
        containerView.addSubview(messageLabel)
        messageLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        messageLableRightConstraint = messageLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -12)
        messageLableRightConstraint.isActive = true
        messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onLabelTapped(_:)))
        messageLabel.addGestureRecognizer(tapGesture)
        messageLabel.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onLabelTapped(_ tap: UITapGestureRecognizer) {
        let position = tap.location(in: messageLabel)
        let index = messageLabel.indexOfAttriTxt(at: position)
        guard
            let track = tracks.first(where: { $0.range.contains(index) })
        else { return }
        delegate?.onUserClicked(track.id)
    }
    
    func update(_ message: RCVRMMessage, delegate: RCVRMMessageCellProtocol) -> RCVRMMessageCell {
        self.delegate = delegate
        shapeLayer.fillColor = message.backgroundColor.cgColor
        messageLabel.attributedText = message.attributeString
        tracks = message.tracks
        DispatchQueue.main.async {
            self.shapeLayer.frame = self.containerView.bounds
        }
        return self
    }
}
