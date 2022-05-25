//
//  LoginViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/21.
//

import UIKit
import ReactorKit
import SVProgressHUD


import RCSceneVoiceRoom

final class LoginViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    private lazy var logoImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.rc_logo()
        return instance
    }()
    
    private lazy var countryCodeLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textAlignment = .right
        instance.textColor = UIColor(hexString: "#9B9B9B")
        instance.text = "+86"
        instance.sizeToFit()
        return instance
    }()
    
    private lazy var countrySelectBtn: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .white
        instance.setImage(R.image.country_select_indicator(), for: .normal)
        instance.addTarget(self, action: #selector(selectCountry), for: .touchUpInside)
        return instance
    }()
    
    private lazy var inputComponent: UIStackView = {
        let instance = UIStackView()
        instance.distribution = .fillProportionally
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
        
        let privacyTap = UITapGestureRecognizer(target: self, action: #selector(handlePrivateLabelTap(_:)))
        privacyLabel.isUserInteractionEnabled = true
        privacyLabel.addGestureRecognizer(privacyTap)
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        view.addGestureRecognizer(viewTap)
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
        let text3 = "和"
        let text4 = "《隐私政策》"
        let text5 = "\n融云 RTC \(version)"
        let attributedText1 = NSAttributedString(string: text1, attributes: [.foregroundColor: UIColor(hexString: "#5C6970"), .paragraphStyle : paragraphStyle])
        let attributedText2 = NSAttributedString(string: text2, attributes: [.foregroundColor: UIColor(hexString: "#0099FF"), .paragraphStyle : paragraphStyle])
        let attributedText3 = NSAttributedString(string: text3, attributes: [.foregroundColor: UIColor(hexString: "#5C6970"), .paragraphStyle : paragraphStyle])
        let attributedText4 = NSAttributedString(string: text4, attributes: [.foregroundColor: UIColor(hexString: "#0099FF"), .paragraphStyle : paragraphStyle])
        let attributedText5 = NSAttributedString(string: text5, attributes: [.foregroundColor: UIColor(hexString: "#5C6970"), .paragraphStyle : paragraphStyle])
        let value = NSMutableAttributedString()
        value.append(attributedText1)
        value.append(attributedText2)
        value.append(attributedText3)
        value.append(attributedText4)
        value.append(attributedText5)
        return value
    }
    
    @objc private func selectCountry() {
        let countryVc = CountryPhoneCodeListController()
        countryVc.didSelectCountry = { [weak self] countryInfo in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
        countryVc.rx.itemSelected
            .map { Reactor.Action.selectPhoneCode($0?.code ?? "") }
            .bind(to: reactor!.action)
            .disposed(by: disposeBag)
        countryVc.show(self)
    }
    
    private func buildLayout() {
        view.backgroundColor = .white
        view.addSubview(logoImageView)
        
        inputComponent.addArrangedSubview(countryCodeLabel)
#if OVERSEA
        inputComponent.addArrangedSubview(countrySelectBtn)
#endif
        inputComponent.addArrangedSubview(phoneTextField)
        container1.addSubview(inputComponent);
        
        view.addSubview(container1)
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
        
        inputComponent.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        countryCodeLabel.snp.makeConstraints {
            $0.width.equalTo(45.resize)
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
            .map { [weak self] (state) in
                guard let `self` = self else { return false }
                return self.verification(phone: state.phoneNumber) && state.verifyCode.count == 6
            }
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { [weak self] (state) in
                guard let `self` = self else { return 0.3 }
                if self.verification(phone: state.phoneNumber) && state.verifyCode.count == 6 {
                    return 1
                } else {
                    return 0.3
                }
            }
            .bind(to: loginButton.rx.alpha)
            .disposed(by: disposeBag)
        
        phoneTextField.rx
            .text
            .orEmpty
            .map { Reactor.Action.inputPhoneNumber($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { $0.phoneCode }
            .bind(to: countryCodeLabel.rx.text)
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
            .map { [weak self] (state) in
                guard let `self` = self else { return 0.3 }
                if self.verification(phone: state.phoneNumber) {
                    return 1
                } else {
                    return 0.3
                }
            }
            .bind(to: requestCodebutton.rx.alpha)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { [weak self] (state) in
                guard let `self` = self else { return false }
                return self.verification(phone: state.phoneNumber)
            }
            .bind(to: requestCodebutton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.requestTitle)
            .bind(to: requestCodebutton.rx.title())
            .disposed(by: disposeBag)
        
        requestCodebutton.rx
            .throttledTap
            .map { Reactor.Action.clickSendVerifyCode }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        loginButton.rx
            .tap
            .map { Reactor.Action.login }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.sendCodeNetworkState)
            .distinctUntilChanged()
            .do(onNext: { state in
                switch state {
                case .success:
                    RCSensorAction.code(.success(())).trigger()
                case let .failure(error):
                    RCSensorAction.code(.failure(NetError(error.message))).trigger()
                default: ()
                }
            })
            .subscribe(onNext: { state in
                switch state {
                case .idle: ()
                case .begin: SVProgressHUD.show()
                case .success:
                    SVProgressHUD.dismiss()
                case let .failure(error):
                    SVProgressHUD.showError(withStatus: error.message)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map(\.loginNetworkState)
            .distinctUntilChanged()
            .do(onNext: { state in
                switch state {
                case .success:
                    RCSensorAction.login(.success(())).trigger()
                case let .failure(error):
                    RCSensorAction.login(.failure(NetError(error.message))).trigger()
                default: ()
                }
            })
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .idle: ()
                case .begin: SVProgressHUD.show()
                case .success:
                    SVProgressHUD.dismiss()
                    self?.dismiss(animated: true, completion: nil)
                    NotificationNameLogin.post()
                    RCSceneUserManager.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
                        RCIM.shared().currentUserInfo = user.rcUser
                    }
                case let .failure(error):
                    SVProgressHUD.showError(withStatus: error.message)
                }
            })
            .disposed(by: disposeBag)
    }
    private func verification(phone: String) -> Bool {
#if OVERSEA
        phone.count >= 6
#else
        phone.count == 11
#endif
    }
    
    @objc private func handlePrivateLabelTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: privacyLabel)
        self.showRegisterPri(privacyLabel, point: point)
        self.showProvacyPri(privacyLabel, point: point)
    }
    
    @objc private func handleViewTap(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func showRegisterPri(_ view: UIView, point: CGPoint) {
        let area = CGRect(x: view.bounds.width / 3,
                          y: view.bounds.height / 3,
                          width: view.bounds.width / 3,
                          height: view.bounds.height / 3)
        guard area.contains(point) else { return }
        WebViewController.show(self,
                               title: "注册条款",
                               path: "https://cdn.ronghub.com/term_of_service_zh.html")
    }
    
    private func showProvacyPri(_ view: UIView, point: CGPoint) {
        let area = CGRect(x: view.bounds.width / 3 * 2,
                          y: view.bounds.height / 3,
                          width: view.bounds.width / 3,
                          height: view.bounds.height / 3)
        guard area.contains(point) else { return }
        WebViewController.show(self,
                               title: "隐私协议",
                               path: "https://cdn.ronghub.com/Privacy_agreement_zh.html")
    }
}
