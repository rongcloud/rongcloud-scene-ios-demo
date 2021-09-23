//
//  VoiceRoomTextInputViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/13.
//

import UIKit
import SVProgressHUD

protocol VoiceRoomInputTextProtocol: AnyObject {
    func textDidInput(text: String)
}

class VoiceRoomTextInputViewController: UIViewController {
    weak var delegate: VoiceRoomInputTextProtocol?
    private let roomName: String
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        instance.layer.cornerRadius = 12.resize
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 15.resize, weight: .medium)
        instance.textColor = .white
        instance.text = "修改房间标题"
        return instance
    }()
    private lazy var textField: UITextField = {
        let instance = UITextField()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        instance.textColor = .white
        instance.leftView = {
            let leftView = UIView()
            leftView.backgroundColor = .clear
            leftView.frame = CGRect(x: 0, y: 0, width: 12.resize, height: 12.resize)
            return leftView
        }()
        instance.leftViewMode = .always
        instance.rightView = {
            let rightView = UIView()
            rightView.backgroundColor = .clear
            rightView.frame = CGRect(x: 0, y: 0, width: 12.resize, height: 12.resize)
            return rightView
        }()
        instance.rightViewMode = .always
        instance.font = .systemFont(ofSize: 13.resize)
        instance.addTarget(self, action: #selector(handleTextFieldEditing(textField:)), for: .editingChanged)
        instance.layer.cornerRadius = 3.resize
        instance.clipsToBounds = true
        instance.returnKeyType = .done
        instance.attributedPlaceholder = NSAttributedString(string: "输入...", attributes: [.foregroundColor : UIColor.lightGray])
        return instance
    }()
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 17.resize)
        instance.setTitle("取消", for: .normal)
        instance.setTitleColor(.white, for: .normal)
        instance.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return instance
    }()
    private lazy var uploadButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 17.resize)
        instance.setTitle("提交", for: .normal)
        instance.setTitleColor(R.color.hexEF499A(), for: .normal)
        instance.addTarget(self, action: #selector(handleUpload), for: .touchUpInside)
        return instance
    }()
    private lazy var sepratorline1: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        return instance
    }()
    private lazy var sepratorline2: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        return instance
    }()
    
    private lazy var tapGestureView = RCTapGestureView(self)
    
    init(name: String, delegate: VoiceRoomInputTextProtocol) {
        roomName = name
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        textField.text = name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    private func buildLayout() {
        view.backgroundColor = UIColor(hexInt: 0x14102c)
        view.addSubview(tapGestureView)
        view.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(textField)
        container.addSubview(cancelButton)
        container.addSubview(uploadButton)
        container.addSubview(sepratorline1)
        container.addSubview(sepratorline2)
        
        tapGestureView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
            $0.height.equalTo(36.resize)
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
            make.height.equalTo(44.resize)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.top.equalTo(sepratorline1.snp.bottom)
            make.left.equalTo(sepratorline2.snp.right)
        }
    }
    
    @objc private func handleUpload() {
        guard let text = textField.text, text.count > 0 else {
            SVProgressHUD.showError(withStatus: "请输入新的房间标题")
            return
        }
        delegate?.textDidInput(text: text)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleTextFieldEditing(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        guard textField.markedTextRange == nil else {
            return
        }
        if text.count > 10 {
            let startIndex = text.startIndex
            let endIndex = text.index(startIndex, offsetBy: 10)
            textField.text = String(text[startIndex..<endIndex])
        }
    }
}
