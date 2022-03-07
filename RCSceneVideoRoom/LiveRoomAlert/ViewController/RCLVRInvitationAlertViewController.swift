//
//  RCLVRInvitationAlertViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/10/8.
//

import UIKit
import SVProgressHUD

class RCLVRInvitationAlertViewController: UIViewController {
    
    private lazy var alertView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .white
        instance.layer.cornerRadius = 12.resize
        instance.layer.masksToBounds = true
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 15.resize)
        instance.textColor = UIColor(byteRed: 51, green: 51, blue: 51)
        instance.textAlignment = .center
        return instance
    }()
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.setTitle("取消", for: .normal)
        instance.setTitleColor(UIColor(byteRed: 51, green: 51, blue: 51), for: .normal)
        instance.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return instance
    }()
    private lazy var sureButton: UIButton = {
        let instance = UIButton()
        instance.setTitle("确定", for: .normal)
        instance.setTitleColor(UIColor(byteRed: 239, green: 73, blue: 154), for: .normal)
        instance.addTarget(self, action: #selector(sure), for: .touchUpInside)
        return instance
    }()
    private lazy var vLine: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(byteRed: 229, green: 230, blue: 231)
        return instance
    }()
    private lazy var hLine: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(byteRed: 229, green: 230, blue: 231)
        return instance
    }()
    
    private var time: Int = 10
    private lazy var timer = Timer(timeInterval: 1, repeats: true) { [weak self] timer in
        guard let self = self else { return }
        self.time -= 1
        let message = "主播邀请您连线，是否同意？\(self.time)s"
        self.titleLabel.text = message
        if self.time <= 0 {
            self.overTime()
        }
    }
    
    private let inviter: String
    private let index: Int
    init(_ inviter: String, index: Int) {
        self.inviter = inviter
        self.index = index
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        RunLoop.main.add(timer, forMode: .common)
        
        let message = "主播邀请您连线，是否同意？\(time)s"
        titleLabel.text = message
    }
    
    @objc private func cancel() {
        timer.invalidate()
        dismissAlert()
        RCLiveVideoEngine.shared().rejectInvitation(ofUser: inviter) { _ in }
    }
    
    @objc private func sure() {
        timer.invalidate()
        dismissAlert()
        RCLiveVideoEngine.shared().acceptInvitation(ofUser: inviter, at: index, completion: { code in
            if (code != .success) {
                SVProgressHUD.showError(withStatus: "没有空余麦位")
            }
        })
    }
    
    @objc private func overTime() {
        timer.invalidate()
        dismissAlert()
        RCLiveVideoEngine.shared().rejectInvitation(ofUser: inviter) { _ in }
    }
    
    func invitationDidCancel() {
        timer.invalidate()
        dismissAlert()
    }
    
    private func dismissAlert() {
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension RCLVRInvitationAlertViewController {
    private func setupConstraints() {
        view.addSubview(alertView)
        alertView.addSubview(titleLabel)
        alertView.addSubview(sureButton)
        alertView.addSubview(cancelButton)
        alertView.addSubview(hLine)
        alertView.addSubview(vLine)
        
        alertView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalToSuperview().multipliedBy(295.0 / 375)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(40)
            make.bottom.equalTo(hLine.snp.top).offset(-40)
        }
        
        hLine.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(44)
            make.height.equalTo(0.5)
        }
        
        vLine.snp.makeConstraints { make in
            make.top.equalTo(hLine)
            make.centerX.bottom.equalToSuperview()
            make.width.equalTo(0.5)
        }
        
        sureButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.left.equalTo(vLine)
            make.top.equalTo(hLine)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.left.equalToSuperview()
            make.top.equalTo(hLine)
            make.right.equalTo(vLine)
        }
    }
}
