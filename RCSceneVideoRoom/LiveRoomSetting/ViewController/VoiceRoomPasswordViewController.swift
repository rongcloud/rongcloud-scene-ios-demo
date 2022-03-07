//
//  VoiceRoomPasswordViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/14.
//

import SVProgressHUD
import RCSceneService
import RCSceneFoundation
import RCSceneRoomSetting

class VoiceRoomPasswordViewController: UIViewController {
    weak var delegate: InputPasswordProtocol?
    fileprivate let type: PasswordViewType
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
        instance.textColor = UIColor(hexString: "#020037")
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
        instance.addTarget(self, action: #selector(handleTextChanaged), for: .editingChanged)
        return instance
    }()
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitle("取消", for: .normal)
        instance.setTitleColor(UIColor(hexString: "#020037"), for: .normal)
        instance.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return instance
    }()
    fileprivate lazy var uploadButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitle("提交", for: .normal)
        instance.setTitleColor(R.color.hexEF499A(), for: .normal)
        instance.addTarget(self, action: #selector(handleInputPassword), for: .touchUpInside)
        return instance
    }()
    private lazy var passwordViewList: [PasswordNumberView] = {
        var list = [PasswordNumberView]()
        for i in 0...3 {
            list.append(PasswordNumberView())
        }
        return list
    }()
    private lazy var sepratorline1: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E5E6E7")
        return instance
    }()
    private lazy var sepratorline2: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E5E6E7")
        return instance
    }()
    private lazy var stackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: passwordViewList)
        instance.spacing = 21.resize
        instance.distribution = .equalSpacing
        return instance
    }()
    
    init(type: PasswordViewType, delegate: InputPasswordProtocol?) {
        self.delegate = delegate
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    @objc private func handleTextChanaged() {
        guard let text = textField.text else {
            return
        }
        for (index, item) in text.enumerated() {
            let view = passwordViewList[index]
            view.update(text: String(item))
        }
        for i in text.count..<4 {
            let view = passwordViewList[i]
            view.update(text: nil)
        }
    }
    
    private func buildLayout() {
        view.backgroundColor = UIColor(hexInt: 0x03062F).withAlphaComponent(0.4)
        view.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(textField)
        container.addSubview(cancelButton)
        container.addSubview(uploadButton)
        container.addSubview(sepratorline1)
        container.addSubview(sepratorline2)
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
        
        sepratorline1.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(29.resize)
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
        }
        
        sepratorline2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(sepratorline1.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.top.equalTo(sepratorline1.snp.bottom)
            make.right.equalTo(sepratorline2.snp.left)
            make.height.equalTo(44)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.top.equalTo(sepratorline1.snp.bottom)
            make.left.equalTo(sepratorline2.snp.right)
        }
    }
    
    @objc private func handleInputPassword() {
        guard let text = textField.text, text.count == 4 else {
            return SVProgressHUD.showError(withStatus: "请输入4位密码")
        }
        switch type {
        case .input:
            dismiss(animated: true) { [weak self] in
                self?.delegate?.passwordDidEnter(password: text)
            }
        case let .verify(room):
            guard room.password == text else {
                textField.text = ""
                for view in passwordViewList {
                    view.update(text: nil)
                }
                return SVProgressHUD.showError(withStatus: "密码验证错误，请重试")
            }
            dismiss(animated: true) { [weak self] in
                self?.delegate?.passwordDidVerify(room)
            }
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension VoiceRoomPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
