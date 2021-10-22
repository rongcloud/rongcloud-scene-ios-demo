//
//  LiveVideoRoomCreationView.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import SVProgressHUD

protocol LiveVideoRoomCreationDelegate {
    func didCreate(_ room: VoiceRoom)
}

class LiveVideoRoomCreationView: UIView {
    private lazy var headerView = CreateLiveVideoHeader(self)
    private lazy var startLiveButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        instance.setTitle("创建直播", for: .normal)
        instance.setTitleColor(.white, for: .normal)
        instance.setBackgroundImage(R.image.begin_live_video_button_bg(), for: .normal)
        instance.addTarget(self, action: #selector(start), for: .touchUpInside)
        return instance
    }()
    private lazy var beautyView = RCMHBeautyView(manager)
    private lazy var backButton: UIButton = {
        let instance = UIButton()
        instance.addTarget(self, action: #selector(back), for: .touchUpInside)
        instance.setImage(R.image.back_indicator_image(), for: .normal)
        return instance
    }()
    
    private lazy var viewModel = LiveVideoViewModel()
    
    private let manager: MHBeautyManager
    init(_ manager: MHBeautyManager) {
        self.manager = manager
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func start() {
        if viewModel.createState.needInputPassword {
            controller?.navigator(.inputPassword(type: .input, delegate: self))
            return
        }
        
        viewModel.create { [weak self] result in
            switch result {
            case let .success(wrapper):
                guard
                    let delegate = self?.controller as? LiveVideoRoomCreationDelegate
                else { return }
                if let room = wrapper.data {
                    if wrapper.code == 30016 {
                        let controller = UIAlertController(title: "提示", message: "您有正在直播的房间(\(room.roomName))，是否进入？", preferredStyle: .alert)
                        let sureAction = UIAlertAction(title: "确定", style: .default) { _ in
                            delegate.didCreate(room)
                        }
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
                            self?.controller?.pop()
                        }
                        controller.addAction(cancelAction)
                        controller.addAction(sureAction)
                        self?.controller?.present(controller, animated: true)
                    } else {
                        delegate.didCreate(room)
                    }
                } else {
                    SVProgressHUD.showError(withStatus: "创建失败")
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    @objc private func back() {
        controller?.navigationController?.popViewController(animated: true)
    }
}

extension LiveVideoRoomCreationView {
    
    private func setupUI() {
        enableTapEndEditing()
        
        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(190.resize)
        }
        
        addSubview(startLiveButton)
        startLiveButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
        }
        
        beautyView.delegate = self
        addSubview(beautyView)
        beautyView.snp.makeConstraints { make in
            make.left.right.equalTo(startLiveButton).inset(6.resize)
            make.bottom.equalTo(startLiveButton.snp.top).offset(-24.resize)
            make.height.equalTo(65.resize)
        }
        
        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.top.equalTo(safeAreaLayoutGuide)
            make.width.height.equalTo(44)
        }
    }
}

extension LiveVideoRoomCreationView: CreateLiveVideoHeaderProtocol {
    func roomDidClick(type isPrivate: Bool) {
        viewModel.createState.isPrivate = isPrivate
    }
    
    func roomDidEndEditing(name: String) {
        viewModel.createState.roomName = name
    }
    
    func roomDidSelect(thumb image: UIImage) {
        viewModel.createState.roomThumbImage = image.kf.resize(to: CGSize(width: 72, height: 72))
    }
}

extension LiveVideoRoomCreationView: RCMHBeautyViewDelegate {
    func didClickBeautyAction(_ action: RCMHBeautyAction) {
        guard let controller = controller as? LiveVideoRoomHostController else { return }
        switch action {
        case .switchCamera:
            RCRTCEngine.sharedInstance().defaultVideoStream.switchCamera()
        case .sticker:
            controller.present(controller.sticker, animated: true)
        case .retouch:
            controller.present(controller.retouch, animated: true)
        case .makeup:
            controller.present(controller.makeup, animated: true)
        case .effect:
            controller.present(controller.effect, animated: true)
        }
    }
}

extension LiveVideoRoomCreationView: VoiceRoomInputPasswordProtocol {
    func passwordDidEnter(password: String) {
        guard password.count > 0 else {
            return SVProgressHUD.showError(withStatus: "请输入密码")
        }
        viewModel.createState.password = password
        start()
    }
}
