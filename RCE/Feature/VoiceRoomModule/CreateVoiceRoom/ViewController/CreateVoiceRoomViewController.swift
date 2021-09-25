//
//  CreateVoiceRoomViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import UIKit
import Kingfisher
import ReactorKit
import RxDataSources
import SVProgressHUD

class CreateVoiceRoomViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 20
        return instance
    }()
    private lazy var backgroundImageView: AnimatedImageView = {
        let instance = AnimatedImageView()
        instance.contentMode = .scaleAspectFill
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 40
        instance.backgroundColor = UIColor(hexString: "#160A56")
        return instance
    }()
    private lazy var dismissButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.down_white_arrow(), for: .normal)
        return instance
    }()
    private lazy var thumbButton: UIButton = {
        let instance = UIButton(type: .custom)
        instance.setBackgroundImage(R.image.create_voice_room_thumb(), for: .normal)
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 22
        instance.imageView?.contentMode = .scaleAspectFill
        return instance
    }()
    private lazy var createVoiceRoomImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.create_voice_room_pen()
        return instance
    }()
    private lazy var selectThumbLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16)
        instance.textColor = .white
        instance.text = "选择封面"
        return instance
    }()
    private lazy var textField: UITextField = {
        let instance = UITextField()
        instance.font = .systemFont(ofSize: 14)
        instance.backgroundColor = .white
        instance.layer.cornerRadius = 22
        instance.textColor = .black
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 23.resize, height: 44))
        instance.leftView = paddingView
        instance.leftViewMode = .always
        instance.returnKeyType = .done
        instance.addTarget(self, action: #selector(handleTextFieldEditing(textField:)), for: .editingChanged)
        instance.attributedPlaceholder = NSAttributedString(string: "设置房间标题", attributes: [.foregroundColor : UIColor.lightGray])
        return instance
    }()
    private lazy var setBackgroundLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16)
        instance.textColor = .white
        instance.text = "设置背景"
        return instance
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60.resize, height: 60.resize)
        layout.minimumLineSpacing = 17.resize
        layout.minimumInteritemSpacing = 17.resize
        layout.scrollDirection = .horizontal
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.backgroundColor = .clear
        instance.register(cellType: SelectVoiceRoomBgImageCollectionViewCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.contentInset = UIEdgeInsets(top: 0, left: 35.resize, bottom: 0, right: 35.resize)
        return instance
    }()
    private lazy var roomTypeLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16)
        instance.textColor = .white
        instance.text = "房间是否公开"
        return instance
    }()
    private lazy var privateButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle("私密", for: .normal)
        instance.setImage(R.image.roomtype_select_icon(), for: .selected)
        instance.setImage(R.image.roomtype_unselect_icon(), for: .normal)
        instance.setInsets(forContentPadding: UIEdgeInsets.zero, imageTitlePadding: 10)
        return instance
    }()
    private lazy var publicButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle("公开", for: .normal)
        instance.setImage(R.image.roomtype_select_icon(), for: .selected)
        instance.setImage(R.image.roomtype_unselect_icon(), for: .normal)
        instance.setInsets(forContentPadding: UIEdgeInsets.zero, imageTitlePadding: 10)
        return instance
    }()
    private lazy var createButton: GradientButton = {
        let instance = GradientButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 17)
        instance.setTitle("创建房间", for: .normal)
        instance.setImage(R.image.create_room_icon(), for: .normal)
        instance.layer.cornerRadius = 24
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var tapGestureView = RCTapGestureView(self)
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<SelectRoomBackgroundSection> = {
        return RxCollectionViewSectionedReloadDataSource<SelectRoomBackgroundSection> { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SelectVoiceRoomBgImageCollectionViewCell.self)
            cell.updateCell(item)
            return cell
        }
    }()
    private var heightConstraint: NSLayoutConstraint!
    
    var onRoomCreated: ((CreateVoiceRoomWrapper) -> Void)?
    
    init(imagelist: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = CreateVoiceRoomReacotor(imagelist: imagelist)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heightConstraint.constant = container.bounds.height
    }
    
    private func buildLayout() {
        view.addSubview(backgroundImageView)
        view.addSubview(tapGestureView)
        view.addSubview(container)
        container.addSubview(thumbButton)
        container.addSubview(selectThumbLabel)
        container.addSubview(textField)
        container.addSubview(setBackgroundLabel)
        container.addSubview(collectionView)
        container.addSubview(roomTypeLabel)
        container.addSubview(privateButton)
        container.addSubview(publicButton)
        container.addSubview(createButton)
        container.addSubview(dismissButton)
        thumbButton.addSubview(createVoiceRoomImageView)
        
        tapGestureView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(container.snp.top).offset(-20)
        }
        
        container.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
        }
        
        thumbButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40.resize)
            $0.size.equalTo(CGSize(width: 110.resize, height: 110.resize))
            $0.centerX.equalToSuperview()
        }
        
        createVoiceRoomImageView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(8)
        }
        
        selectThumbLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(thumbButton.snp.bottom).offset(15.resize)
        }
        
        textField.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(42.resize)
            $0.top.equalTo(selectThumbLabel.snp.bottom).offset(20.resize)
            $0.height.equalTo(44)
        }
        
        setBackgroundLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(42.resize)
            $0.top.equalTo(textField.snp.bottom).offset(20.resize)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(setBackgroundLabel.snp.bottom).offset(15.resize)
            make.left.right.equalToSuperview()
            make.height.equalTo(60.resize)
        }
        
        roomTypeLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(42.resize)
            $0.top.equalTo(collectionView.snp.bottom).offset(25.resize)
        }
        
        privateButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(42.resize)
            $0.top.equalTo(roomTypeLabel.snp.bottom).offset(15.resize)
        }
        
        publicButton.snp.makeConstraints {
            $0.left.equalTo(privateButton.snp.right).offset(60.resize)
            $0.centerY.equalTo(privateButton)
        }
        
        createButton.snp.makeConstraints {
            $0.top.equalTo(privateButton.snp.bottom).offset(36.resize)
            $0.height.equalTo(49)
            $0.left.right.equalToSuperview().inset(42.resize)
            $0.bottom.equalToSuperview().inset(60.resize)
        }
        
        dismissButton.snp.makeConstraints {
            $0.right.top.equalToSuperview().inset(20.resize)
        }
        
        backgroundImageView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
        }
        heightConstraint = backgroundImageView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
    }
    
    func bind(reactor: CreateVoiceRoomReacotor) {
        dismissButton.rx.tap.subscribe { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        rx.viewDidLoad
            .map {
                let randomName = [
                    "room_background_image1",
                    "room_background_image2",
                    "room_background_image3",
                    "room_background_image4",
                    "room_background_image5",
                    "room_background_image6"
                ]
                .randomElement() ?? "room_background_image1"
                return UIImage(named: randomName)
            }
            .map {Reactor.Action.selectThumbImage($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.error?)
            .distinctUntilChanged()
            .map(\.message)
            .bind(to: SVProgressHUD.rx.errorStatus)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.success?)
            .distinctUntilChanged()
            .map(\.message)
            .bind(to: SVProgressHUD.rx.successStatus)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.thumbImage)
            .bind(to: thumbButton.rx.backgroundImage())
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.bgImageUrl)
            .distinctUntilChanged()
            .bind(to: backgroundImageView.rx.animatedUrl)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.section)
            .distinctUntilChanged()
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        rx.viewDidAppear
            .subscribe(onNext: {
                [weak self] value in
                guard let self = self else { return }
                self.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
            }).disposed(by: disposeBag)
        
        textField.rx
            .text
            .orEmpty
            .map { Reactor.Action.inputRoomName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { ($0.type == .privateRoom) }
            .bind(to: privateButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { ($0.type == .publicRoom) }
            .bind(to: publicButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.showPassoword)
            .distinctUntilChanged()
            .filter { isShow in
                return isShow
            }
            .flatMap { [weak self] isShow -> Observable<String> in
                guard let self = self else { return Observable.empty() }
                if let vc = self.navigator(.inputPassword(type: .input, delegate: nil)) as? VoiceRoomPasswordViewController {
                    return vc.rx.password
                }
                return Observable.empty()
            }
            .filter{ $0.count == 4}
            .map { password in Reactor.Action.inputPassowrd(password)}
            .bind(to: reactor.action).disposed(by: disposeBag)
        
        reactor.state
            .map(\.needLogin)
            .distinctUntilChanged()
            .filter {
                $0
            }
            .subscribe(onNext: {
                [weak self] value in
                guard let self = self else { return }
                self.onLogout()
            }).disposed(by: disposeBag)
        
        privateButton.rx
            .tap
            .map { Reactor.Action.selectRoomType(.privateRoom) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        publicButton.rx
            .tap
            .map { Reactor.Action.selectRoomType(.publicRoom) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.rx
            .modelSelected(String.self)
            .map {Reactor.Action.selectBackgroundImage($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        thumbButton.rx
            .tap
            .debug()
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = false
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                .take(1)
            }
            .map { info -> UIImage? in
                let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
                return image?.resizeAspectFillImage(to: CGSize(width: 200, height: 200))
            }
            .map { Reactor.Action.selectThumbImage($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        createButton.rx
            .tap
            .map { Reactor.Action.createRoom }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.createdRoom)
            .take(1)
            .do(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .subscribe(onNext: { [weak self] wrapper in
                self?.onRoomCreated?(wrapper)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func onLogout() {
        if let presented = presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.onLogout()
            }
            return
        }
        navigationController?.popToRootViewController(animated: true)
        navigator(.login)
        VoiceRoomManager.shared.leave { _ in }
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
    
    deinit {
        print("create room deinit")
    }
}

extension Reactive where Base == CreateVoiceRoomViewController {
    var createSuccess: Observable<CreateVoiceRoomWrapper> {
        return base.reactor!.state
            .compactMap(\.createdRoom)
            .take(1)
            .asObservable()
            .do { [weak base] _ in
                base?.dismiss(animated: true, completion: nil)
            }
    }
}
