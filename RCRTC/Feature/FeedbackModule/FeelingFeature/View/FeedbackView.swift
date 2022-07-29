//
//  FeedbackView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/7/20.
//

import UIKit

protocol FeedbackViewProtocol: AnyObject {
    func cancelDidClick()
    func likeDidClick()
    func notLikeDidClick()
}

class FeedbackView: UIView {
    weak var delegate: FeedbackViewProtocol?
    private lazy var containerView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .white
        instance.layer.cornerRadius = 12
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var smileButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 8
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = UIColor(hexString: "#E5E6E7").cgColor
        instance.addTarget(self, action: #selector(handleLikeAction), for: .touchUpInside)
        return instance
    }()
    private lazy var smileImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.feedback_smile_icon()
        return instance
    }()
    private lazy var smileLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12)
        instance.textColor = UIColor(hexString: "#020037")
        instance.text = "点个赞"
        return instance
    }()
    private lazy var awakedButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 8
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = UIColor(hexString: "#E5E6E7").cgColor
        instance.addTarget(self, action: #selector(handleNotLikeAction), for: .touchUpInside)
        return instance
    }()
    private lazy var awakedImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.feedback_awaked_icon()
        return instance
    }()
    private lazy var awakedLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12)
        instance.textColor = UIColor(hexString: "#020037")
        instance.text = "吐个槽"
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16)
        instance.textColor = UIColor(hexString: "#020037")
        instance.text = "请留下您的使用感受把"
        return instance
    }()
    private lazy var separatorline: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E5E6E7")
        return instance
    }()
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.setTitle("稍后再说", for: .normal)
        instance.setTitleColor(UIColor(hexString: "#7983FE"), for: .normal)
        instance.addTarget(self, action: #selector(handleCancelAction), for: .touchUpInside)
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        addSubview(containerView)
        containerView.addSubview(smileButton)
        containerView.addSubview(awakedButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(separatorline)
        containerView.addSubview(cancelButton)
        
        smileButton.addSubview(smileImageView)
        smileButton.addSubview(smileLabel)
        
        awakedButton.addSubview(awakedImageView)
        awakedButton.addSubview(awakedLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        smileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 56, height: 56))
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(25)
        }
        
        smileLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(smileImageView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        
        awakedImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 56, height: 56))
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(25)
        }
        
        awakedLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(awakedImageView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        smileButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.right.equalTo(containerView.snp.centerX).offset(-12)
        }
        
        awakedButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(containerView.snp.centerX).offset(12)
        }
        
        separatorline.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(awakedButton.snp.bottom).offset(25)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(separatorline.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    @objc private func handleLikeAction() {
        delegate?.likeDidClick()
    }
    
    @objc private func handleNotLikeAction() {
        delegate?.notLikeDidClick()
    }
    
    @objc private func handleCancelAction() {
        delegate?.cancelDidClick()
    }
}
