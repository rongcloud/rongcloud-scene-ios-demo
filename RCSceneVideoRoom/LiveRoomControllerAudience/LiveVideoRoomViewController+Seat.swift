//
//  LiveVideoRoomViewController+Seat.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/24.
//

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: role)
    private var seat_role: RCRTCLiveRoleType {
        get { role }
        set {
            role = newValue
            if role == .broadcaster {
                micButton.micState = .connecting
            } else if micButton.micState == .connecting {
                micButton.micState = .request
            }
        }
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func seat_viewDidLoad() {
        m_viewDidLoad()
        micButton.addTarget(self, action: #selector(micRequestDidClick), for: .touchUpInside)
    }
    
    var seatInfo: RCLiveVideoSeat? {
        RCLiveVideoEngine
            .shared()
            .currentSeats
            .first(where: { $0.userId == Environment.currentUserId })
    }
    
    @objc private func micRequestDidClick() {
        switch micButton.micState {
        case .request: requestSeat()
        case .waiting: waitingSeat()
        case .connecting: connectingSeat()
        default: ()
        }
    }
    
    func requestSeat(_ index: Int = -1) {
        if RCLiveVideoEngine.shared().pkInfo != nil {
            return SVProgressHUD.showError(withStatus: "当前 PK 中，无法进行操作")
        }
        guard micButton.micState == .request else { return }
        if isSeatFreeEnter {
            enterSeat(index)
        } else {
            RCLiveVideoEngine.shared().requestLiveVideo(index, completion: { code in
                if code == .success {
                    SVProgressHUD.showSuccess(withStatus: "已申请连线，等待房主接受")
                    self.micButton.micState = .waiting
                } else {
                    SVProgressHUD.showError(withStatus: "请求连麦失败\(code.rawValue)")
                }
            })
        }
    }
    
    func enterSeat(_ index: Int) {
        if RCLiveVideoEngine.shared().pkInfo != nil {
            SVProgressHUD.showError(withStatus: "当前 PK 中，无法进行操作")
        }
        SVProgressHUD.show()
        RCLiveVideoEngine.shared().joinLiveVideo(at: index) { code in
            switch code {
            case .success:
                SVProgressHUD.showSuccess(withStatus: "上麦成功")
                self.micButton.micState = .connecting
            default:
                SVProgressHUD.showError(withStatus: "没有可用麦位")
            }
        }
    }
    
    func waitingSeat() {
        let controller = RCLVRAlertWaitingViewController()
        controller.delegate = self
        present(controller, animated: false)
    }
    
    func connectingSeat() {
        guard let seatInfo = seatInfo else { return }
        let controller = RCLVRAlertConnectingViewController(seatInfo)
        controller.delegate = self
        present(controller, animated: false)
    }
    
    func switchSeat(_ seat: RCLiveVideoSeat) {
        guard let currentSeat = seatInfo else { return }
        if currentSeat.index == seat.index { return }
        RCLiveVideoEngine.shared().switchLiveVideo(to: seat.index) { code in
            debugPrint("switchLiveVideo \(code.rawValue)")
            SceneRoomManager.updateLiveSeatList()
        }
    }
    
    func otherUserSeat(_ seat: RCLiveVideoSeat) {
        
    }
}

extension LiveVideoRoomViewController: RCLVRAlertDelegate {
    func didClickAction(_ action: RCLVRSheetAlertActionType) {
        switch action {
        case .cancelRequest:
            micButton.micState = .request
        case .hangUp:
            micButton.micState = .request
            role = .audience
        default: ()
        }
    }
}
