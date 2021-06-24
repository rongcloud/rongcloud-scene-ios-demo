//
//  VoiceRoomAlertViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/25.
//

import UIKit

enum VoiceRoomAlertAction {
    case confirm(String)
    case cancel(String)
}

protocol VoiceRoomAlertProtocol: AnyObject {
    func cancelDidClick(alertType: String)
    func confirmDidClick(alertType: String)
}

class VoiceRoomAlertViewController: UIViewController {
    private weak var delegate: VoiceRoomAlertProtocol?
    private let alertType: String
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 12
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var blurView: UIVisualEffectView = {
        let instance = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 15, weight: .medium)
        instance.textColor = .white
        instance.numberOfLines = 0
        instance.textAlignment = .center
        return instance
    }()
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitleColor(.white, for: .normal)
        instance.addTarget(self, action: #selector(handleCancleButtonClick), for: .touchUpInside)
        return instance
    }()
    private lazy var confirmButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitleColor(R.color.hexEF499A(), for: .normal)
        instance.addTarget(self, action: #selector(handleConfirmButtonClick), for: .touchUpInside)
        return instance
    }()
    private lazy var sepratorline1: UIView = {
        let instance = UIView()
        instance.backgroundColor = .white.withAlphaComponent(0.2)
        return instance
    }()
    private lazy var sepratorline2: UIView = {
        let instance = UIView()
        instance.backgroundColor = .white.withAlphaComponent(0.2)
        return instance
    }()
    private let actions: [VoiceRoomAlertAction]
    
    init(title: String, actions: [VoiceRoomAlertAction], alertType: String, delegate: VoiceRoomAlertProtocol?) {
        self.delegate = delegate
        self.actions = actions
        self.alertType = alertType
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    private func buildLayout() {
        view.backgroundColor = .clear
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(titleLabel)
        container.addSubview(cancelButton)
        container.addSubview(confirmButton)
        container.addSubview(sepratorline1)
        container.addSubview(sepratorline2)
        
        container.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40.resize)
            make.center.equalToSuperview()
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35.resize)
            make.left.right.equalToSuperview().inset(20.resize)
        }
        
        sepratorline1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40.resize)
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
        }
        for action in actions {
            switch action {
            case let .confirm(title):
                confirmButton.setTitle(title, for: .normal)
            case let .cancel(title):
                cancelButton.setTitle(title, for: .normal)
            }
        }
        if actions.count == 2 {
            cancelButton.snp.makeConstraints { make in
                make.left.bottom.equalToSuperview()
                make.top.equalTo(sepratorline1.snp.bottom)
                make.height.equalTo(44)
                make.width.equalToSuperview().multipliedBy(0.5)
            }
            
            confirmButton.snp.makeConstraints { make in
                make.size.equalTo(cancelButton)
                make.right.equalToSuperview()
                make.centerY.equalTo(cancelButton)
            }
            
            sepratorline2.snp.makeConstraints { make in
                make.width.equalTo(1)
                make.centerX.equalToSuperview()
                make.top.equalTo(sepratorline1.snp.bottom)
                make.bottom.equalToSuperview()
            }
        } else {
            confirmButton.snp.makeConstraints { make in
                make.left.bottom.right.equalToSuperview()
                make.top.equalTo(sepratorline1.snp.bottom)
                make.height.equalTo(44)
            }
        }
    }
    
    @objc private func handleCancleButtonClick() {
        delegate?.cancelDidClick(alertType: alertType)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleConfirmButtonClick() {
        delegate?.confirmDidClick(alertType: alertType)
        dismiss(animated: true, completion: nil)
    }
}
