//
//  RCRadioRoomViewController+Suspend.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import SVProgressHUD

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func suspend_viewDidLoad() {
        m_viewDidLoad()
        roomSuspendView.continueLive = { [unowned self] in resume() }
    }
    
    func resume() {
        SVProgressHUD.show()
        networkProvider.request(.resumeRoom(roomId: roomInfo.roomId)) { [weak self] result in
            switch result.map(AppResponse.self) {
            case let .success(res):
                if res.validate() {
                    SVProgressHUD.dismiss(withDelay: 0.3)
                    self?.roomDidResume()
                    self?.roomKVState.update(suspend: false)
                } else {
                    SVProgressHUD.showError(withStatus: "网络请求失败")
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
        enterSeat { _ in }
    }
    
    func suspend() {
        SVProgressHUD.show()
        networkProvider.request(.suspendRoom(roomId: roomInfo.roomId)) { [weak self] result in
            switch result.map(AppResponse.self) {
            case let .success(res):
                if res.validate() {
                    SVProgressHUD.dismiss(withDelay: 0.3)
                    self?.roomDidSuspend()
                    self?.roomKVState.update(suspend: true)
                } else {
                    SVProgressHUD.showError(withStatus: "网络请求失败")
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
        leaveSeat { _ in }
    }
    
    func roomDidResume() {
        UIView.animate(withDuration: 0.37, animations: { [unowned self] in
            roomSuspendView.alpha = 0
            roomOwnerView.alpha = 1
        }, completion: { [unowned self] _ in
            roomSuspendView.removeFromSuperview()
        })
    }
    
    func roomDidSuspend() {
        view.addSubview(roomSuspendView)
        if roomInfo.isOwner {
            roomSuspendView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            roomSuspendView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(roomInfoView.snp.bottom).offset(41.resize)
                make.bottom.equalTo(messageView.snp.top)
            }
        }
        roomSuspendView.alpha = 0
        UIView.animate(withDuration: 0.37, animations: { [unowned self] in
            roomSuspendView.alpha = 1
            roomOwnerView.alpha = 0
        })
    }
}
