//
//  NoticeViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/2.
//

import UIKit

public class NoticeViewController: UIViewController {
    private weak var delegate: RCSceneRoomSettingProtocol?
    
    private lazy var containerView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 6
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        return UIVisualEffectView(effect: blurEffect)
    }()
    private lazy var noticeTitleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17, weight: .bold)
        instance.textColor = .white
        instance.textAlignment = .center
        instance.text = editable ? "修改房间公告" : "房间公告"
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        return instance
    }()
    private lazy var textView: UITextView = {
        let instance = UITextView()
        instance.backgroundColor = .clear
        instance.textColor = .white
        instance.font = .systemFont(ofSize: 14)
        instance.delegate = self
        return instance
    }()
    private lazy var confirmButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = R.color.hexEF499A()
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitle("确定", for: .normal)
        instance.layer.cornerRadius = 4
        instance.setTitleColor(.white, for: .normal)
        instance.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        return instance
    }()
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitle("取消", for: .normal)
        instance.layer.cornerRadius = 4
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = R.color.hexEF499A()?.cgColor
        instance.setTitleColor(R.color.hexEF499A(), for: .normal)
        instance.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return instance
    }()
    
    private let editable: Bool
    private let notice: String
    public init(_ editable: Bool = false, notice: String, delegate: RCSceneRoomSettingProtocol) {
        self.editable = editable
        self.notice = notice
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        textView.text = notice
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = editable
        buildLayout()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if editable {
            textView.becomeFirstResponder()
        }
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        enableTextViewAdaptor()
        
        view.addSubview(containerView)
        containerView.addSubview(effectView)
        containerView.addSubview(noticeTitleLabel)
        containerView.addSubview(textView)
        
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(50.resize)
            make.centerY.equalToSuperview().priority(500)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        noticeTitleLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(46)
        }
        
        if editable {
            textView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(22.resize)
                make.top.equalTo(noticeTitleLabel.snp.bottom).offset(20)
                make.height.equalTo(textView.snp.width).multipliedBy(0.5)
            }
            
            containerView.addSubview(confirmButton)
            containerView.addSubview(cancelButton)
            
            confirmButton.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 100, height: 40))
                make.top.equalTo(textView.snp.bottom).offset(20)
                make.bottom.equalToSuperview().inset(20)
                make.left.equalTo(containerView.snp.centerX).offset(6)
            }
            
            cancelButton.snp.makeConstraints { make in
                make.size.equalTo(confirmButton)
                make.right.equalTo(containerView.snp.centerX).offset(-6)
                make.centerY.equalTo(confirmButton)
            }
        } else {
            textView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(22.resize)
                make.top.equalTo(noticeTitleLabel.snp.bottom).offset(20)
                make.height.equalTo(textView.snp.width)
                make.bottom.equalToSuperview().inset(20)
            }
        }
    }
    
    @objc private func handleConfirm() {
        guard
            let text = textView.text,
            let delegate = delegate
        else { fatalError("notice error") }
        dismiss(animated: true) {
            delegate.eventDidTrigger(.roomNotice(text), extra: nil)
        }
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
}

extension NoticeViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 100
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        confirmButton.isEnabled = {
            guard let text = textView.text else { return false }
            return text.count > 0
        }()
    }
    
    func enableTextViewAdaptor() {
        let name = UIApplication.keyboardWillChangeFrameNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidUpdate(_:)),
                                               name: name,
                                               object: nil)
    }
    
    @objc private func keyboardDidUpdate(_ notification: Notification) {
        guard let info = notification.userInfo else {
            return
        }
        
        let frameEndKey = UIResponder.keyboardFrameEndUserInfoKey
        guard let frameEndValue = info[frameEndKey] as? NSValue else {
            return
        }
        
        let frameEnd = frameEndValue.cgRectValue
        containerView.snp.updateConstraints { make in
            make.bottom.lessThanOrEqualToSuperview().inset(frameEnd.height + 20)
        }
    }
}
