//
//  ChatListViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/25.
//

import UIKit
import RongIMKit
import SVProgressHUD

import RCSceneService

public class ChatListViewController: RCConversationListViewController {
    
    public var canCallComing: Bool = false
    
    public init(_ type: RCConversationType) {
        super.init(displayConversationTypes: [type.rawValue], collectionConversationType: [])
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        conversationListTableView.separatorStyle = .singleLine
        conversationListTableView.separatorColor = UIColor("#E3E5E6")
        conversationListTableView.separatorInset = UIEdgeInsets(top: 0, left: 71.resize, bottom: 0, right: 0)
        conversationListTableView.backgroundColor = .clear
        conversationListTableView.tableFooterView = UIView()
        
        navigationItem.title = "消息"
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back_indicator_image(),
//                                                           style: .plain,
//                                                           target: self,
//                                                           action: #selector(back))
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    public override func onSelectedTableRow(_ conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, at indexPath: IndexPath!) {
        guard let userId = model.targetId else {
            return
        }
        SVProgressHUD.show()
        UserInfoDownloaded.shared.refreshUserInfo(userId: userId) { [weak self] user in
            SVProgressHUD.dismiss()
            let userInfo = RCUserInfo(userId: user.userId, name: user.userName, portrait: user.portraitUrl)
            RCIM.shared().refreshUserInfoCache(userInfo, withUserId: user.userId)
            let controller = ChatViewController(.ConversationType_PRIVATE, userId: userId)
            controller.canCallComing = self?.canCallComing ?? false
            self?.show(controller, sender: self)
        }
    }
    
    public override func rcConversationListTableView(_ tableView: UITableView!, heightForRowAt indexPath: IndexPath!) -> CGFloat {
        return 72.resize
    }
    
    public override func willDisplayConversationTableCell(_ cell: RCConversationBaseCell!, at indexPath: IndexPath!) {
        super.willDisplayConversationTableCell(cell, at: indexPath)
        guard let cell = cell as? RCConversationCell else {
            return
        }
        cell.selectionStyle = .none
        cell.conversationTitle.font = UIFont.systemFont(ofSize: 17.resize, weight: .medium)
        cell.conversationTitle.textColor = UIColor(hexString: "#111F2C")
        cell.messageContentLabel.font = UIFont.systemFont(ofSize: 14.resize)
        cell.messageContentLabel.textColor = UIColor(hexString: "#A0A5AB")
        cell.messageCreatedTimeLabel.font = UIFont.systemFont(ofSize: 13.resize)
        cell.messageCreatedTimeLabel.textColor = UIColor(red: 0.73, green: 0.75, blue: 0.79, alpha: 0.6)
//        cell.headerImageView.contentMode = .scaleAspectFill
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
}
