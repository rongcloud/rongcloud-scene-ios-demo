//
//  ChatEventTableViewCell.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/20.
//

import UIKit
import Reusable

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

protocol ChatEventTableViewCellProtocol: AnyObject {
    func onUserClicked(_ userId: String)
}

class ChatEventTableViewCell: UITableViewCell, Reusable {
    private weak var delegate: ChatEventTableViewCellProtocol?
    private lazy var containerView = UIView()
    private lazy var shapeLayer = ChatShapeLayer()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.resize)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var tracks = [VoiceRoomEventTrack]()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12.resize)
            $0.top.bottom.equalToSuperview().inset(3.resize)
            $0.width.lessThanOrEqualToSuperview().multipliedBy(278.0 / 375)
        }
        containerView.layer.addSublayer(shapeLayer)
        containerView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints {
            $0.left.right.width.equalToSuperview().inset(12.resize)
            $0.top.bottom.height.equalToSuperview().inset(8.resize)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onLabelTapped(_:)))
        messageLabel.addGestureRecognizer(tapGesture)
        messageLabel.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onLabelTapped(_ tap: UITapGestureRecognizer) {
        let position = tap.location(in: messageLabel)
        let index = messageLabel.indexOfAttributedTextCharacterAtPoint(point: position)
        for track in tracks {
            if track.range.contains(index) {
                delegate?.onUserClicked(track.id)
                break
            }
        }
    }
    
    func update(_ event: VoiceRoomChatEvent, delegate: ChatEventTableViewCellProtocol) -> Self {
        self.delegate = delegate
        shapeLayer.fillColor = event.backgroundColor.cgColor
        messageLabel.attributedText = event.attributeString
        tracks = event.tracks
        DispatchQueue.main.async {
            self.shapeLayer.frame = self.containerView.bounds
        }
        return self
    }
}

extension UILabel {
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}

extension NSRange {
    func isContain(_ index: Int) -> Bool {
        return index >= location && index <= location + length
    }
}
