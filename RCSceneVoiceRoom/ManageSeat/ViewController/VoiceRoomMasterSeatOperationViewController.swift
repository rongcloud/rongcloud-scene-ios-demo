//
//  OwnerSeatPopViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/11.
//

import UIKit
import RCSceneService

protocol VoiceRoomMasterSeatOperationProtocol: AnyObject {
    func didMasterLeaveButtonClicked()
    func didMasterSeatMuteButtonClicked(_ isMute: Bool)
}

class VoiceRoomMasterSeatOperationViewController: UIViewController {
    private let userId: String
    private let isMute: Bool
    weak var delegate: VoiceRoomMasterSeatOperationProtocol?
    private lazy var popView: OwnerSeatPopView = {
        return OwnerSeatPopView {
            [weak self] in
            self?.delegate?.didMasterLeaveButtonClicked()
        } muteSeatCallback: {
            [weak self] in
            guard let self = self else { return }
            self.delegate?.didMasterSeatMuteButtonClicked(!self.isMute)
            self.dismiss(animated: true, completion: nil)
        }
    }()
    
    init(userId: String, isMute: Bool, delegate: VoiceRoomMasterSeatOperationProtocol) {
        self.delegate = delegate
        self.userId = userId
        self.isMute = isMute
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableClickingDismiss()
        view.addSubview(popView)
        
        popView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
        }
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
            self?.popView.updateView(user: user)
        }
        if isMute || RCVoiceRoomEngine.sharedInstance().isDisableAudioRecording() {
            popView.muteButton.setTitle("打开麦克风", for: .normal)
        } else {
            popView.muteButton.setTitle("关闭麦克风", for: .normal)
        }
    }
}
