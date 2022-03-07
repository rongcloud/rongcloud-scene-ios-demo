//
//  RCLVRAlertConnectingViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/19.
//

import UIKit

class RCLVRAlertConnectingViewController: RCLVRAlertViewController {

    private(set) lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.text = "正在进行语音连线"
        instance.textColor = .white
        instance.font = .systemFont(ofSize: 16.resize, weight: .medium)
        return instance
    }()
    
    private lazy var switchMediaButton: UIButton = {
        var action: RCLVRSeatSheetAction {
            if seatInfo.userEnableVideo {
                return RCLVRSeatSheetAction(title: "切换到音频连线", type: .gradient)
            } else {
                return RCLVRSeatSheetAction(title: "切换到音视频连线", type: .gradient)
            }
        }
        let instance = RCActionButton(action)
        instance.addTarget(self, action: #selector(switchMediaType), for: .touchUpInside)
        return instance
    }()
    
    private lazy var switchMicButton: UIButton = {
        var action: RCLVRSeatSheetAction {
            if seatInfo.userEnableAudio {
                return RCLVRSeatSheetAction(title: "关闭麦克风", type: .normal)
            } else {
                return RCLVRSeatSheetAction(title: "开启麦克风", type: .normal)
            }
        }
        let instance = RCActionButton(action)
        instance.addTarget(self, action: #selector(switchMicState), for: .touchUpInside)
        return instance
    }()
    
    private lazy var hangUpButton: UIButton = {
        let instance = RCActionButton(RCLVRSeatSheetAction(title: "挂断连接", type: .normal))
        instance.addTarget(self, action: #selector(hangUp), for: .touchUpInside)
        return instance
    }()
    
    private let seatInfo: RCLiveVideoSeat
    
    init(_ seatInfo: RCLiveVideoSeat) {
        self.seatInfo = seatInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(contentView.snp.top).offset(35.resize)
        }
        
        contentView.addSubview(switchMediaButton)
        switchMediaButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(70.resize)
            make.width.equalTo(319.resize)
            make.height.equalTo(44.resize)
        }
        
        contentView.addSubview(switchMicButton)
        switchMicButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(128.resize)
            make.width.equalTo(319.resize)
            make.height.equalTo(44.resize)
        }
        
        contentView.addSubview(hangUpButton)
        hangUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(186.resize)
            make.width.equalTo(319.resize)
            make.height.equalTo(44.resize)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-28.5)
        }
    }
    
    override func contentHeight() -> CGFloat {
        return 258.resize
    }
    
    override func maskLayer() -> CAShapeLayer {
        let r: CGFloat = 15.resize
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: contentView.bounds,
                                       byRoundingCorners: [.topLeft, .topRight],
                                       cornerRadii: CGSize(width: r, height: r)).cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.frame = contentView.bounds
        return shapeLayer
    }
}

extension RCLVRAlertConnectingViewController {
    @objc private func switchMediaType() {
        dismiss(animated: true)
        let enableVideo = !seatInfo.userEnableVideo
        seatInfo.setUserEnableVideo(enableVideo) { [weak self] code in
            debugPrint("open live video: \(code.rawValue)")
            self?.delegate?.didClickAction(.switchVideo(enableVideo))
        }
    }
    
    @objc private func switchMicState() {
        dismiss(animated: true)
        let enableAudio = !seatInfo.userEnableAudio
        seatInfo.setUserEnableAudio(enableAudio) { [weak self] code in
            debugPrint("mute live video seat: \(code.rawValue)")
            self?.delegate?.didClickAction(.switchMic(enableAudio))
        }
    }
    
    @objc private func hangUp() {
        dismiss(animated: true)
        RCLiveVideoEngine.shared().leaveLiveVideo { code in
            debugPrint("did finish live video: \(code.rawValue)")
            self.delegate?.didClickAction(.hangUp)
        }
    }
}
