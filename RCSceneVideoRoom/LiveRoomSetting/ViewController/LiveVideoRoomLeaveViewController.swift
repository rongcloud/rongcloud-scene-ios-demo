//
//  LiveVideoRoomLeaveViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/6/9.
//

import UIKit

protocol LiveVideoRoomLeaveDelegate: AnyObject {
    func leaveRoomDidClick()
    func scaleRoomDidClick()
}

final class LiveVideoRoomLeaveViewController: UIViewController {
    weak var delegate: LiveVideoRoomLeaveDelegate?
    
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(byteRed: 3, green: 6, blue: 47, alpha: 0.8)
        instance.layer.cornerRadius = 20.resize
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var leaveButton: UIButton = {
        let instance = UIButton()
        instance.setBackgroundImage(R.image.leave_voiceroom(), for: .normal)
        instance.addTarget(self, action: #selector(leaveButtonDidClick), for: .touchUpInside)
        return instance
    }()
    private lazy var leaveLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = UIColor.white
        instance.font = .systemFont(ofSize: 12.resize)
        instance.text = "离开房间"
        return instance
    }()
    private lazy var scaleButton: UIButton = {
        let instance = UIButton()
        instance.setBackgroundImage(R.image.room_scale_icon(), for: .normal)
        instance.addTarget(self, action: #selector(scaleButtonDidClick), for: .touchUpInside)
        return instance
    }()
    private lazy var scaleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = UIColor.white
        instance.font = .systemFont(ofSize: 12.resize)
        instance.text = "收起房间"
        return instance
    }()
    
    private lazy var upIconImageView = UIImageView(image: R.image.leave_room_up_icon())
    private lazy var tapGestureView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        show()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismiss()
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        
        view.addSubview(container)
        container.addSubview(leaveButton)
        container.addSubview(leaveLabel)
        container.addSubview(scaleButton)
        container.addSubview(scaleLabel)
        container.addSubview(upIconImageView)
        
        container.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(142.resize)
        }
        
        leaveButton.snp.makeConstraints {
            $0.width.height.equalTo(50.resize)
            $0.bottom.equalToSuperview().offset(-61.resize)
            $0.right.equalTo(container).offset(-70.resize)
        }
        
        leaveLabel.snp.makeConstraints { make in
            make.centerX.equalTo(leaveButton)
            make.bottom.equalToSuperview().offset(-37.resize)
        }
        
        scaleButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(70.resize)
            make.width.height.equalTo(50.resize)
            make.bottom.equalToSuperview().offset(-61.resize)
        }
        
        scaleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(scaleButton)
            make.bottom.equalToSuperview().offset(-37.resize)
        }
        
        upIconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-7.resize)
            make.width.height.equalTo(27.resize)
        }
    }
    
    @objc func leaveButtonDidClick() {
        dismiss(animated: false) { [unowned self] in delegate?.leaveRoomDidClick() }
    }
    
    @objc func scaleButtonDidClick() {
        dismiss(animated: false) { [unowned self] in delegate?.scaleRoomDidClick() }
    }
    
    private func show() {
        container.transform = CGAffineTransform(translationX: 0, y: -142.resize)
        UIView.animate(withDuration: 0.2) {
            self.container.transform = .identity
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.2) {
            self.container.transform = CGAffineTransform(translationX: 0, y: -142.resize)
        }
    }
}
