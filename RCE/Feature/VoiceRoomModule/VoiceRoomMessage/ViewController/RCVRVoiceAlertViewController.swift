//
//  RCVRVoiceAlertViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/2.
//

import UIKit

final class RCVRVoiceAlertViewController: UIViewController {
    
    private lazy var contentView = UIView()
    private lazy var volumeView = RCVoiceVolumeView()
    private lazy var imageView = UIImageView(image: R.image.record_voice_cancel())
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .white
        instance.textAlignment = .center
        return instance
    }()
    
    private var currentState: RCVRVoiceButtonState = .none {
        didSet {
            if currentState == oldValue { return }
            switch currentState {
            case .lack: onTimeLack()
            case .begin, .recording: onRecording()
            case .outArea: onOutside()
            default: onEnd()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
    }
    
    func update(_ state: RCVRVoiceButtonState) {
        currentState = state
    }
    
    private func onTimeLack() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(contentView)
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        contentView.addSubview(titleLabel)
        contentView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(70)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        titleLabel.text = "长按说话"
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [unowned self] in
            dismiss(animated: true)
            currentState = .none
        }
    }
    
    private func onRecording() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(contentView)
        contentView.backgroundColor = .clear
        contentView.addSubview(volumeView)
        volumeView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(160)
        }
        volumeView.startAnimation()
    }
    
    private func onOutside() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(contentView)
        contentView.backgroundColor = .clear
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(160)
        }
    }
    
    private func onEnd() {
        contentView.removeFromSuperview()
        volumeView.stopAnimation()
    }
}
