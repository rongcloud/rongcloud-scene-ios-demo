//
//  PromotionViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/7/13.
//

import UIKit

final class PromotionViewController: UIViewController {
    
    private lazy var alertView: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white
        instance.layer.cornerRadius = 12
        instance.layer.masksToBounds = true
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = UIColor(byteRed: 2, green: 0, blue: 55)
        instance.font = UIFont.systemFont(ofSize: 16)
        instance.text = "融云最近活动，了解一下？"
        return instance
    }()
    private lazy var contentView = UIImageView(image: R.image.promotion())
    private(set) lazy var sureButton: UIButton = {
        let instance = UIButton()
        instance.setTitle("我想了解", for: .normal)
        instance.setTitleColor(UIColor(byteRed: 121, green: 131, blue: 254), for: .normal)
        instance.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        instance.addTarget(self, action: #selector(sure), for: .touchUpInside)
        return instance
    }()
    private(set) lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.setTitle("我再想想", for: .normal)
        instance.setTitleColor(UIColor(byteRed: 2, green: 0, blue: 55), for: .normal)
        instance.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        instance.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return instance
    }()
    private lazy var hLineView = UIView()
    private lazy var vLineView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(byteRed: 3, green: 6, blue: 47, alpha: 0.4)
        
        setupConstraints()
    }

    private func setupConstraints() {
        view.addSubview(alertView)
        alertView.addSubview(titleLabel)
        alertView.addSubview(contentView)
        alertView.addSubview(sureButton)
        alertView.addSubview(cancelButton)
        alertView.addSubview(hLineView)
        alertView.addSubview(vLineView)
        
        alertView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(295)
            make.height.equalTo(252)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(alertView.snp.top).offset(35)
            make.width.lessThanOrEqualToSuperview()
        }
        
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.top.equalToSuperview().offset(64)
            make.height.equalTo(120)
        }
        
        sureButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(44)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(sureButton)
            make.left.equalTo(sureButton.snp.right)
        }
        
        hLineView.backgroundColor = UIColor(byteRed: 229, green: 230, blue: 230)
        hLineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(sureButton)
            make.height.equalTo(1)
        }
        
        vLineView.backgroundColor = UIColor(byteRed: 229, green: 230, blue: 230)
        vLineView.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.top.equalTo(hLineView.snp.bottom)
            make.width.equalTo(1)
        }
    }
    
    @objc private func sure() {
        let controller = presentingViewController
        dismiss(animated: true) {
            guard let controller = controller?.currentVisableViewController() else { return }
            WebViewController.show(controller,
                                   title: "促销活动",
                                   path: "https://m.rongcloud.cn/activity/rtc20")
        }
        UMengEvent.AppraisalBanner.trigger()
    }
    
    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
