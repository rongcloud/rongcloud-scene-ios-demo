//
//  RCRoomListViewController+Restore.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/14.
//

import UIKit
import RCSceneRoom

extension RCRoomListViewController {
    func checkRoomInfo() {
        guard RCRoomFloatingManager.shared.controller == nil else { return }
        let api = RCNetworkAPI.checkCurrentRoom
        networkProvider.request(api) { [weak self] result in
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(wrapper):
                self?.onUserComeBack(wrapper.data)
            case let .failure(error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    /// 当用户上次异常退出时，重新进入
    private func onUserComeBack(_ room: RCSceneRoom?) {
        guard let room = room else { return }
        guard presentedViewController == nil else { return }
        let controller = UIAlertController(title: "提示", message: "您有正在直播的房间，是否进入？", preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "进入", style: .default) { [unowned self] _ in enter(room) }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { [unowned self] _ in leave(room) }
        controller.addAction(sureAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    private func leave(_ room: RCSceneRoom) {
        networkProvider.request(.userUpdateCurrentRoom(roomId: "")) { _ in }
    }
}
