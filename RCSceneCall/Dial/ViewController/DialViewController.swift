//
//  BeginCallViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/29.
//

import UIKit
import RxDataSources
import ReactorKit
import RxSwift
import SVProgressHUD
import MessageUI

public class DialViewController: UIViewController, View {
    public var disposeBag: DisposeBag = DisposeBag()
    private lazy var serviceView = DialServiceView()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = UIColor(hexString: "#F5F6F9")
        instance.separatorStyle = .none
        instance.register(cellType: DialHistoryTableViewCell.self)
        return instance
    }()
    private lazy var keyboardButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.dial_keyboard_icon(), for: .normal)
        return instance
    }()
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<DialSection> = {
        return RxTableViewSectionedReloadDataSource<DialSection> { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: DialHistoryTableViewCell.self)
            cell.updateCell(history: item)
            return cell
        }
    }()
    private lazy var emptyView = DialHistoryEmptyView()
    private let dialView = DialKeyboardView()
    public let type: CallType
    
    private weak var callSession: RCCallSession?
    
    public init(type: CallType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        self.reactor = DialReactor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = type == .audio ? "语音通话" : "视频通话"
        buildLayout()
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(onCallSessionCreated(_:)),
                         name: .RCCallNewSessionCreation,
                         object: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showDialView(isShow: true)
    }
    
    public func bind(reactor: DialReactor) {
        reactor.state
            .map(\.sections)
            .do(onNext: { [weak self] sections in
                guard let self = self else { return }
                let count = sections.reduce(0) { partialResult, section in
                    return partialResult + section.items.count
                }
                self.emptyView.isHidden = count > 0
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        keyboardButton.rx.tap.subscribe(onNext: {
            [weak self] value in
            guard let self = self else { return }
            self.showDialView(isShow: true)
        }).disposed(by: disposeBag)
        
        dialView.rx.hideDidTap.subscribe(onNext: {
            [weak self] value in
            guard let self = self else { return }
            self.showDialView(isShow: false)
        }).disposed(by: disposeBag)
        
        dialView.rx.dialNumber
            .map {
                number in
                Reactor.Action.callNumber(phone: number)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        dialView.rx.currentInput
            .map {
                input in
                Reactor.Action.inputPhone(value: input)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        dialView.rx.inviteCurrentDidTap.debug()
            .subscribe(onNext: {
                [weak self] value in
                guard let self = self else { return }
                self.sendMessage(phone: value)
            }).disposed(by: disposeBag)
        
        reactor.state
            .map(\.shouldInvite)
            .map {
                !$0
            }
            .bind(to: dialView.rx.isShowInviteButton)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.shouldInvite)
            .map {
                !$0
            }
            .bind(to: dialView.rx.isShowInviteLabel)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.error)
            .map(\.message)
            .distinctUntilChanged()
            .bind(to: SVProgressHUD.rx.errorStatus)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.hudShowing)
            .distinctUntilChanged()
            .subscribe(onNext: {
                value in
                if value {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
                }
            }).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(DialHistory.self)
            .map { Reactor.Action.callHistory(history: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.callingUid)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] uid in
                guard let self = self, let uid = uid else { return }
                RCCall.shared().startSingleCall(uid, mediaType: self.type.mediaType)
            })
            .disposed(by: disposeBag)
    }
    
    private func sendMessage(phone: String) {
        let composeVC = MFMessageComposeViewController()
        // Configure the fields of the interface.
        composeVC.recipients = [phone]
        composeVC.messageComposeDelegate = self
        composeVC.body =
            """
        【融云全球通信云】安全·可靠的全球互联网通信云
        为您的应用提供高效快捷的音视频服务
        您的伙伴邀请您加入体验
        点击链接下载：https://www.rongcloud.cn/demo/proxy/RC_RTC
        """
        present(composeVC, animated: true, completion: nil)
    }
    
    private func buildLayout() {
        view.backgroundColor = UIColor(hexString: "#F5F6F9")
        view.addSubview(serviceView)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(keyboardButton)
        view.addSubview(dialView)
        
        serviceView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(72.resize)
        }
        
        emptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(132.resize)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(serviceView.snp.bottom)
            make.bottom.equalTo(dialView.snp.top)
        }
        
        keyboardButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 53, height: 53))
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24.resize)
        }
        
        dialView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
    }
    
    private func showDialView(isShow: Bool) {
        if isShow {
            dialView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
        } else {
            dialView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(view.snp.bottom)
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func onCallSessionCreated(_ notification: Notification) {
        guard let callSession = notification.object as? RCCallSession else { return }
        callSession.add(self)
        self.callSession = callSession
    }
}

extension DialViewController: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension RCCallSession {
    var isHangUp: Bool {
        return disconnectReason == .hangup || disconnectReason == .remoteHangup
    }
}

extension DialViewController: RCCallSessionDelegate {
    public func callDidDisconnect() {
        guard let callSession = callSession, callSession.isHangUp else { return }
        UserDefaults.standard.increaseFeedbackCountdown()
        guard UserDefaults.standard.shouldShowFeedback() else { return }
        callRouter?.feedback()
    }
}
