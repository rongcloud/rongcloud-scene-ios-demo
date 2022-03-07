//
//  VoiceRoomGiftCountViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/27.
//

import UIKit

protocol VoiceRoomGiftCountViewControllerDelegate: AnyObject {
    func onGiftCountSelected(_ count: Int)
}

public final class VoiceRoomGiftCountViewController: UIViewController {
    
    private let sendView: VoiceRoomGiftSendView
    
    private lazy var backView = UIView()
    private lazy var menuView = VoiceRoomGiftCountMenuView()
    private lazy var customCountButton = UIButton()
    private lazy var count1Button = createButton(1)
    private lazy var count10Button = createButton(10)
    private lazy var count99Button = createButton(99)
    private lazy var count666Button = createButton(666)
    private lazy var count999Button = createButton(999)
    
    public init(_ sendView: VoiceRoomGiftSendView) {
        self.sendView = sendView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupConstraints()
        setupUI()
        
        setLastSelectedButton()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        backView.addGestureRecognizer(tapGesture)
    }
    
    private func setLastSelectedButton() {
        switch sendView.count {
        case 1:
            setSelectedButton(count1Button)
        case 10:
            setSelectedButton(count10Button)
        case 99:
            setSelectedButton(count99Button)
        case 666:
            setSelectedButton(count666Button)
        case 999:
            setSelectedButton(count999Button)
        default: break
        }
    }

    private func setSelectedButton(_ button: UIButton) {
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexString: "#E92B88").withAlphaComponent(0.6).cgColor
        button.layer.cornerRadius = 6.resize
        button.backgroundColor = UIColor(hexString: "#E92B88").withAlphaComponent(0.1)
    }
    
    @objc private func onTap() {
        sendView.count = sendView.count
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onCountButtonClicked(_ button: UIButton) {
        if button.tag == 0 {
            customCount()
        } else {
            sendView.count = button.tag
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func customCount() {
        let alertController = UIAlertController(title: "请输入自定义数字", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        let sureAction = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            guard let text = alertController.textFields?.first?.text, let count = Int(text), count > 0 else { return }
            self?.sendView.count = count
            self?.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(sureAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension VoiceRoomGiftCountViewController {
    private func setupConstraints() {
        view.addSubview(backView)
        view.addSubview(menuView)
        menuView.addSubview(customCountButton)
        menuView.addSubview(count1Button)
        menuView.addSubview(count10Button)
        menuView.addSubview(count99Button)
        menuView.addSubview(count666Button)
        menuView.addSubview(count999Button)
        
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let sendViewFrame = view.convert(sendView.frame, from: sendView.superview)
        let rightOffetX = view.frame.width - sendViewFrame.maxX
        let bottomOffsetY = view.frame.height - sendViewFrame.minY
        
        menuView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-rightOffetX)
            make.bottom.equalToSuperview().offset(-bottomOffsetY - 5.resize)
            make.width.equalTo(123.resize)
            make.height.equalTo(195.resize)
        }
        
        customCountButton.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(5.resize)
            make.height.equalTo(26.resize)
        }
        
        count999Button.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5.resize)
            make.top.equalTo(customCountButton.snp.bottom).offset(5.resize)
        }
        
        count666Button.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5.resize)
            make.top.equalTo(count999Button.snp.bottom).offset(5.resize)
            make.height.equalTo(count999Button)
        }
        
        count99Button.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5.resize)
            make.top.equalTo(count666Button.snp.bottom).offset(5.resize)
            make.height.equalTo(count666Button)
        }
        
        count10Button.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5.resize)
            make.top.equalTo(count99Button.snp.bottom).offset(5.resize)
            make.height.equalTo(count99Button)
        }
        
        count1Button.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5.resize)
            make.top.equalTo(count10Button.snp.bottom).offset(5.resize)
            make.height.equalTo(count10Button)
            make.bottom.equalToSuperview().offset(-9.resize)
        }
    }
    
    private func setupUI() {
        backView.backgroundColor = .clear
        
        menuView.offsetRight = sendView.getDistanceOfArrowCenterToTheRight()
        
        customCountButton.backgroundColor = UIColor(hexString: "#F4F4F7")
        customCountButton.layer.cornerRadius = 6.resize
        customCountButton.layer.masksToBounds = true
        customCountButton.setTitle("自定义", for: .normal)
        customCountButton.setTitleColor(UIColor(hexString: "#B2B2B2"), for: .normal)
        customCountButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.resize)
        customCountButton.addTarget(self, action: #selector(customCount), for: .touchUpInside)
    }
    
    private func createButton(_ count: Int) -> UIButton {
        let button = UIButton()
        button.tag = count
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12.resize, weight: .medium),
            .foregroundColor: UIColor(hexString: "#333333")
        ]
        button.setAttributedTitle(NSAttributedString(string: "\(count)", attributes: attributes), for: .normal)
        button.addTarget(self, action: #selector(onCountButtonClicked(_:)), for: .touchUpInside)
        return button
    }
}

final class VoiceRoomGiftCountMenuView: UIView {
    
    private lazy var shapeLayer = CAShapeLayer()
    
    var offsetRight: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer.frame = bounds
        
        let offsetX = bounds.width - offsetRight
        let radius: CGFloat = 3.resize
        let triangleWidth: CGFloat = 6.resize
        let triangleHeight: CGFloat = 3.resize
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: radius))
        path.addArc(withCenter: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: .pi,
                    endAngle: .pi * 1.5,
                    clockwise: true)
        path.addArc(withCenter: CGPoint(x: bounds.width - radius, y: radius),
                    radius: radius,
                    startAngle: .pi * 1.5,
                    endAngle: .pi * 2,
                    clockwise: true)
        path.addArc(withCenter: CGPoint(x: bounds.width - radius, y: bounds.height - triangleHeight - radius),
                    radius: radius,
                    startAngle: 0,
                    endAngle: .pi * 0.5,
                    clockwise: true)
        path.addLine(to: CGPoint(x: offsetX + triangleWidth * 0.5, y: bounds.height - triangleHeight))
        path.addLine(to: CGPoint(x: offsetX, y: bounds.height))
        path.addLine(to: CGPoint(x: offsetX - triangleWidth * 0.5, y: bounds.height - triangleHeight))
        path.addArc(withCenter: CGPoint(x: radius, y: bounds.height - triangleHeight - radius),
                    radius: radius,
                    startAngle: .pi * 0.5,
                    endAngle: .pi,
                    clockwise: true)
        path.close()
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.path = path.cgPath
    }
}
