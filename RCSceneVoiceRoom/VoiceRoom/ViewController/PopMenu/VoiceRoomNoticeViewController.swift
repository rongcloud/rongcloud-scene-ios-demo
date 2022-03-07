//
//  VoiceRoomNoticeViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/2.
//

import UIKit
import IQKeyboardManager

class VoiceRoomNoticeViewController: UIViewController {
    weak var delegate: VoiceRoomNoticeDelegate?
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
        instance.text = "房间公告"
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
        instance.backgroundColor = UIColor(hexString: "#EF499A")
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
        instance.layer.borderColor = UIColor(hexString: "#EF499A").cgColor
        instance.setTitleColor(UIColor(hexString: "#EF499A"), for: .normal)
        instance.addTarget(self, action: #selector(dismissCurrent), for: .touchUpInside)
        return instance
    }()
    private let modify: Bool
    private let notice: String
    init(modify: Bool = false, notice: String, delegate: VoiceRoomNoticeDelegate) {
        self.modify = modify
        self.delegate = delegate
        self.notice = notice
        super.init(nibName: nil, bundle: nil)
        textView.text = notice
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        if modify { textView.becomeFirstResponder() }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        view.addSubview(containerView)
        containerView.addSubview(effectView)
        containerView.addSubview(noticeTitleLabel)
        containerView.addSubview(textView)
        containerView.addSubview(confirmButton)
        containerView.addSubview(cancelButton)
        
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(50.resize)
            make.center.equalToSuperview()
        }
        
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        noticeTitleLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(46)
        }
        
        if modify {
            noticeTitleLabel.text = "修改房间公告"
            textView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(22.resize)
                make.top.equalTo(noticeTitleLabel.snp.bottom).offset(20)
                make.height.equalTo(textView.snp.width).multipliedBy(0.5)
            }
            
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
            textView.isEditable = false
            textView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(22.resize)
                make.top.equalTo(noticeTitleLabel.snp.bottom).offset(20)
                make.height.equalTo(textView.snp.width)
                make.bottom.equalToSuperview().inset(20)
            }
        }
    }
    
    @objc private func handleConfirm() {
        delegate?.noticeDidModified(notice: textView.text)
        dismissCurrent()
    }
}

extension VoiceRoomNoticeViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 100
    }
}
