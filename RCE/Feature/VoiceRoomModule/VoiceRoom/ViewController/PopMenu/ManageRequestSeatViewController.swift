//
//  RequestSeatPopViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/14.
//

import UIKit

protocol RequestSeatPopProtocol: AnyObject {
    func cancelRequestSeatDidClick()
}

class ManageRequestSeatViewController: UIViewController {
    weak var delegate: RequestSeatPopProtocol?
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        return instance
    }()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16, weight: .medium)
        instance.textColor = .white
        instance.text = "已申请连线"
        return instance
    }()
    private lazy var cancelRequestButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = R.color.hexCDCDCD()?.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle("撤回连线申请", for: .normal)
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
    
    init(delegate: RequestSeatPopProtocol) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
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
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(titleLabel)
        container.addSubview(cancelRequestButton)
        container.addSubview(cancelButton)
        
        container.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        delegate?.cancelRequestSeatDidClick()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCancleClick() {
        dismiss(animated: true, completion: nil)
    }
}
