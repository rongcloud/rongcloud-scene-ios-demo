//
//  RCLVRAlertWaitingViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/19.
//

import UIKit
import SVProgressHUD

class RCLVRAlertWaitingViewController: RCLVRAlertViewController {

    private(set) lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.text = "已申请连线"
        instance.textColor = .white
        instance.font = .systemFont(ofSize: 16.resize, weight: .medium)
        return instance
    }()
    
    private lazy var cancelRequestButton: UIButton = {
        let instance = RCActionButton(RCLVRSeatSheetAction(title: "撤回连麦申请", type: .gradient))
        instance.addTarget(self, action: #selector(cancelRequest), for: .touchUpInside)
        return instance
    }()
    
    private lazy var cancelButton: UIButton = {
        let instance = RCActionButton(RCLVRSeatSheetAction(title: "取消", type: .normal))
        instance.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return instance
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(contentView.snp.top).offset(35.resize)
        }
        
        contentView.addSubview(cancelRequestButton)
        cancelRequestButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(70.resize)
            make.width.equalTo(319.resize)
            make.height.equalTo(44.resize)
        }
        
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(128.resize)
            make.width.equalTo(319.resize)
            make.height.equalTo(44.resize)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-28.5)
        }
    }
    
    override func contentHeight() -> CGFloat {
        return 200.resize
    }
    
    override func maskLayer() -> CAShapeLayer {
        let r: CGFloat = 15.resize
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: contentView.bounds,
                                       byRoundingCorners: [.topLeft, .topRight],
                                       cornerRadii: CGSize(width: r, height: r)).cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.frame = contentView.bounds
        return shapeLayer
    }
}

extension RCLVRAlertWaitingViewController {
    @objc private func cancelRequest() {
        dismiss(animated: true)
        RCLiveVideoEngine.shared().cancelRequest { code in
            if code == .success {
                self.delegate?.didClickAction(.cancelRequest)
                SVProgressHUD.showSuccess(withStatus: "已撤回连麦申请")
            } else {
                SVProgressHUD.showError(withStatus: "取消失败")
            }
        }
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
}
