//
//  ViewController.swift
//  RCSceneRoomSetting
//
//  Created by shaoshuai on 01/27/2022.
//  Copyright (c) 2022 shaoshuai. All rights reserved.
//

import RCSceneRoomSetting

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func test() {
        let notice = "欢迎来到TEST"
        let items: [Item] = {
            return [
                .roomLock(true),
                .roomName("roomName"),
                .roomNotice(notice),
                .forbidden,
                .cameraSwitch,
                .beautySticker,
                .beautyRetouch,
                .beautyMakeup,
                .beautyEffect,
                .music,
                .cameraSetting,
                .seatFree(true)
            ]
        }()
        let controller = RCSceneRoomSettingViewController(items: items, delegate: self)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
}

extension ViewController: RCSceneRoomSettingProtocol {
    func eventWillTrigger(_ item: Item) -> Bool {
        return false
    }
    
    func eventDidTrigger(_ item: Item, extra: String?) {
    }
}
