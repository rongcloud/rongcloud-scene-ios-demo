//
//  RCVRVoiceButton.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/2.
//

import UIKit
import RCRTCAudio

enum RCVRVoiceButtonState {
    case none
    case begin
    case recording
    case outArea
    case cancel
    case end
    case lack
    
    var isRecording: Bool {
        switch self {
        case .begin, .recording, .outArea:
            return true
        default:
            return false
        }
    }
}

final class RCVRVoiceButton: UIView {
    
    var recordStateChanged: ((RCVRVoiceButtonState) -> Void)?
    var recordDidSuccess: (((URL, TimeInterval)?)->Void)?
    
    private lazy var imageView = UIImageView()
    private lazy var gradientLayer = CAGradientLayer()
    
    private(set) var state: RCVRVoiceButtonState = .none {
        didSet {
            switch state {
            case .begin:
                RCRTCAudioRecorder.shared.start()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .recording: ()
            case .outArea: ()
            case .cancel:
                RCRTCAudioRecorder.shared.cancel()
            case .end:
                let url = RCRTCAudioRecorder.shared.stop()
                recordDidSuccess?(url)
            default: ()
            }
            gradientLayer.isHidden = !state.isRecording
            imageView.image = state.isRecording ?
                R.image.record_voice_highlighted() :
                R.image.record_voice_normal()
            recordStateChanged?(state)
        }
    }
    
    private var beginTime: TimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressTriggle(_:)))
        longGesture.minimumPressDuration = 0.2
        addGestureRecognizer(longGesture)
        
        gradientLayer.colors = [UIColor(hexString: "#E92B99").cgColor, UIColor(hexString: "#A835EF").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.isHidden = true
        layer.addSublayer(gradientLayer)
        
        imageView.image = R.image.record_voice_normal()
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(17)
            make.height.equalTo(21)
        }
        
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width * 0.5
        gradientLayer.frame = bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        beginTime = Date().timeIntervalSince1970
        print("touch begin: \(Date().timeIntervalSince1970)")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("touch end: \(Date().timeIntervalSince1970)")
        if beginTime + 0.2 > Date().timeIntervalSince1970 {
            state = .lack
        }
    }
    
    @objc private func onLongPressTriggle(_ gesture: UILongPressGestureRecognizer) {
        print("state: \(gesture.state.rawValue) position: \(gesture.location(in: self))")
        switch gesture.state {
        case .began: state = .begin
        case .changed: state = bounds.contains(gesture.location(in: self)) ? .recording : .outArea
        case .cancelled: state = .cancel
        case .ended:
            if state == .outArea {
                state = .cancel
            } else {
                state = .end
            }
        default: ()
        }
    }
    
}
