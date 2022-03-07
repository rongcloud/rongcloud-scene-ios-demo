//
//  RCLVRAlertViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/18.
//

import UIKit

enum RCLVRSeatSheetActionAppearanceType {
    case normal
    case gradient
}

enum RCLVRSheetAlertActionType {
    case switchVideo(Bool)
    case switchMic(Bool)
    case cancelRequest
    case cancelInvitation
    case hangUp
    case cancel
}

struct RCLVRSeatSheetAction {
    let title: String
    let type: RCLVRSeatSheetActionAppearanceType
    
    var color: UIColor {
        switch type {
        case .normal: return UIColor(byteRed: 239, green: 73, blue: 154)
        case .gradient: return .white
        }
    }
    
    var backgroundImage: UIImage {
        let size = CGSize(width: 319.resize, height: 44.resize)
        switch type {
        case .gradient:
            let gradientLayer = CAGradientLayer()
            gradientLayer.locations = [0, 1]
            gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
            gradientLayer.colors = [
                UIColor(byteRed: 80, green: 93, blue: 255, alpha: 1).cgColor,
                UIColor(byteRed: 233, green: 43, blue: 136, alpha: 1).cgColor
            ]
            gradientLayer.bounds = CGRect(origin: .zero, size: size)
            gradientLayer.cornerRadius = 6.resize
            return UIGraphicsImageRenderer(size: size)
                .image { renderer in
                    gradientLayer.render(in: renderer.cgContext)
                }
        case .normal:
            let shapeLayer = CAShapeLayer()
            shapeLayer.lineWidth = 1
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor(byteRed: 239, green: 73, blue: 154).cgColor
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 0.5, dy: 0.5)
            shapeLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: 6.resize).cgPath
            return UIGraphicsImageRenderer(size: size)
                .image { renderer in
                    shapeLayer.render(in: renderer.cgContext)
                }
        }
    }
}

protocol RCLVRAlertDelegate: AnyObject {
    func didClickAction(_ action: RCLVRSheetAlertActionType)
}

class RCLVRAlertViewController: UIViewController {
    
    private(set) lazy var backView = UIView()
    private(set) lazy var contentView = UIView()
    
    weak var delegate: RCLVRAlertDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.numberOfTouchesRequired = 1
        backView.addGestureRecognizer(tap)
        
        contentView.backgroundColor = UIColor(byteRed: 3, green: 6, blue: 47)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(200)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        show()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismiss()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.layer.mask = maskLayer()
    }
    
    private func show() {
        backView.alpha = 0
        contentView.transform = CGAffineTransform(translationX: 0, y: contentHeight())
        UIView.animate(withDuration: 0.2) {
            self.backView.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.2) {
            self.backView.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentHeight())
        }
    }
    
    @objc private func tapHandler() {
        dismiss(animated: false)
    }
    
    deinit {
        debugPrint("Alert Controller destroy")
    }
}

extension RCLVRAlertViewController {
    @objc func contentHeight() -> CGFloat {
        return 240
    }
    
    @objc func maskLayer() -> CAShapeLayer {
        return CAShapeLayer()
    }
}

extension RCLVRAlertViewController {
    
    func RCActionButton(_ action: RCLVRSeatSheetAction) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(action.title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17.resize)
        button.setTitleColor(action.color, for: .normal)
        button.setTitleColor(action.color.withAlphaComponent(0.7), for: .highlighted)
        button.setBackgroundImage(action.backgroundImage, for: .normal)
        return button
    }
    
    func gradientBackgroundImage() -> UIImage {
        let size = CGSize(width: 319.resize, height: 44.resize)
        let gradientLayer = CAGradientLayer()
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.colors = [
            UIColor(byteRed: 80, green: 93, blue: 255, alpha: 1).cgColor,
            UIColor(byteRed: 233, green: 43, blue: 136, alpha: 1).cgColor
        ]
        gradientLayer.bounds = CGRect(origin: .zero, size: size)
        gradientLayer.cornerRadius = 6.resize
        return UIGraphicsImageRenderer(size: size)
            .image { renderer in
                gradientLayer.render(in: renderer.cgContext)
            }
    }
    
    func commonBackgroundImage() -> UIImage {
        let size = CGSize(width: 319.resize, height: 44.resize)
        let gradientLayer = CAGradientLayer()
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.colors = [
            UIColor(byteRed: 80, green: 93, blue: 255, alpha: 1).cgColor,
            UIColor(byteRed: 233, green: 43, blue: 136, alpha: 1).cgColor
        ]
        gradientLayer.bounds = CGRect(origin: .zero, size: size)
        gradientLayer.cornerRadius = 6.resize
        return UIGraphicsImageRenderer(size: size)
            .image { renderer in
                gradientLayer.render(in: renderer.cgContext)
            }
    }
}
