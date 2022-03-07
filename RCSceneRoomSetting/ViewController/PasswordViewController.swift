//
//  PasswordViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/14.
//

import UIKit

public class PasswordViewController: UIViewController {
    weak var delegate: RCSceneRoomSettingProtocol?
    
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white
        instance.layer.cornerRadius = 12
        instance.clipsToBounds = true
        return instance
    }()
    
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 15, weight: .medium)
        instance.textColor = R.color.hex020037()
        instance.text = "设置4位数字密码"
        return instance
    }()
    
    fileprivate lazy var textField: UITextField = {
        let instance = UITextField()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        instance.textColor = .white
        instance.font = .systemFont(ofSize: 13)
        instance.delegate = self
        instance.layer.cornerRadius = 2
        instance.clipsToBounds = true
        instance.isHidden = true
        instance.returnKeyType = .done
        instance.keyboardType = .numberPad
        instance.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
        return instance
    }()
    
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitle("取消", for: .normal)
        instance.setTitleColor(R.color.hex020037(), for: .normal)
        instance.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return instance
    }()
    
    private lazy var uploadButton: UIButton = {
        let instance = UIButton()
        instance.isEnabled = false
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitle("提交", for: .normal)
        instance.setTitleColor(R.color.hexEF499A(), for: .normal)
        instance.addTarget(self, action: #selector(handleInputPassword), for: .touchUpInside)
        return instance
    }()
    
    private lazy var passwordViews: [PasswordNumberView] = {
        var list = [PasswordNumberView]()
        for i in 0...3 {
            list.append(PasswordNumberView())
        }
        return list
    }()
    
    private lazy var separatorLine1: UIView = {
        let instance = UIView()
        instance.backgroundColor = R.color.hexE5E6E7()
        return instance
    }()
    
    private lazy var separatorLine2: UIView = {
        let instance = UIView()
        instance.backgroundColor = R.color.hexE5E6E7()
        return instance
    }()
    
    private lazy var stackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: passwordViews)
        instance.spacing = 21.resize
        instance.distribution = .equalSpacing
        return instance
    }()
    
    public init(_ delegate: RCSceneRoomSettingProtocol?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    @objc private func handleTextChanged() {
        guard let text = textField.text else {
            return
        }
        for (index, item) in text.enumerated() {
            let view = passwordViews[index]
            view.update(text: String(item))
        }
        for i in text.count..<4 {
            let view = passwordViews[i]
            view.update(text: nil)
        }
        uploadButton.isEnabled = text.count == 4
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        
        view.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(textField)
        container.addSubview(cancelButton)
        container.addSubview(uploadButton)
        container.addSubview(separatorLine1)
        container.addSubview(separatorLine2)
        container.addSubview(stackView)
        
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200.resize)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(40.resize)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25.resize)
            $0.centerX.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20.resize)
            $0.left.right.equalToSuperview().inset(27.resize)
            $0.height.equalTo(36)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(textField)
        }
        
        separatorLine1.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(29.resize)
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
        }
        
        separatorLine2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(separatorLine1.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.top.equalTo(separatorLine1.snp.bottom)
            make.right.equalTo(separatorLine2.snp.left)
            make.height.equalTo(44)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.top.equalTo(separatorLine1.snp.bottom)
            make.left.equalTo(separatorLine2.snp.right)
        }
    }
    
    @objc private func handleInputPassword() {
        guard let text = textField.text else {
            fatalError("text is nil")
        }
        dismiss(animated: true) { [weak self] in
            guard let delegate = self?.delegate else { return }
            delegate.eventDidTrigger(.roomLock(true), extra: text)
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension PasswordViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
        }
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 4
    }
}
