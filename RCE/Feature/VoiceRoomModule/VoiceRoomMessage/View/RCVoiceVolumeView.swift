//
//  RCVoiceVolumeView.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/30.
//

import UIKit

class RCVoiceVolumeView: UIView {

    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.text = "手指上滑，取消发送"
        instance.textColor = .white
        instance.font = UIFont.systemFont(ofSize: 13)
        return instance
    }()
    
    private lazy var voiceTubeImageView = UIImageView(image: R.image.voice_volume_tube())
    
    private lazy var volumeView: UIView = {
        let instance = UIView()
        for index in 0..<6 {
            let layer = CALayer()
            layer.backgroundColor = UIColor.white.cgColor
            layer.cornerRadius = 2
            layer.name = "\(index)"
            layer.isHidden = true
            instance.layer.addSublayer(layer)
        }
        return instance
    }()
    
    private lazy var timer = Timer(timeInterval: 0.4, repeats: true) { [weak self] _ in
        self?.update((1...6).randomElement() ?? 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        addSubview(titleLabel)
        addSubview(voiceTubeImageView)
        addSubview(volumeView)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(snp.bottom).inset(23.5)
        }
        
        voiceTubeImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.top.equalToSuperview().offset(32)
            make.width.equalTo(40)
            make.height.equalTo(70)
        }
        
        volumeView.snp.makeConstraints { make in
            make.left.equalTo(voiceTubeImageView.snp.right).offset(11)
            make.bottom.equalTo(voiceTubeImageView).offset(-4)
            make.width.equalTo(28)
            make.height.equalTo(49)
        }
        
        layer.cornerRadius = 6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        volumeView.layer.sublayers?.forEach({ layer in
            let index = Int(layer.name!)!
            let frame = CGRect(x: 0, y: 9 * (5 - index), width: 10 + index * 4, height: 4)
            layer.frame = frame
        })
    }
    
    func startAnimation() {
        timer.fireDate = .distantPast
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func stopAnimation() {
        timer.fireDate = .distantFuture
    }
    
    private func update(_ audioLevel: Int) {
        guard audioLevel >= 1, audioLevel <= 6 else { return }
        volumeView.layer.sublayers?.forEach({ layer in
            let index = Int(layer.name!)!
            layer.isHidden = index >= audioLevel
        })
    }
}
