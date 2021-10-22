//
//  RCLVRCancelMicViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/14.
//

import UIKit

enum RCLVRCancelMicType: String {
    case request = "撤回连线申请"
    case invite = "撤回连线邀请"
    case connection = "挂断连接"
    
    var title: String {
        switch self {
        case .request: return "已申请视频连线"
        case .invite: return "已邀请视频连线"
        case .connection: return "正在进行视频连线"
        }
    }
}

protocol RCLiveVideoCancelDelegate: AnyObject {
    func didCancelLiveVideo(_ action: RCLVRCancelMicType)
}

class RCLVRCancelMicViewController: UIViewController {
    weak var delegate: RCLiveVideoCancelDelegate?
    
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        return instance
    }()
    
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16, weight: .medium)
        instance.textColor = .white
        instance.text = type.title
        return instance
    }()
    
    private lazy var cancelRequestButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = R.color.hexCDCDCD()?.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle(type.rawValue, for: .normal)
        instance.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        instance.layer.cornerRadius = 8
        instance.clipsToBounds = true
        instance.addTarget(self, action: #selector(handleCancelRequest), for: .touchUpInside)
        return instance
    }()
    
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = R.color.hexCDCDCD()?.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle("取消", for: .normal)
        instance.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        instance.layer.cornerRadius = 8
        instance.clipsToBounds = true
        instance.addTarget(self, action: #selector(handleCancleClick), for: .touchUpInside)
        return instance
    }()
    
    private let type: RCLVRCancelMicType
    init(_ type: RCLVRCancelMicType, delegate: RCLiveVideoCancelDelegate) {
        self.type = type
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
//        modalTransitionStyle = .crossDissolve
//        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        
        container.backgroundColor = UIColor(byteRed: 3, green: 6, blue: 47, alpha: 0.8)
        view.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(cancelRequestButton)
        container.addSubview(cancelButton)
        
        container.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26.resize)
            make.centerX.equalToSuperview()
        }
        
        cancelRequestButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(28.resize)
            make.top.equalTo(titleLabel.snp.bottom).offset(28.resize)
            make.height.equalTo(44)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(cancelRequestButton.snp.bottom).offset(15.resize)
            make.size.equalTo(cancelRequestButton)
            make.left.equalTo(cancelRequestButton)
            make.bottom.equalToSuperview().inset(40.resize)
        }
    }
    
    @objc func handleCancelRequest() {
        dismiss(animated: true) { [unowned self] in
            delegate?.didCancelLiveVideo(type)
        }
    }
    
    @objc func handleCancleClick() {
        dismiss(animated: true)
    }
}
