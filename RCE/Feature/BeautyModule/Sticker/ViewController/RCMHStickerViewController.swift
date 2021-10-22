//
//  RCMHStickerViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/2.
//

import UIKit

class RCMHStickerViewController: UIViewController {
    
    private lazy var containerView = UIView()
    private var stickerView: MHStickersView = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 250)
        return MHStickersView(frame: frame)
    }()
    
    private let manager: MHBeautyManager
    init(_ manager: MHBeautyManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .clear
        enableClickingDismiss()
        containerView.backgroundColor = UIColor(byteRed: 3, green: 6, blue: 47)
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-250)
        }
        containerView.addSubview(stickerView)
        stickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stickerView.delegate = self
    }

}

extension RCMHStickerViewController: MHStickersViewDelegate {
    func handleStickerEffect(_ stickerContent: String, withLevel level: Int) {
        manager.isUseSticker = level > 0
        manager.setSticker(stickerContent, withLevel: level)
    }
}
