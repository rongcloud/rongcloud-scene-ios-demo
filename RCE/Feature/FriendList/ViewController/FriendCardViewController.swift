//
//  FriendCardViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/4.
//

import UIKit

final class FriendCardViewController: UIViewController {
    
    private lazy var tapView = RCTapGestureView(self)
    private lazy var cardView = UIView()
    private lazy var shapeLayer = CAShapeLayer()
    private lazy var avatarImageView = UIImageView(image: R.image.default_avatar())
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.text = "--"
        instance.textColor = UIColor(byteRed: 3, green: 0, blue: 58)
        instance.font = UIFont.systemFont(ofSize: 17.resize, weight: .medium)
        return instance
    }()
    private lazy var chatButton: UIButton = {
        let instance = UIButton()
        instance.setTitle("发私信", for: .normal)
        instance.setTitleColor(UIColor(hexString: "#EF499A"), for: .normal)
        instance.titleLabel?.font = UIFont.systemFont(ofSize: 14.resize)
        instance.addTarget(self, action: #selector(chat), for: .touchUpInside)
        return instance
    }()
    
    private let userId: String
    init(_ userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let shapeRect = CGRect(x: 0,
                               y: 37.5.resize,
                               width: cardView.bounds.width,
                               height: cardView.bounds.height - 37.5.resize)
        let path = UIBezierPath(roundedRect: shapeRect,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 20.resize, height: 20.resize))
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.frame = cardView.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black.alpha(0.7)
        
        setupConstraint()
        
        UserInfoDownloaded.shared
            .fetchUserInfo(userId: userId) { [weak self] user in self?.update(user) }
    }
    
    private func update(_ user: VoiceRoomUser) {
        nameLabel.text = user.userName
        avatarImageView.kf.setImage(with: URL(string: user.portraitUrl),
                                    placeholder: R.image.default_avatar())
    }
    
    @objc private func chat() {
        let userId = userId
        let controller = presentingViewController
        dismiss(animated: true) {
            guard let controller = controller?.currentVisableViewController() else { return }
            controller.navigator(.privateChat(userId: userId))
        }
    }
}

extension FriendCardViewController {
    private func setupConstraint() {
        view.addSubview(tapView)
        view.addSubview(cardView)
        cardView.layer.addSublayer(shapeLayer)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(chatButton)
        
        tapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cardView.backgroundColor = .clear
        cardView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200.resize)
        }
        
        avatarImageView.backgroundColor = .white
        avatarImageView.layer.cornerRadius = 37.5.resize
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderWidth = 9.resize
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.height.equalTo(75.resize)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarImageView.snp.bottom)
            make.width.lessThanOrEqualToSuperview().offset(-30)
        }
        
        let chatSize = CGSize(width: 160.resize, height: 43.resize)
        chatButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(30.resize)
            make.size.equalTo(chatSize)
        }
        let chatImage = UIGraphicsImageRenderer(size: chatSize)
            .image { renderer in
                let rect = CGRect(origin: .zero, size: chatSize).insetBy(dx: 0.5, dy: 0.5)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: chatSize.height * 0.5)
                renderer.cgContext.addPath(path.cgPath)
                UIColor(byteRed: 239, green: 73, blue: 154).setStroke()
                renderer.cgContext.setLineWidth(1)
                renderer.cgContext.strokePath()
            }
        chatButton.setBackgroundImage(chatImage, for: .normal)
    }
}
