//
//  RCVRMView.swift
//  RCVoiceRoomMessage
//
//  Created by shaoshuai on 2021/8/10.
//

import UIKit

public class RCVRMView: UIView {
    
    public weak var dataSource: RCVRMViewDataSource?
    public weak var delegate: RCVRMViewDelegate?
    
    private lazy var messages = [RCMessageContent]()
    
    public lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.register(RCVRMMessageCell.self, forCellReuseIdentifier: "Cell")
        instance.register(RCVRMVoiceMessageCell.self, forCellReuseIdentifier: "VoiceCell")
        instance.delegate = self
        instance.dataSource = self
        instance.backgroundColor = .clear
        instance.separatorColor = .clear
        instance.translatesAutoresizingMaskIntoConstraints = false
        return instance
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        [
            NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
        ].forEach { $0.isActive = true }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func add(_ message: RCMessageContent) {
        DispatchQueue.main.async {
            self.addChatMessage(message)
        }
    }
    
    public func reloadMessages() {
        mIds_E = dataSource?.voiceRoomViewManagerIds(self) ?? []
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func addChatMessage(_ message: RCMessageContent) {
        guard let _ = message as? RCVRMMessage else { return }
        let isBottom = tableView.isReachBottom
        messages.append(message)
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .none)
        if isBottom { tableView.scrollToRow(at: indexPath, at: .bottom, animated: true) }
    }
}

extension RCVRMView: UITableViewDataSource, RCVRMMessageCellProtocol {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = messages[indexPath.row] as? RCVRMMessage else { return UITableViewCell() }
        if messages[indexPath.row].isKind(of: RCVRVoiceMessage.self) {
            let voiceMessage = messages[indexPath.row] as! RCVRVoiceMessage
            return (tableView.dequeueReusableCell(withIdentifier: "VoiceCell", for: indexPath) as! RCVRMVoiceMessageCell)
                .update(voiceMessage, delegate: self)
        }
        return (tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RCVRMMessageCell)
            .update(message, delegate: self)
    }
    
    func onUserClicked(_ userId: String) {
        delegate?.voiceRoomView(self, didClick: userId)
    }
}

extension RCVRMView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

public extension RCVRMView {
    func update(cId: String, rName: String, uId: String) {
        cId_E = uId
        oId_E = cId
        oName_E = rName
        tableView.reloadData()
    }
}

extension UITableView {
    var isReachBottom: Bool {
        guard let items = indexPathsForVisibleRows else {
            return false
        }
        guard let count = dataSource?.tableView(self, numberOfRowsInSection: 0) else {
            return false
        }
        return (items.max()?.row ?? 0) >= count - 2
    }
}

public protocol RCVRMViewDataSource: AnyObject {
    func voiceRoomViewManagerIds(_ view: RCVRMView) -> [String]
}

public protocol RCVRMViewDelegate: AnyObject {
    func voiceRoomView(_ view: RCVRMView, didClick userId: String)
}
