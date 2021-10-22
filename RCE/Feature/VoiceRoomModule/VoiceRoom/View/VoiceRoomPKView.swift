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

typealias PKCallback = ((PKState, PKResult) -> Void)

private struct Constants {
    static let pkDuration = 150
    static let punishDuration = 150
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
    var pkState = PKState.initial
    private var pkCountdownTimer: Timer?
    private var punishCountdownTimer: Timer?
    private var pkSeconds = 0
    private var punishmentSeconds = 0
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
    
    func pkViewBegin(info: VoiceRoomPKInfo, currentRoomOwnerId: String, currentRoomId: String, finish: @escaping PKCallback) {
        updateUserInfo(info: info, currentRoomOwnerId: currentRoomOwnerId)
        if info.currentUserRole() != .audience {
            muteButton.isHidden = false
        } else {
            muteButton.isHidden = true
        }
        var pkTime = Date().timeIntervalSince1970
        let group = DispatchGroup()
        [info.inviteeRoomId, info.inviterRoomId].forEach {
            [weak self] id in
            guard let self = self else {
                return
            }
            group.enter()
            self.getCurrentPKInfo(roomId: id) { model in
                guard let giftModel = model else {
                    group.leave()
                    return
                }
                self.updateGiftValue(content: PKGiftContent(score: giftModel.score, roomId: id, userList: giftModel.userInfoList), currentRoomId: currentRoomId)
                if let timestamp = giftModel.pkTime {
                    pkTime = TimeInterval(timestamp/1000)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            let pasedTime = max(Int(Date().timeIntervalSince1970 - pkTime), 1)
            switch pasedTime {
            case 0..<Constants.pkDuration:
                self.pkSeconds = Constants.pkDuration - pasedTime
                self.punishmentSeconds = Constants.punishDuration
                self.pkState = .pkOngoing
            case Constants.pkDuration..<Constants.pkDuration + Constants.punishDuration:
                self.pkSeconds = 0
                self.punishmentSeconds = (Constants.pkDuration + Constants.punishDuration) - pasedTime
                self.pkState = .punishOngoing
            default:
                self.pkSeconds = 0
                self.punishmentSeconds = 0
                self.pkState = .end
            }
            self.beginCountdown(remainSeconds: self.pkSeconds, finish: finish)
        }
    }
    
    private func getCurrentPKInfo(roomId: String, completion: @escaping ((PKGiftModel?) -> Void)) {
        networkProvider.request(RCNetworkAPI.pkInfo(roomId: roomId)) { result in
            switch result {
            case let .success(response):
                let pkInfo = try? JSONDecoder().decode(PKGiftModel.self, from: response.data, keyPath: "data")
                completion(pkInfo)
            case let .failure(error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func beginCountdown(remainSeconds: Int, finish: @escaping PKCallback) {
        guard remainSeconds > 0 else {
            self.setupPKResult()
            self.pkState = .punishOngoing
            countdownLabel.isHidden = true
            pkCountdownTimer?.invalidate()
            beginPunishmentCountdown(remainSeconds: punishmentSeconds, finish: finish);
            return
        }
        pkState = .pkOngoing
        pkSeconds = remainSeconds
        pkCountdownTimer?.invalidate()
        pkCountdownTimer = Timer(timeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            guard self.pkSeconds > 0 else {
                timer.invalidate()
                self.pkState = .punishOngoing
                self.countdownLabel.isHidden = true
                self.setupPKResult()
                self.beginPunishmentCountdown(remainSeconds: self.punishmentSeconds, finish: finish);
                return
            }
            self.pkSeconds -= 1
            let min = self.pkSeconds/60
            let sec = self.pkSeconds % 60
            let text = String(format: "%02d:%02d", min, sec)
            self.countdownLabel.text = text
        })
        RunLoop.current.add(pkCountdownTimer!, forMode: .common)
        pkCountdownTimer?.fire()
    }
    
    private func beginPunishmentCountdown(remainSeconds: Int, finish: @escaping PKCallback) {
        guard remainSeconds > 0 else {
            punishCountdownTimer?.invalidate()
            pkInfo = nil
            pkState = .end
            finish(.end, self.pkResult())
            return
        }
        pkState = .punishOngoing
        punishCountdownLabel.isHidden = false
        punishmentSeconds = remainSeconds
        punishCountdownTimer?.invalidate()
        punishCountdownTimer = Timer(timeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            guard self.punishmentSeconds > 0 else {
                timer.invalidate()
                self.pkState = .end
                finish(.end, self.pkResult())
                return
            }
            self.punishmentSeconds -= 1
            let min = self.punishmentSeconds/60
            let sec = self.punishmentSeconds % 60
            let text = String(format: "%02d:%02d", min, sec)
            self.punishCountdownLabel.text = "惩罚时间 " + text
        })
        RunLoop.current.add(punishCountdownTimer!, forMode: .common)
        punishCountdownTimer?.fire()
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
    
    func updateGiftValue(content: PKGiftContent, currentRoomId: String) {
        log.debug(content)
        guard let _ = self.pkInfo, pkState == .pkOngoing || pkState == .initial else {
            return
        }
        let isLeft = (content.roomId == currentRoomId)
        if isLeft {
            score.0 = content.score ?? 0
        } else {
            score.1 = content.score ?? 0
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
        label.text = postition + "\(content.score ?? 0)"
        if content.userList.count > 0 {
            for i in (0..<stackView.arrangedSubviews.count) {
                let arrangedViews = isLeft ? stackView.arrangedSubviews.reversed() : stackView.arrangedSubviews
                guard let giftView = arrangedViews[i] as? VoiceRoomPKGiftUserView else {
                    return
                }
                if i < content.userList.count {
                    giftView.updateColor(Constants.leftColor)
                    giftView.updateUser(user: content.userList[i], rank: i + 1, isLeft: isLeft)
                } else {
                    giftView.updateColor(.clear)
                    giftView.updateUser(user: nil, rank: i + 1, isLeft: isLeft)
                }
//                stackView.addArrangedSubview(instance)
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
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
        pkState = .initial
        pkCountdownTimer?.invalidate()
        punishCountdownTimer?.invalidate()
        pkSeconds = 0
        punishmentSeconds = 0
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
