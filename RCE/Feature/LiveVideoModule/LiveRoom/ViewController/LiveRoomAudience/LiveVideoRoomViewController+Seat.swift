//
//  LiveVideoRoomViewController+Seat.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/24.
//

import SVProgressHUD

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: role)
    private var seat_role: RCRTCLiveRoleType {
        get { role }
        set {
            role = newValue
            toolBarView.micState = role == .broadcaster ? .connecting : .request
        }
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func seat_viewDidLoad() {
        m_viewDidLoad()
        toolBarView.add(requset: self, action: #selector(micRequestDidClick))
    }
    
    @objc private func micRequestDidClick() {
        switch toolBarView.micState {
        case .request: requestSeat()
        case .waiting:
            let controller = RCLVRCancelMicViewController(.request, delegate: self)
            present(controller, animated: true)
        case .connecting:
            let controller = RCLVRCancelMicViewController(.connection, delegate: self)
            present(controller, animated: true)
        }
    }
    
    func requestSeat() {
        guard toolBarView.micState == .request else { return }
        RCLiveVideoEngine.shared().requestLiveVideo(-1, completion: { [weak self] code in
            DispatchQueue.main.async {
                if code == .success {
                    SVProgressHUD.showSuccess(withStatus: "已申请连线，等待房主接受")
                    self?.toolBarView.micState = .waiting
                } else {
                    SVProgressHUD.showError(withStatus: "请求连麦失败\(code.rawValue)")
                }
            }
        })
    }
}
