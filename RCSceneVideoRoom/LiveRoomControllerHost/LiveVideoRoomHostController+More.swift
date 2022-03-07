//
//  LiveVideoRoomHostController+More.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import UIKit
import RCSceneMusic

extension LiveVideoRoomHostController {
    
    func closeRoomDidClick() {
        if RCLiveVideoEngine.shared().pkInfo != nil {
            return SVProgressHUD.showError(withStatus: "当前 PK 中，无法进行此操作")
        }
        let controller = UIAlertController(title: "提示", message: "确定结束本次直播么？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(cancelAction)
        let sureAction = UIAlertAction(title: "确认", style: .default) { [unowned self] _ in
            closeRoom()
        }
        controller.addAction(sureAction)
        present(controller, animated: true)
    }
    
    func closeRoom() {
        clearMusicData()
        SVProgressHUD.show()
        videoRoomService.closeRoom(roomId: room.roomId) { result in
            switch result.map(AppResponse.self) {
            case let .success(response):
                if response.validate() {
                    SVProgressHUD.showSuccess(withStatus: "直播结束，房间已关闭")
                    RCLiveVideoEngine.shared().leaveRoom { [weak self] _ in
                        self?.navigationController?.popViewController(animated: true)
                        DataSourceImpl.instance.clear()
                        PlayerImpl.instance.clear()
                    }
                } else {
                    SVProgressHUD.showSuccess(withStatus: "关闭房间失败")
                }
            case .failure:
                SVProgressHUD.showSuccess(withStatus: "关闭房间失败")
            }
        }
        videoRoomService.userUpdateCurrentRoom(roomId: "") { _ in }
    }
    
    func clearMusicData() {
        DataSourceImpl.instance.clear()
        PlayerImpl.instance.clear()
        DelegateImpl.instance.clear()
    }
}

extension LiveVideoRoomHostController: LiveVideoRoomMoreDelegate {
    func sceneRoom(_ view: RCLiveVideoRoomMoreView, didClick action: LiveVideoRoomMoreAction) {
        switch action {
        case .quit:
            closeRoomDidClick()
        default:
            fatalError("unsupport action")
        }
    }
}

