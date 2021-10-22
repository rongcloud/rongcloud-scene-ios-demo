//
//  LiveVideoRoomHostController+More.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import SVProgressHUD

extension LiveVideoRoomHostController {
    
    func closeRoomDidClick() {
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
        SVProgressHUD.show()
        networkProvider.request(.closeRoom(roomId: room.roomId)) { result in
            switch result.map(AppResponse.self) {
            case let .success(response):
                if response.validate() {
                    SVProgressHUD.showSuccess(withStatus: "直播结束，房间已关闭")
                    RCLiveVideoEngine.shared().finish { [weak self] _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                } else {
                    SVProgressHUD.showSuccess(withStatus: "关闭房间失败")
                }
            case .failure:
                SVProgressHUD.showSuccess(withStatus: "关闭房间失败")
            }
        }
        networkProvider.request(.userUpdateCurrentRoom(roomId: "")) { _ in }
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

