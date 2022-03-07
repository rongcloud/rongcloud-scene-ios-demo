//
//  UserInfoEditViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/2.
//

import UIKit
import ReactorKit
import SVProgressHUD
import RxViewController
import RCSceneService
import RCSceneFoundation
import RCSceneVoiceRoom

final class UserInfoEditViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private lazy var cardView = UIView()
    private lazy var closeIconButton = UIButton()
    private lazy var userAvatarImageView: UIImageView = {
        let instance = UIImageView(image: R.image.default_avatar())
        instance.contentMode = .scaleAspectFill
        return instance
    }()
    private lazy var headerEditImageView = UIImageView(image: R.image.user_edit_image())
    private lazy var nameContainerView = UIView()
    private lazy var nameTextField = UITextField()
    private lazy var saveButton = UIButton()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        reactor = UserInfoEditReactor(Environment.currentUserId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("UIEVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupConstrains()
        setupUI()
    }
    
    func bind(reactor: UserInfoEditReactor) {
        rx.viewDidLoad
            .map { Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.user)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] user in
                self?.updateInfo(user)
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap(\.header)
            .distinctUntilChanged()
            .bind(to: userAvatarImageView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.updateState)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .idle: ()
                case .request:
                    SVProgressHUD.show()
                case let .success(user):
                    UserInfoDownloaded.shared.updateLocalCache(user)
                    if let loginUser = UserDefaults.standard.loginUser() {
                        let updatedUser = loginUser.update(name: user.userName, portrait: user.portrait ?? "")
                        UserDefaults.standard.set(user: updatedUser)
                    }
                    self?.dismiss(animated: true, completion: {
                        SVProgressHUD.showSuccess(withStatus: "更新成功")
                        NotificationNameUserInfoUpdated.post(UserDefaults.standard.loginUser())
                    })
                case let .failure(error):
                    SVProgressHUD.showError(withStatus: error.message)
                }
            })
            .disposed(by: disposeBag)
        
        userAvatarImageView.rx
            .tapGesture()
            .when(.recognized)
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = false
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                .take(1)
            }
            .map { info in
                let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
                return image?.kf.resize(to: CGSize(width: 200, height: 200), for: .aspectFill)
            }
            .map { Reactor.Action.header($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nameTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.name($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nameTextField.rx.controlEvent(.editingChanged)
            .subscribe(onNext: { [weak self] _ in
                self?.handleTextFieldEditing()
            })
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { Reactor.Action.update }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        closeIconButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { Reactor.Action.update }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func updateInfo(_ user: VoiceRoomUser) {
        userAvatarImageView.kf.setImage(with: URL(string: user.portraitUrl),
                                 placeholder: R.image.default_avatar())
        nameTextField.text = user.userName
        let userInfo = RCUserInfo(userId: user.userId, name: user.userName, portrait: user.portraitUrl)
        RCIM.shared().refreshUserInfoCache(userInfo, withUserId: user.userId)
    }
    
    private func handleTextFieldEditing() {
        guard let text = nameTextField.text else {
            return
        }
        guard nameTextField.markedTextRange == nil else {
            return
        }
        if text.count > 10 {
            let startIndex = text.startIndex
            let endIndex = text.index(startIndex, offsetBy: 10)
            nameTextField.text = String(text[startIndex..<endIndex])
        }
    }
}

extension UserInfoEditViewController {
    private func setupConstrains() {
        view.addSubview(cardView)
        cardView.addSubview(closeIconButton)
        cardView.addSubview(userAvatarImageView)
        cardView.addSubview(headerEditImageView)
        cardView.addSubview(nameContainerView)
        nameContainerView.addSubview(nameTextField)
        cardView.addSubview(saveButton)
        
        cardView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30.resize)
            make.width.equalTo(293.resize)
        }
        
        closeIconButton.snp.makeConstraints { make in
            make.centerX.equalTo(cardView.snp.right).offset(-31.resize)
            make.centerY.equalTo(cardView.snp.top).offset(31.resize)
            make.width.height.equalTo(36.resize)
        }
        
        userAvatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25.resize)
            make.width.height.equalTo(70.resize)
        }
        
        headerEditImageView.snp.makeConstraints { make in
            make.right.bottom.equalTo(userAvatarImageView)
            make.width.height.equalTo(20.resize)
        }
        
        nameContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(userAvatarImageView.snp.bottom).offset(23.resize)
            make.width.equalTo(233.resize)
            make.height.equalTo(40.resize)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(18.resize)
            make.top.bottom.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameContainerView.snp.bottom).offset(30.resize)
            make.width.equalTo(nameContainerView)
            make.height.equalTo(40.resize)
            make.bottom.equalToSuperview().inset(30.resize)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hexString: "#03062F").alpha(0.4)
        
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12.resize
        cardView.layer.masksToBounds = true
        
        userAvatarImageView.layer.cornerRadius = 35.resize
        userAvatarImageView.layer.masksToBounds = true
        
        nameContainerView.backgroundColor = UIColor(hexString: "#F3F4F5")
        nameContainerView.layer.cornerRadius = 4.resize
        nameContainerView.layer.masksToBounds = true
        
        headerEditImageView.contentMode = .scaleAspectFit
        
        nameTextField.textColor = UIColor(hexString: "#020037")
        nameTextField.placeholder = "请输入昵称"
        nameTextField.font = UIFont.systemFont(ofSize: 14.resize)
        nameTextField.returnKeyType = .done
        
        saveButton.backgroundColor = UIColor(hexString: "#7983FE")
        saveButton.layer.cornerRadius = 4.resize
        saveButton.layer.masksToBounds = true
        let saveAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17.resize)
        ]
        saveButton.setAttributedTitle(NSAttributedString(string: "保存", attributes: saveAttribute), for: .normal)
        
        let closeIcon = R.image.white_quite_icon()?.withRenderingMode(.alwaysTemplate)
        closeIconButton.setImage(closeIcon, for: .normal)
        closeIconButton.tintColor = .black
    }
}

