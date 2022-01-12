//
//  LiveVideoRoomViewController+More.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/15.
//

import SVProgressHUD

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: role)
    private var more_role: RCRTCLiveRoleType {
        get { role }
        set {
            role = newValue
            switch role {
            case .broadcaster:
                navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                (parent as? RCRoomContainerViewController)?.disableSwitchRoom()
            case .audience:
                navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                (parent as? RCRoomContainerViewController)?.enableSwitchRoom()
            @unknown default: ()
            }
        }
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func more_viewDidLoad() {
        m_viewDidLoad()
    }
}


extension LiveVideoRoomViewController: LiveVideoRoomMoreDelegate {
    func sceneRoom(_ view: RCLiveVideoRoomMoreView, didClick action: LiveVideoRoomMoreAction) {
        switch action {
        case .leave:
            leaveRoom()
        case .quit:
            closeRoomDidClick()
        case .minimize:
            if role == .broadcaster {
                return SVProgressHUD.showInfo(withStatus: "连麦中禁止此操作")
            }
            scaleRoomDidClick()
        }
    }
    
    func closeRoomDidClick() {
        let controller = UIAlertController(title: "提示", message: "确定结束本次连麦么？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(cancelAction)
        let sureAction = UIAlertAction(title: "确认", style: .default) { _ in
            RCLiveVideoEngine.shared()
                .leaveLiveVideo({ [weak self] _ in
                    self?.liveVideoDidFinish(.leave)
                })
        }
        controller.addAction(sureAction)
        present(controller, animated: true)
    }
    
    func scaleRoomDidClick() {
        guard let controller = parent as? RCRoomContainerViewController else { return }
        RCRoomFloatingManager.shared.show(controller)
        navigationController?.popViewController(animated: false)
    }
}
