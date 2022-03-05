//
//  LiveVideoPKProgressView.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/29.
//

import UIKit

class LiveVideoPKProgressView: UIView {
    private lazy var leftProgressLayer: CALayer = {
        let instance = CALayer()
        instance.backgroundColor = UIColor(hexString: "#E92B88").cgColor
        return instance
    }()
    private lazy var leftScoreLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        instance.text = "我方 0"
        return instance
    }()
    private lazy var rightProgressLayer: CALayer = {
        let instance = CALayer()
        instance.backgroundColor = UIColor(hexString: "#505DFF").cgColor
        return instance
    }()
    private lazy var rightScoreLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        instance.text = "对方 0"
        return instance
    }()
    private lazy var flashImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = R.image.pk_flash_icon()
        return instance
    }()
    
    private(set) var left: Int = 0
    private(set) var right: Int = 0
    
    private var leftProgress: CGFloat {
        if left == right { return 0.5 }
        return CGFloat(left) / CGFloat(left + right)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(leftProgressLayer)
        layer.addSublayer(rightProgressLayer)
        addSubview(leftScoreLabel)
        addSubview(rightScoreLabel)
        addSubview(flashImageView)
        
        leftScoreLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        
        rightScoreLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(12)
        }
        
        flashImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(2)
            make.width.equalTo(16)
            make.height.equalTo(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgressFrame()
    }
    
    private func updateProgressFrame() {
        let leftWidth = leftProgress * bounds.width
        let leftSize = CGSize(width: leftWidth, height: bounds.height)
        leftProgressLayer.frame = CGRect(origin: .zero, size: leftSize)
        let rightSize = CGSize(width: bounds.width - leftWidth, height: bounds.height)
        rightProgressLayer.frame = CGRect(origin: CGPoint(x: leftWidth, y: 0), size: rightSize)
        flashImageView.snp.updateConstraints { make in
            make.centerX.equalToSuperview().offset(leftWidth - bounds.width * 0.5)
        }
    }
    
    func update(_ left: Int, right: Int) {
        self.left = left
        self.right = right
        updateProgressFrame()
        self.leftScoreLabel.text = "我方 \(left)"
        self.rightScoreLabel.text = "对方 \(right)"
    }

    func result() -> LiveVideoPKResult {
        if left == right { return .draw }
        if left > right { return .win }
        return .lose
    }
    
    func updateScore(_ model: PKGiftModel) {
        guard let PK = RCLiveVideoEngine.shared().pkInfo else { return }
        var left = 0, right = 0
        for room in model.roomScores {
            if room.roomId == PK.roomId() {
                left = room.score
            } else {
                right = room.score
            }
        }
        update(left, right: right)
    }
    
    deinit {
        debugPrint("pk progress deinit")
    }
}
