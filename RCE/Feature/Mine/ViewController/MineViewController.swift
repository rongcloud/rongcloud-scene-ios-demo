//
//  MineViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/7/13.
//

import UIKit
import RCSceneService
import RCSceneFoundation

final class MineViewController: UIViewController {
    
    private(set) lazy var settingButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.setting_icon(), for: .normal)
        instance.addTarget(self, action: #selector(handleSettingClick), for: .touchUpInside)
        return instance
    }()
    
    private lazy var scrollView: UIScrollView = {
        let instance = UIScrollView()
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var avatarButton: UIButton = {
        let instance = UIButton()
        instance.imageView?.contentMode = .scaleAspectFill
        instance.setBackgroundImage(R.image.default_avatar(), for: .normal)
        instance.addTarget(self, action: #selector(editButtonClicked), for: .touchUpInside)
        return instance
    }()
    private lazy var headerEditImageView = UIImageView(image: R.image.user_edit_image())
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = UIColor(byteRed: 2, green: 0, blue: 55)
        instance.font = .systemFont(ofSize: 16.resize)
        return instance
    }()
    private lazy var promotionButton: UIButton = {
        let instance = UIButton()
        instance.setBackgroundImage(R.image.promotion(), for: .normal)
        instance.addTarget(self, action: #selector(promotion), for: .touchUpInside)
        instance.layer.cornerRadius = 8.resize
        instance.layer.masksToBounds = true
        return instance
    }()
    private lazy var itemsView = PromotionItemsView({ [weak self] item in
        guard let self = self else { return }
        WebViewController.show(self, title: item.title, path: item.path)
    })
    private lazy var serviceButton: UIButton = {
        let instance = UIButton()
        instance.setTitleColor(.white, for: .normal)
        instance.setTitleColor(.lightGray, for: .highlighted)
        instance.setTitle("专属客户经理", for: .normal)
        instance.titleLabel?.font = .systemFont(ofSize: 16.resize)
        instance.setImage(R.image.service(), for: .normal)
        instance.setBackgroundImage(serviceButtonBackground(), for: .normal)
        instance.addTarget(self, action: #selector(service), for: .touchUpInside)
        return instance
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hexString: "0xE6F0F3")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingButton)
        
        setupConstraint()
        configUI()
        
        NotificationNameUserInfoUpdated.addObserver(self, selector: #selector(userInfoUpdated(_:)))
        NotificationNameLogin.addObserver(self, selector: #selector(configUI))
    }
    
    @objc private func userInfoUpdated(_ notification: Notification) {
        guard let user = notification.object as? User else { return }
        avatarButton.kf.setImage(with: URL(string: user.portraitUrl),
                                 for: .normal,
                                 placeholder: R.image.default_avatar())
        nameLabel.text = user.userName
    }
    
    @objc private func editButtonClicked() {
        navigator(.userInfoEdit)
    }

    @objc private func promotion() {
        UMengEvent.SettingBanner.trigger()
        WebViewController.show(self, title: "促销活动", path: "https://m.rongcloud.cn/activity/rtc20")
    }
    
    @objc private func service() {
        UMengEvent.SettingCallCM.trigger()
        UIApplication.shared.open(URL(string: "tel://13161856839")!, options: [:]) { _ in }
    }
    
    private func serviceButtonBackground() -> UIImage {
        let size = CGSize(width: 335.resize, height: 50.resize)
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.colors = [
            UIColor(byteRed: 121, green: 131, blue: 254).cgColor,
            UIColor(byteRed: 167, green: 158, blue: 250).cgColor
        ]
        gradientLayer.bounds = CGRect(origin: .zero, size: size)
        return UIGraphicsImageRenderer(size: size)
            .image { renderer in
                gradientLayer.render(in: renderer.cgContext)
            }
    }
}

extension MineViewController {
    private func setupConstraint() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(avatarButton)
        scrollView.addSubview(headerEditImageView)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(promotionButton)
        scrollView.addSubview(itemsView)
        scrollView.addSubview(serviceButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        avatarButton.layer.cornerRadius = 35.resize
        avatarButton.layer.masksToBounds = true
        avatarButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(70.resize)
        }
        
        headerEditImageView.snp.makeConstraints { make in
            make.right.bottom.equalTo(avatarButton)
            make.width.height.equalTo(20.resize)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(avatarButton.snp.bottom).offset(25.resize)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
        }
        
        promotionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(9.resize)
            make.width.equalTo(337.resize)
            make.height.equalTo(131.resize)
        }
        
        itemsView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(promotionButton.snp.bottom).offset(20.resize)
            make.width.equalTo(335.resize)
            make.height.equalTo(220.resize)
        }
        
        serviceButton.layer.cornerRadius = 25.resize
        serviceButton.layer.masksToBounds = true
        serviceButton.snp.makeConstraints { make in
            make.top.equalTo(itemsView.snp.bottom).offset(31.resize)
            make.bottom.equalToSuperview().offset(-30.resize)
            make.centerX.equalToSuperview()
            make.width.equalTo(335.resize)
            make.height.equalTo(50.resize)
        }
    }
    
    @objc func handleSettingClick() {
        let controller = SettingViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func configUI() {
        guard let user = Environment.currentUser else { return }
        let avatarURL = URL(string: user.portraitUrl)
        avatarButton.kf.setImage(with: avatarURL,
                                 for: .normal,
                                 placeholder: R.image.default_avatar())
        nameLabel.text = user.userName
    }
}
