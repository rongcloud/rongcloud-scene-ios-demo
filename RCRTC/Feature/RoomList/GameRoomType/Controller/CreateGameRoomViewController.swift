//
//  CreateGameRoomViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import UIKit
import Kingfisher
import SVProgressHUD

protocol CreateGameRoomProtocol: AnyObject {
    func serverCreateRoomOver(roomInfo: RCSceneRoom)
}

class CreateGameRoomViewController: UIViewController {
    
    weak var delegate: CreateGameRoomProtocol?
    
    var gameModels = [RCSceneGameResp]()
    var selectedGameId: String?
    
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 20
        return instance
    }()
    
    private lazy var backgroundView: UIImageView = {
        let instance = UIImageView(image: R.image.groom_bg_icon())
        instance.contentMode = .scaleAspectFill
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 40
        instance.backgroundColor = .white
        return instance
    }()
    
    private lazy var setBackgroundLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16)
        instance.textColor = UIColor(hexString: "#03003A")
        instance.text = "选择游戏"
        return instance
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 74.resize, height: 74.resize)
        layout.scrollDirection = .horizontal
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.backgroundColor = .clear
        instance.register(RCGameSelectCell.self, forCellWithReuseIdentifier: "SELECT_CELL")
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.delegate = self
        instance.dataSource = self
        instance.contentInset = UIEdgeInsets(top: 0, left: 35.resize, bottom: 0, right: 35.resize)
        return instance
    }()
    
    private lazy var roomNameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16)
        instance.textColor = UIColor(hexString: "#03003A")
        instance.text = "房间名称"
        return instance
    }()
    
    private lazy var textField: UITextField = {
        let instance = UITextField()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = UIColor(hexString: "#03003A")
        instance.layer.cornerRadius = 22
        instance.backgroundColor = UIColor(hexString: "#E8F0F3")
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 23.resize, height: 44))
        instance.leftView = paddingView
        instance.leftViewMode = .always
        instance.keyboardType = .default
        instance.returnKeyType = .done
        instance.text = "快来和我一起互动吧"
        instance.addTarget(self, action: #selector(handleTextFieldEditing(textField:)), for: .editingChanged)
//        instance.attributedPlaceholder = NSAttributedString(string: "快来和我一起互动吧", attributes: [.foregroundColor : UIColor(hexString: "#03003A")])
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
        instance.addTarget(self, action: #selector(handleCreateBtnClick), for: .touchUpInside)
        return instance
    }()

    private var heightConstraint: NSLayoutConstraint!
    
    func getGameList() {
        gameRoomProvider.request(.gameList) { result in
            switch result.map(RCSceneWrapper<[RCSceneGameResp]>.self) {
            case let .success(wrapper):
                if let list = wrapper.data {
                    self.gameModels = list
                    self.collectionView.reloadData()
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
        self.getGameList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heightConstraint.constant = container.bounds.height
    }
    
    private func buildLayout() {
        view.addSubview(backgroundView)
        enableClickingDismiss()
        view.addSubview(container)
        container.addSubview(setBackgroundLabel)
        container.addSubview(collectionView)
        container.addSubview(roomNameLabel)
        container.addSubview(textField)
        container.addSubview(createButton)
        
        container.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
        }
        
        setBackgroundLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(42.resize)
            $0.top.equalToSuperview().offset(50.resize)
        }

        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(setBackgroundLabel.snp.bottom).offset(15.resize)
            make.left.right.equalToSuperview()
            make.height.equalTo(102.resize)
        }
        
        roomNameLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(42.resize)
            $0.top.equalTo(collectionView.snp.bottom).offset(20.resize)
        }
        
        textField.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(42.resize)
            $0.top.equalTo(roomNameLabel.snp.bottom).offset(20.resize)
            $0.height.equalTo(44)
        }
        
        createButton.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(36.resize)
            $0.height.equalTo(49)
            $0.left.right.equalToSuperview().inset(42.resize)
            $0.bottom.equalToSuperview().inset(60.resize)
        }
        
        backgroundView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
        }
        heightConstraint = backgroundView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            textField.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    
    @objc private func onLogout() {
        if let presented = presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.onLogout()
            }
            return
        }
        navigationController?.popToRootViewController(animated: true)
        NotificationNameLogout.post()
    }
    
    @objc private func handleTextFieldEditing(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        guard textField.markedTextRange == nil else {
            return
        }
        textField.text = String(text.prefix(11))
    }
    
    @objc func handleCreateBtnClick() {
        guard let gameId = selectedGameId else {
            SVProgressHUD.showError(withStatus: "请选择游戏类型")
            return
        }

        var roomName = "快来和我一起互动吧"
        if let text = textField.text, text.isEmpty == false {
            roomName = text
        }
        SVProgressHUD.show()

        let api = RCGameRoomService.createGameRoom(name: roomName, themePictureUrl: "", backgroundUrl: "", kv: [], isPrivate: 0, password: "", roomType: 4, gameId: gameId)
        gameRoomProvider.request(api) { result in
            SVProgressHUD.dismiss()
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(wrapper):
                if let roomInfo = wrapper.data {
                    SVProgressHUD.showSuccess(withStatus: "创建成功")
                    self.dismiss(animated: true) {
                        self.delegate?.serverCreateRoomOver(roomInfo: roomInfo)
                    }
                } else {
                    SVProgressHUD.showError(withStatus: "创建失败，请重试")
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
   
}

extension CreateGameRoomViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameModels.count
    }
    
}

extension CreateGameRoomViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SELECT_CELL", for: indexPath) as! RCGameSelectCell
        return cell.updateCell(game: gameModels[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gameModel = gameModels[indexPath.row]
        selectedGameId = gameModel.gameId
    }
}

