//
//  LoginViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/21.
//

import UIKit
import ReactorKit
import SVProgressHUD

final class LoginViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    private lazy var logoImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.login_logo()
        return instance
    }()
    private lazy var container1: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = UIColor(hexString: "#D4D7D9").cgColor
        instance.layer.cornerRadius = 4
        return instance
    }()
    private lazy var phoneTextField: UITextField = {
        let instance = UITextField(frame: .zero)
        instance.keyboardType = .numberPad
        instance.backgroundColor = .white
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = UIColor(hexString: "#333333")
        instance.attributedPlaceholder = attributedText(color: UIColor(hexString: "#9B9B9B"), text: "请输入手机号")
        instance.leftViewMode = .always
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
        instance.leftView = leftView
        return instance
    }()
    private lazy var verifyCodeTextField: UITextField = {
        let instance = UITextField(frame: .zero)
        instance.keyboardType = .numberPad
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = UIColor(hexString: "#333333")
        instance.attributedPlaceholder = attributedText(color: UIColor(hexString: "#9B9B9B"), text: "请输入验证码")
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = UIColor(hexString: "#D4D7D9").cgColor
        instance.layer.cornerRadius = 4
        instance.leftViewMode = .always
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
        instance.leftView = leftView
        return instance
    }()
    private lazy var loginButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = UIColor(hexString: "#0099FF")
        instance.titleLabel?.font =  .systemFont(ofSize: 17)
        instance.setTitleColor(.white, for: .normal)
        instance.setTitle(R.string.localizable.login(), for: .normal)
        instance.layer.cornerRadius = 4
        return instance
    }()
    private lazy var countdownLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textAlignment = .center
        instance.textColor = UIColor(hexString: "#0099FF")
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = UIColor(hexString: "#D4D7D9").cgColor
        instance.layer.cornerRadius = 4
        return instance
    }()
    private lazy var requestCodebutton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .white
        instance.titleLabel?.font =  .systemFont(ofSize: 14)
        instance.setTitleColor(UIColor(hexString: "#0099FF"), for: .normal)
        instance.setTitle("获取验证码", for: .normal)
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = UIColor(hexString: "#0099FF").cgColor
        instance.layer.cornerRadius = 4
        return instance
    }()
    private lazy var privacyLabel: UILabel = {
        let instance = UILabel()
        instance.textAlignment = .center
        instance.font = .systemFont(ofSize: 11)
        instance.numberOfLines = 0
        instance.attributedText = privacyAttributedText()
        return instance
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.reactor = LoginReactor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    private func attributedText(color: UIColor, text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [.foregroundColor : color, .font: UIFont.systemFont(ofSize: 14)])
    }
    
    private func privacyAttributedText() -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .center
        let version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.1.0"
        let text1 = "新登录用户即注册开通融云开发者账号\n且表示同意"
        let text2 = "《注册条款》"
        let text3 = "\n融云 RTC \(version)"
        let attributedText1 = NSAttributedString(string: text1, attributes: [.foregroundColor: UIColor(hexString: "#5C6970"), .paragraphStyle : paragraphStyle])
        let attributedText2 = NSAttributedString(string: text2, attributes: [.foregroundColor: UIColor(hexString: "#0099FF"), .paragraphStyle : paragraphStyle])
        let attributedText3 = NSAttributedString(string: text3, attributes: [.foregroundColor: UIColor(hexString: "#5C6970"), .paragraphStyle : paragraphStyle])
        let value = NSMutableAttributedString()
        value.append(attributedText1)
        value.append(attributedText2)
        value.append(attributedText3)
        return value
    }
    
    private func buildLayout() {
        view.backgroundColor = .white
        view.addSubview(logoImageView)
        view.addSubview(container1)
        container1.addSubview(phoneTextField)
        view.addSubview(verifyCodeTextField)
        view.addSubview(requestCodebutton)
        view.addSubview(countdownLabel)
        view.addSubview(loginButton)
        view.addSubview(privacyLabel)
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(121.resize)
        }
        
        container1.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(38.resize)
            make.height.equalTo(40.resize)
            make.top.equalTo(logoImageView.snp.bottom).offset(84.resize)
        }
        
        phoneTextField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        verifyCodeTextField.snp.makeConstraints {
            $0.left.equalToSuperview().offset(38.resize)
            $0.height.equalTo(40.resize)
            $0.top.equalTo(container1.snp.bottom).offset(20)
            $0.width.equalTo(180.resize)
        }
        
        countdownLabel.snp.makeConstraints {
            $0.left.equalTo(verifyCodeTextField.snp.right).offset(10.resize)
            $0.right.equalToSuperview().inset(38.resize)
            $0.centerY.equalTo(verifyCodeTextField)
            $0.height.equalTo(40.resize)
        }
        
        requestCodebutton.snp.makeConstraints {
            $0.edges.equalTo(countdownLabel)
        }
        
        loginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(requestCodebutton.snp.bottom).offset(48.resize)
            $0.height.equalTo(44.resize)
            $0.left.right.equalTo(container1)
        }
        
        privacyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(17.resize)
        }
    }
    
    func bind(reactor: LoginReactor) {
        reactor.state
            .map { $0.phoneNumber.count == 11 && $0.verifyCode.count == 6 }
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.phoneNumber.count == 11 && $0.verifyCode.count == 6 }
            .map { $0 ? 1 : 0.3 }
            .bind(to: loginButton.rx.alpha)
            .disposed(by: disposeBag)
        
        phoneTextField.rx
            .text
            .orEmpty
            .map { Reactor.Action.inputPhoneNumber($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        verifyCodeTextField.rx
            .text
            .orEmpty
            .map { Reactor.Action.inputVerifyCode($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.error)
            .distinctUntilChanged()
            .compactMap { $0?.message }
            .bind(to: SVProgressHUD.rx.errorStatus)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.success)
            .distinctUntilChanged()
            .compactMap { $0?.message }
            .bind(to: SVProgressHUD.rx.successStatus)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { "已发送(\($0.countdown)s)" }
            .distinctUntilChanged()
            .bind(to: countdownLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { !$0.countdownRunning }
            .bind(to: countdownLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.countdownRunning)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.verifyCodeTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.countdownRunning)
            .bind(to: requestCodebutton.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.phoneNumber.count == 11 }
            .map { $0 ? 1 : 0.3 }
            .bind(to: requestCodebutton.rx.alpha)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.phoneNumber.count == 11 }
            .bind(to: requestCodebutton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.requestTitle)
            .bind(to: requestCodebutton.rx.title())
            .disposed(by: disposeBag)
        
        requestCodebutton.rx
            .tap
            .map { Reactor.Action.clickSendVerifyCode }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        loginButton.rx
            .tap
            .map { Reactor.Action.login }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.loginNetworkState)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .idle: ()
                case .begin: SVProgressHUD.show()
                case .success:
                    SVProgressHUD.dismiss()
                    self?.dismiss(animated: true, completion: nil)
                    NotificationNameLogin.post()
                    UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
                        RCIM.shared().currentUserInfo = user.rcUser
                    }
                case let .failure(error):
                    SVProgressHUD.showError(withStatus: error.message)
                }
            })
            .disposed(by: disposeBag)
        
        privacyLabel.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] tap in
                guard let self = self else { return }
                guard let view = tap.view else { return }
                let area = CGRect(x: view.bounds.width * 0.5,
                                  y: view.bounds.height / 3,
                                  width: view.bounds.width * 0.5 * 0.8,
                                  height: view.bounds.height / 3)
                let point = tap.location(in: view)
                guard area.contains(point) else { return }
                let path = Bundle.main.path(forResource: "privacy_cn", ofType: "html")!
                WebViewController.show(self, title: "注册条款", path: path)
            })
            .disposed(by: disposeBag)
        
        view.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}
