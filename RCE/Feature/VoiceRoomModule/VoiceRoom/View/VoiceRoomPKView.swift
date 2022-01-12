//
//  VoiceRoomPKView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/11.
//

import UIKit

protocol VoiceRoomPKViewDelegate: AnyObject {
    func silenceButtonDidClick()
}

private struct Constants {
    static let countdown = 180
    static let leftColor = UIColor(hexString: "#E92B88")
    static let rightColor = UIColor(hexString: "#505DFF")
}

class VoiceRoomPKView: UIView {
    weak var delegate: VoiceRoomPKViewDelegate?
    private lazy var leftMasterView: VoiceRookPKMasterView = {
        let instance = VoiceRookPKMasterView()
        return instance
    }()
    private lazy var rightMasterView: VoiceRookPKMasterView = {
        let instance = VoiceRookPKMasterView()
        return instance
    }()
    private lazy var middleImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.pk_vs_icon()
        return instance
    }()
    private lazy var countdownLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        instance.textColor = .white.withAlphaComponent(0.6)
        instance.text = "02:30"
        return instance
    }()
    private lazy var punishCountdownLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14, weight: .medium)
        instance.textColor = .white.withAlphaComponent(0.6)
        instance.text = "惩罚时间 03:00"
        instance.isHidden = true
        return instance
    }()
    private lazy var progressContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 12
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var leftProgressView: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E92B88")
        return instance
    }()
    private lazy var leftScoreLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        instance.text = "我方 0"
        return instance
    }()
    private lazy var rightProgressView: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#505DFF")
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
    private lazy var leftStackView: UIStackView = {
        let viewlist = (0...2).map { _ in VoiceRoomPKGiftUserView() }
        let instance = UIStackView(arrangedSubviews: viewlist)
        instance.axis = .horizontal
        instance.spacing = 12
        instance.distribution = .equalSpacing
        instance.alignment = .center
        return instance
    }()
    private lazy var rightStackView: UIStackView = {
        let viewlist = (0...2).map { _ in VoiceRoomPKGiftUserView() }
        let instance = UIStackView(arrangedSubviews: viewlist)
        instance.axis = .horizontal
        instance.spacing = 12
        instance.distribution = .equalSpacing
        instance.alignment = .center
       // instance.semanticContentAttribute = .forceRightToLeft
        return instance
    }()
    private var countDownTimer: Timer?
    private var countdownSec = 0
    private var pkInfo: VoiceRoomPKInfo?
    private var score: (Int, Int) = (0, 0)
    private lazy var muteButton: UIButton = {
        let instance = UIButton(type: .custom)
        instance.setImage(R.image.open_remote_audio_icon(), for: .normal)
        instance.addTarget(self, action: #selector(handleMuteDidClick), for: .touchUpInside)
        return instance
    }()
    
    init() {
        super.init(frame: .zero)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        layer.cornerRadius = 16
        clipsToBounds = false
        backgroundColor = .black.withAlphaComponent(0.4)
        addSubview(leftMasterView)
        addSubview(rightMasterView)
        rightMasterView.addSubview(muteButton)
        addSubview(progressContainer)
        addSubview(middleImageView)
        addSubview(countdownLabel)
        progressContainer.addSubview(leftProgressView)
        progressContainer.addSubview(rightProgressView)
        progressContainer.addSubview(flashImageView)
        addSubview(leftStackView)
        addSubview(rightStackView)
        progressContainer.addSubview(leftScoreLabel)
        progressContainer.addSubview(rightScoreLabel)
        addSubview(punishCountdownLabel)
        
        leftMasterView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(36.resize)
            make.top.equalToSuperview().offset(20.resize)
        }
        
        rightMasterView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(36.resize)
            make.top.equalToSuperview().offset(20.resize)
        }
        
        muteButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalTo(rightMasterView.snp.right).offset(-5)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        progressContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12.resize)
            make.height.equalTo(24)
            make.top.equalTo(leftMasterView.snp.bottom).offset(17)
            make.bottom.equalToSuperview().inset(54)
        }
        
        leftProgressView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        rightProgressView.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        flashImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(leftProgressView.snp.right)
        }
        
        middleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(leftMasterView)
        }
        
        countdownLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(middleImageView.snp.bottom).offset(3)
        }
        
        leftScoreLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        rightScoreLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        leftStackView.snp.makeConstraints { make in
            make.left.equalTo(progressContainer)
            make.top.equalTo(progressContainer.snp.bottom).offset(8)
        }
        
        rightStackView.snp.makeConstraints { make in
            make.right.equalTo(progressContainer)
            make.top.equalTo(progressContainer.snp.bottom).offset(8)
        }
        
        punishCountdownLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(progressContainer.snp.top)
        }
    }
    
    func beginPK(info: VoiceRoomPKInfo, timeDiff: Int, currentRoomOwnerId: String, currentRoomId: String) {
        updateUserInfo(info: info, currentRoomOwnerId: currentRoomOwnerId)
        if info.currentUserRole() != .audience {
            muteButton.isHidden = false
        } else {
            muteButton.isHidden = true
        }
        let passedTime = timeDiff
        self.countdownSec = Constants.countdown - passedTime
        self.startCountdown(remainSeconds: self.countdownSec, state: .pkOngoing)
    }
    
    func beginPunishment(passedSeconds: Int, info: VoiceRoomPKInfo? = nil, currentRoomId: String? = nil) {
        if let info = info, let roomId = currentRoomId {
            updateUserInfo(info: info, currentRoomOwnerId: roomId)
        }
        setupPKResult()
        startCountdown(remainSeconds: Constants.countdown - passedSeconds, state: .punishOngoing)
    }
    
    private func startCountdown(remainSeconds: Int, state: PKCountdownState) {
        guard remainSeconds > 0 else {
            countdownLabel.isHidden = true
            punishCountdownLabel.isHidden = true
            countDownTimer?.invalidate()
            return
        }
        countdownSec = remainSeconds
        countDownTimer?.invalidate()
        countdownLabel.isHidden = (state == .punishOngoing)
        punishCountdownLabel.isHidden = (state == .pkOngoing)
        countDownTimer = Timer(timeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            guard self.countdownSec > 0 else {
                timer.invalidate()
                return
            }
            self.countdownSec -= 1
            let min = self.countdownSec/60
            let sec = self.countdownSec % 60
            switch state {
            case .pkOngoing:
                let text = String(format: "%02d:%02d", min, sec)
                self.countdownLabel.text = text
            case .punishOngoing:
                let text = String(format: "%02d:%02d", min, sec)
                self.punishCountdownLabel.text = text
            }
            
        })
        RunLoop.current.add(countDownTimer!, forMode: .common)
        countDownTimer?.fire()
    }
    
    private func pkResult() -> PKResult {
        let result: (PKResult, PKResult) = {
            if score.0 > score.1 {
                return (.win, .lose)
            } else if score.0 < score.1 {
                return (.lose, .win)
            } else {
                return (.tie, .tie)
            }
        }()
        return result.0
    }
    
    private func updateUserInfo(info: VoiceRoomPKInfo, currentRoomOwnerId: String) {
        self.pkInfo = info
        UserInfoDownloaded.shared.fetch([info.inviterId, info.inviteeId]) { userlist in
            if let leftUser = userlist.first(where: { user in
                user.userId == currentRoomOwnerId
            }) {
                self.leftMasterView.updateUser(leftUser)
            }
            let rightUserId = info.inviterId == currentRoomOwnerId ? info.inviteeId : info.inviterId
            if let rightUser = userlist.first(where: { user in
                user.userId == rightUserId
            }) {
                self.rightMasterView.updateUser(rightUser)
            }
        }
    }
    
    func updateGiftValue(content: PKGiftModel, currentRoomId: String) {
        for room in content.roomScores {
            let isLeft = (room.roomId == currentRoomId)
            if isLeft {
                score.0 = room.score
            } else {
                score.1 = room.score
            }
            if score.0 + score.1 > 0 {
                let leftScale = CGFloat(score.0)/CGFloat(score.0 + score.1)
                leftProgressView.snp.remakeConstraints { make in
                    make.left.top.bottom.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(leftScale)
                }
                rightProgressView.snp.remakeConstraints { make in
                    make.right.top.bottom.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(1 - leftScale)
                }
            }
            let label = isLeft ? leftScoreLabel : rightScoreLabel
            let stackView = isLeft ? leftStackView : rightStackView
            let postition = isLeft ? "我方 " : "对方 "
            label.text = postition + "\(room.score)"
            if room.userInfoList.count > 0 {
                for i in (0..<stackView.arrangedSubviews.count) {
                    let arrangedViews = isLeft ? stackView.arrangedSubviews.reversed() : stackView.arrangedSubviews
                    guard let giftView = arrangedViews[i] as? VoiceRoomPKGiftUserView else {
                        return
                    }
                    if i < room.userInfoList.count {
                        giftView.updateColor(Constants.leftColor)
                        giftView.updateUser(user: room.userInfoList[i], rank: i + 1, isLeft: isLeft)
                    } else {
                        giftView.updateColor(.clear)
                        giftView.updateUser(user: nil, rank: i + 1, isLeft: isLeft)
                    }
                }
            }
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
        
    }
    
    private func setupPKResult() {
        if score.0 > score.1 {
            leftMasterView.updatePKResult(result: .win)
            rightMasterView.updatePKResult(result: .lose)
        } else if (score.0 == score.1) {
            leftMasterView.updatePKResult(result: .tie)
            rightMasterView.updatePKResult(result: .tie)
            middleImageView.image = R.image.pk_tie_icon()
        } else {
            leftMasterView.updatePKResult(result: .lose)
            rightMasterView.updatePKResult(result: .win)
        }
    }
    
    func setupMuteState(isMute: Bool) {
        let image = isMute ? R.image.disable_remote_audio_icon() : R.image.open_remote_audio_icon()
        muteButton.setImage(image, for: .normal)
    }
    
    func resetGiftViews() {
        leftStackView.removeAllArrangedSubviews()
        rightStackView.removeAllArrangedSubviews()
        (0...2).forEach { _ in
            let leftGiftView = VoiceRoomPKGiftUserView()
            let rightGiftView = VoiceRoomPKGiftUserView()
            leftStackView.addArrangedSubview(leftGiftView)
            rightStackView.addArrangedSubview(rightGiftView)
        }
    }
    
    func reset() {
        resetGiftViews()
        pkInfo = nil
        countdownSec = 0
        countDownTimer = nil
        countdownLabel.isHidden = false
        punishCountdownLabel.isHidden = true
        score = (0, 0)
        leftScoreLabel.text = "我方 0"
        rightScoreLabel.text = "对方 0"
        leftMasterView.reset()
        rightMasterView.reset()
        middleImageView.image = R.image.pk_vs_icon()
        muteButton.setImage(R.image.open_remote_audio_icon(), for: .normal)
        leftProgressView.snp.remakeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        rightProgressView.snp.remakeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    @objc private func handleMuteDidClick() {
        delegate?.silenceButtonDidClick()
    }
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            NSLayoutConstraint.deactivate($0.constraints)
            $0.removeFromSuperview()
        }
    }
}
