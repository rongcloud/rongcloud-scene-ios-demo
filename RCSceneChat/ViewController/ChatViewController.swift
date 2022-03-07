//
//  ChatViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/27.
//

import UIKit
import RongIMKit
import SVProgressHUD

import RCSceneService

public class ChatViewController: RCConversationViewController {
    
    public var canCallComing: Bool = false
    
    public init(_ type: RCConversationType, userId: String) {
        super.init(conversationType: type, targetId: userId)
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexString: "#F5F6F9")
        view.subviews.forEach {
            $0.backgroundColor = UIColor(hexString: "#F5F6F9")
        }
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back_indicator_image(),
//                                                           style: .plain,
//                                                           target: self,
//                                                           action: #selector(back))
        refreshUserInfo()
    }
    
    private func refreshUserInfo() {
        UserInfoDownloaded.shared.fetchUserInfo(userId: targetId) { [weak self] user in
            self?.navigationItem.title = user.userName
        }
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    public override func willDisplayMessageCell(_ cell: RCMessageBaseCell!, at indexPath: IndexPath!) {
        super.willDisplayMessageCell(cell, at: indexPath)
        
        if let cell = cell as? RCTextMessageCell {
            if cell.model.messageDirection == .MessageDirection_SEND {
                cell.textLabel.textColor = .white
                cell.bubbleBackgroundView.tintColor = UIColor(hexString: "#7983FE")
                cell.bubbleBackgroundView.image = cell.bubbleBackgroundView.image?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.textLabel.textColor = .black
                cell.bubbleBackgroundView.tintColor = UIColor.white
                cell.bubbleBackgroundView.image = cell.bubbleBackgroundView.image?.withRenderingMode(.alwaysTemplate)
            }
        } else if let cell = cell as? RCVoiceMessageCell {
            let tempImageView = ChatroomVoiceImageView(frame: .zero)
            tempImageView.image = cell.playVoiceView.image
            tempImageView.frame = cell.playVoiceView.frame
            cell.playVoiceView.removeFromSuperview()
            cell.messageContentView.addSubview(tempImageView)
            cell.playVoiceView = tempImageView
            if cell.model.messageDirection == .MessageDirection_SEND {
                cell.voiceDurationLabel.textColor = .white
                tempImageView.tintColor = .white
                cell.bubbleBackgroundView.tintColor = UIColor(hexString: "#7983FE")
                cell.bubbleBackgroundView.image = cell.bubbleBackgroundView.image?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.voiceDurationLabel.textColor = .black
                tempImageView.tintColor = .black
                cell.bubbleBackgroundView.tintColor = UIColor.white
                cell.bubbleBackgroundView.image = cell.bubbleBackgroundView.image?.withRenderingMode(.alwaysTemplate)
            }
        }
        
//        if let cell = cell as? RCMessageCell {
//            cell.portraitImageView.contentMode = .scaleAspectFill
//        }
    }
    
    public override func didTapMessageCell(_ model: RCMessageModel!) {
        //  call
        if model.content?.classForCoder.getObjectName() == "RC:VCSummary" {
            if !canCallComing {
                return SVProgressHUD.showInfo(withStatus: "请先退出房间，再进行通话")
            }
        }
        super.didTapMessageCell(model)
    }
    
    public override func pluginBoardView(_ pluginBoardView: RCPluginBoardView!, clickedItemWithTag tag: Int) {
        //  call
        if tag == 1101 || tag == 1102 {
            if canCallComing == false {
                return SVProgressHUD.showInfo(withStatus: "请先退出房间，再进行通话")
            }
        }
        super.pluginBoardView(pluginBoardView, clickedItemWithTag: tag)
    }
}

final class ChatroomVoiceImageView: UIImageView {
    override var image: UIImage? {
        get {
            super.image
        }
        set {
            super.image = newValue?.withRenderingMode(.alwaysTemplate)
        }
    }
}
