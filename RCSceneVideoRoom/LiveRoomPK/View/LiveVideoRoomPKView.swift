//
//  LiveVideoRoomPKView.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/29.
//

import UIKit

private struct Constants {
    static let countdown = 180
    static let leftColor = UIColor(hexString: "#E92B88")
    static let rightColor = UIColor(hexString: "#505DFF")
}

enum LiveVideoPKResult {
    case win
    case lose
    case draw
    
    var title: String {
        switch self {
        case .win, .lose: return "惩罚时间"
        case .draw: return "平局"
        }
    }
}

enum LiveVideoPKState {
    case progress
    case finish(LiveVideoPKResult)
    
    var title: String {
        switch self {
        case .progress: return "PK"
        case let .finish(result): return result.title
        }
    }
}

class LiveVideoRoomPKView: UIView {
    private lazy var muteButton: UIButton = {
        let instance = UIButton(type: .custom)
        instance.setImage(R.image.open_remote_audio_icon(), for: .normal)
        instance.setImage(R.image.disable_remote_audio_icon(), for: .selected)
        instance.addTarget(self, action: #selector(handleMuteDidClick), for: .touchUpInside)
        return instance
    }()
    private lazy var otherRoomButton: UIButton = {
        let instance = UIButton(type: .custom)
        instance.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        instance.semanticContentAttribute = .forceRightToLeft
        instance.setImage(R.image.room(), for: .normal)
        instance.setTitleColor(.white, for: .normal)
        instance.titleLabel?.font = .systemFont(ofSize: 11)
        instance.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        instance.addTarget(self, action: #selector(handleOtherRoomDidClick), for: .touchUpInside)
        instance.layer.cornerRadius = 10
        instance.layer.masksToBounds = true
        return instance
    }()
    private lazy var countdownLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        instance.textColor = UIColor.white.withAlphaComponent(0.6)
        return instance
    }()
    private(set) lazy var progressView = LiveVideoPKProgressView()
    private lazy var giverView = LiveVideoPKGiverView()
    
    private var countDownTimer: Timer?
    
    private var result: LiveVideoPKResult {
        progressView.result()
    }
    
    init() {
        super.init(frame: .zero)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        addSubview(muteButton)
        addSubview(countdownLabel)
        addSubview(otherRoomButton)
        addSubview(giverView)
        addSubview(progressView)
        
        muteButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(8)
            make.size.equalTo(CGSize(width: 33, height: 18))
        }
        
        countdownLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(progressView.snp.top).offset(-10)
        }
        
        otherRoomButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.bottom.equalTo(countdownLabel)
            make.height.equalTo(20)
        }
        
        progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalToSuperview().inset(40)
        }
        
        giverView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    
    func begin(_ time: Int) {
        guard
            let otherUserId = RCLiveVideoEngine.shared().pkInfo?.otherRoomUserId(),
            let seat = RCLiveVideoEngine.shared().currentSeats.first(where: { $0.userId == otherUserId })
        else { return }
        seat.delegate = self
        updateUserInfo()
        startCountdown(time: Constants.countdown - time, state: .progress)
    }
    
    func punish(_ time: Int) {
        updateUserInfo()
        if time <= 0 { showResultView() }
        startCountdown(time: Constants.countdown - time, state: .finish(result))
    }
    
    private func startCountdown(time: Int, state: LiveVideoPKState) {
        countDownTimer?.invalidate()
        guard time > 0 else { return }
        var leftTime = time
        let title = state.title
        let timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self, leftTime > 0 else { return timer.invalidate() }
            leftTime -= 1
            let min = leftTime/60
            let sec = leftTime%60
            let time = String(format: "%02d:%02d", min, sec)
            self.countdownLabel.text = "\(title) \(time)"
        })
        RunLoop.current.add(timer, forMode: .common)
        timer.fire()
        countDownTimer = timer
    }
    
    private func updateUserInfo() {
        guard let PK = RCLiveVideoEngine.shared().pkInfo else { return }
        UserInfoDownloaded.shared.fetchUserInfo(userId: PK.otherRoomUserId()) { user in
            self.otherRoomButton.setTitle("\(user.userName)  ", for: .normal)
        }
    }
    
    private func showResultView() {
        let resultView = LiveVideoPKResultView()
        resultView.update(result)
        insertSubview(resultView, at: 0)
        resultView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(progressView.snp.top)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            resultView.removeFromSuperview()
        }
    }
    
    func updateGiftValue(content: PKGiftModel) {
        giverView.updateGiverInfo(content)
        progressView.updateScore(content)
    }
    
    @objc private func handleMuteDidClick() {
        guard let room = SceneRoomManager.shared.currentRoom else { return }
        guard room.userId == Environment.currentUserId else { return }
        let isMute = !muteButton.isSelected
        RCLiveVideoEngine.shared().mutePKUser(isMute) { code in
            if code == .success {
                self.muteButton.isSelected = isMute
            } else {
                SVProgressHUD.showError(withStatus: "静音设置失败")
            }
        }
    }
    
    @objc private func handleOtherRoomDidClick() {
        guard let PK = RCLiveVideoEngine.shared().pkInfo else { return }
        if PK.roomUserId() == Environment.currentUserId { return }
        SVProgressHUD.show()
        videoRoomService.roomInfo(roomId: PK.otherRoomId()) { [weak self] result in
            SVProgressHUD.dismiss()
            switch result.map(RCNetworkWapper<VoiceRoom>.self) {
            case let .success(model):
                guard
                    let room = model.data,
                    let controller = self?.controller as? LiveVideoRoomViewController,
                    let containerAction = controller.roomContainerAction
                else { return }
                containerAction.switchRoom(room)
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    deinit {
        debugPrint("PK view deinit")
    }
}

extension LiveVideoRoomPKView: RCLiveVideoSeatDelegate {
    func seat(_ seat: RCLiveVideoSeat, didLock isLocked: Bool) {
    }
    
    func seat(_ seat: RCLiveVideoSeat, didMute isMuted: Bool) {
        muteButton.isSelected = isMuted
    }
    
    func seat(_ seat: RCLiveVideoSeat, didUserEnableAudio enable: Bool) {
    }
    
    func seat(_ seat: RCLiveVideoSeat, didUserEnableVideo enable: Bool) {
    }
    
    func seat(_ seat: RCLiveVideoSeat, didSpeak audioLevel: Int) {
    }
}
