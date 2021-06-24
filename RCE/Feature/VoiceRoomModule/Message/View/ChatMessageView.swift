//
//  ChatMessageView.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/20.
//

import UIKit

protocol ChatMessageViewProtocol: AnyObject {
    func onUserClicked(_ userId: String)
}

class ChatMessageView: UIView {
    weak var delegate: ChatMessageViewProtocol?
    private let roomInfo: VoiceRoom
    private lazy var chatEvents = [VoiceRoomChatEvent]()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.register(cellType: ChatEventTableViewCell.self)
        instance.delegate = self
        instance.dataSource = self
        instance.backgroundColor = .clear
        instance.separatorColor = .clear
        return instance
    }()
    
    init(_ roomInfo: VoiceRoom) {
        self.roomInfo = roomInfo
        super.init(frame: .zero)
        
        chatEvents.append(VoiceRoomChatEventWelcome(roomName: roomInfo.roomName))
        chatEvents.append(VoiceRoomChatEventStatement())
        
        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        VoiceRoomChatEventManger.shared.roomUserId = roomInfo.userId
        
        fetchLatest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchLatest() {
        let roomId = roomInfo.roomId
        let count = 10
        let option = RCRemoteHistoryMsgOption()
        option.count = count
        RCCoreClient.shared()
            .getRemoteHistoryMessages(.ConversationType_CHATROOM, targetId: roomId, option: option)
            { [weak self] messages, success in
                guard
                    let self = self,
                    let messages = messages as? [RCMessage]
                else { return }
                let events: [VoiceRoomChatEvent] = messages.compactMap({ message in
                    return message.content as? VoiceRoomChatEvent
                })
                DispatchQueue.main.async {
                    self.chatEvents.insert(contentsOf: events, at: 0)
                    self.tableView.reloadData()
                }
            } error: { eCode in
                print("ecode:\(eCode.rawValue)")
            }
    }
    
    public func add(_ event: VoiceRoomChatEvent) {
        let isBottom = tableView.indexPathsForVisibleRows?.first(where: {$0.row <= chatEvents.count - 2}) != nil
        chatEvents.append(event)
        let indexPath = IndexPath(item: chatEvents.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .none)
        if isBottom {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    public func handle(_ message: RCMessage) {
        guard
            message.conversationType == .ConversationType_CHATROOM,
            message.targetId == roomInfo.roomId,
            let chatMessage = message.content as? VoiceRoomChatEvent
            else { return }
        DispatchQueue.main.async {
            self.add(chatMessage)
        }
    }
    
    public func update(_ managers: [VoiceRoomUser]) {
        VoiceRoomChatEventManger.shared.managerUsers = managers
        tableView.reloadData()
    }
}

extension ChatMessageView: UITableViewDataSource, ChatEventTableViewCellProtocol {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(for: indexPath, cellType: ChatEventTableViewCell.self)
            .update(chatEvents[indexPath.row], delegate: self)
    }
    
    func onUserClicked(_ userId: String) {
        delegate?.onUserClicked(userId)
    }
}

extension ChatMessageView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

import RxSwift
import RxCocoa

extension Reactive where Base: ChatMessageView {
    func handleMessage() -> Binder<RCMessage> {
        Binder(self.base) { view, message in
            view.handle(message)
        }
    }
    
    func addEvent() -> Binder<VoiceRoomChatEvent> {
        Binder(self.base) { view, event in
            view.add(event)
        }
    }
}
