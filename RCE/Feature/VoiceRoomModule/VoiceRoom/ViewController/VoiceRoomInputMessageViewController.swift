//
//  VoiceRoomInputMessageViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/20.
//

import UIKit
import GrowingTextView
import SVProgressHUD
import RongChatRoom
import RongRTCLib
import IQKeyboardManager
import ISEmojiView

protocol VoiceRoomInputMessageProtocol: AnyObject {
    func onSendMessage(_ userId: String, userName: String, content: String)
}

class VoiceRoomInputMessageViewController: UIViewController {
    private weak var delegate: VoiceRoomInputMessageProtocol?
    private let roomId: String
    private lazy var tapGestureView = RCTapGestureView(self)
    private lazy var containterView = UIView()
    private lazy var containterLineView = UIView()
    private lazy var backImageView = UIImageView(image: R.image.message_background())
    private lazy var textView = GrowingTextView()
    private lazy var emojiView: EmojiView = {
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        keyboardSettings.countOfRecentsEmojis = 0
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        return emojiView
    }()
    private lazy var emojiButton = UIButton()
    private lazy var sendButton = UIButton()
    
    init(_ roomId: String, delegate: VoiceRoomInputMessageProtocol) {
        self.roomId = roomId
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        setupUI()
        fetchForbiddenList()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = false
        DispatchQueue.main.async {
            self.textView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = true
    }
    
    func fetchForbiddenList() {
        networkProvider.request(RCNetworkAPI.forbiddenList(roomId: roomId)) { result in
            switch result {
            case .success(let response):
                let data = response.data
                let responseModel = try? JSONDecoder().decode(VoiceRoomForbiddenResponse.self, from: data)
                let wordlist = responseModel?.data ?? []
                VoiceRoomManager.shared.forbiddenWordlist = wordlist.map(\.name)
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        let endFrame = value.cgRectValue
        var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
        if #available(iOS 11, *) {
            if keyboardHeight > 0 {
                keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
            }
        }
        let offsetY = -keyboardHeight
        containterView.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(offsetY)
        }
        view.layoutIfNeeded()
    }
    
    @objc private func onEmojiClicked() {
        if textView.inputView == nil {
            textView.inputView = emojiView
            emojiButton.setImage(R.image.message_keyboard(), for: .normal)
        } else {
            textView.inputView = nil
            emojiButton.setImage(R.image.message_emoji(), for: .normal)
        }
        textView.reloadInputViews()
    }
    
    @objc private func onSendClicked() {
        guard
            let text = textView.text, text.count > 0
        else {
            return SVProgressHUD.showError(withStatus: "消息不能为空")
        }
        let roomId = self.roomId
        UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
            guard text.isCivilized else {
                self?.delegate?.onSendMessage(user.userId, userName: user.userName, content: text)
                self?.dismiss(animated: true, completion: nil)
                return
            }
            let event = RCChatroomBarrage()
            event.userId = user.userId
            event.userName = user.userName
            event.content = text.civilized
            RCChatroomMessageCenter
                .sendChatMessage(roomId, content: event, success: { [weak self] mId in
                    self?.delegate?.onSendMessage(user.userId, userName: user.userName, content: text)
                    self?.dismiss(animated: true, completion: nil)
                }, error: { errorCode, mId in
                    SVProgressHUD.showError(withStatus: "消息发送失败")
                })
        }
    }
}

extension VoiceRoomInputMessageViewController {
    private func buildLayout() {
        view.addSubview(tapGestureView)
        view.addSubview(containterView)
        containterView.addSubview(backImageView)
        containterView.addSubview(textView)
        containterView.addSubview(emojiButton)
        containterView.addSubview(sendButton)
        containterView.addSubview(containterLineView)
        
        tapGestureView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(containterView.snp.top).offset(-30.resize)
        }
        
        containterView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.greaterThanOrEqualTo(50.resize)
        }
        
        backImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12.resize)
            make.top.bottom.equalToSuperview().inset(8.resize)
            make.right.equalTo(emojiButton.snp.left).offset(-12.resize)
        }
        
        emojiButton.snp.makeConstraints { make in
            make.width.height.equalTo(30.resize)
            make.centerY.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints { make in
            make.left.equalTo(emojiButton.snp.right).offset(12.resize)
            make.right.equalToSuperview().offset(-12.resize)
            make.centerY.equalToSuperview()
            make.width.equalTo(55.resize)
            make.height.equalTo(31.resize)
        }
        
        containterLineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        backImageView.contentMode = .scaleAspectFill
        
        containterLineView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = .black
        textView.maxLength = 140
        textView.trimWhiteSpaceWhenEndEditing = false
        textView.placeholder = "聊聊吧..."
        textView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
        textView.minHeight = 34.0.resize
        textView.maxHeight = 70.0.resize
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 12.0.resize
        textView.contentInset = UIEdgeInsets(top: 0, left: 6.resize, bottom: 0, right: 6.resize)
        
        emojiButton.setImage(R.image.message_emoji(), for: .normal)
        emojiButton.addTarget(self, action: #selector(onEmojiClicked), for: .touchUpInside)
        
        let sendTitle = NSAttributedString(string: "发送", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 14.resize)])
        sendButton.setAttributedTitle(sendTitle, for: .normal)
        sendButton.addTarget(self, action: #selector(onSendClicked), for: .touchUpInside)
        let sendBackImage = UIGraphicsImageRenderer(size: CGSize(width: 55.resize, height: 31.resize))
            .image { renderer in
                let context = renderer.cgContext
                let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: 55.resize, height: 31.resize)), cornerRadius: 15.5.resize)
                context.addPath(path.cgPath)
                context.clip()
                let colorsSpace = CGColorSpaceCreateDeviceRGB()
                let colors: CFArray = [
                    UIColor(hexString: "#E92B88").cgColor,
                    UIColor(hexString: "#505DFF").cgColor
                ] as CFArray
                let locations: [CGFloat] = [0, 1]
                guard
                    let gradient = CGGradient(colorsSpace: colorsSpace, colors: colors, locations: locations)
                else { return }
                context.drawLinearGradient(gradient,
                                           start: CGPoint(x: 27.5.resize, y: 0),
                                           end: CGPoint(x: 27.5.resize, y: 31.resize),
                                           options: .drawsBeforeStartLocation)
            }
        sendButton.setBackgroundImage(sendBackImage, for: .normal)
    }
}

extension VoiceRoomInputMessageViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        print(height)
        view.layoutIfNeeded()
    }
}

extension VoiceRoomInputMessageViewController: EmojiViewDelegate {
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        textView.insertText(emoji)
    }
    
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        textView.inputView = nil
        textView.keyboardType = .default
        textView.reloadInputViews()
    }
    
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        textView.deleteBackward()
    }
    
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        textView.resignFirstResponder()
    }
}

fileprivate extension String {
    var civilized: String {
        return VoiceRoomManager.shared.forbiddenWordlist.reduce(self) { $0.replacingOccurrences(of: $1, with: String(repeating: "*", count: $1.count)) }
    }
    
    var isCivilized: Bool {
        return VoiceRoomManager.shared.forbiddenWordlist.first(where: { contains($0) }) == nil
    }
}
