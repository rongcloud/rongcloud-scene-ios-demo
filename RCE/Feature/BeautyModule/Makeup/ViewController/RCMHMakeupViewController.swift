//
//  RCMHMakeupViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/2.
//

import UIKit

class RCMHMakeupViewController: UIViewController {
    
    private lazy var containerView = UIView()
    private var makeupView: MHMakeUpView = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180)
        return MHMakeUpView(frame: frame)
    }()
    
    private let manager: MHBeautyManager
    init(_ manager: MHBeautyManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-180)
        }
        containerView.addSubview(makeupView)
        makeupView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        makeupView.delegate = self
    }

}

extension RCMHMakeupViewController: MHMakeUpViewDelegate {
    func handleMakeUpType(_ type: Int, withON On: Bool) {
        manager.isUseMakeUp = type != 0
        guard let type = MHMakeupType(rawValue: type) else {
            return
        }
        manager.setBeautyManagerMakeUp(type, withOn: On)
    }
}

//- (void)getManagerActionStatus:(BOOL)hidden{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.statusLabel.hidden = YES;
//        self.statusLabel.text = @"";
//    });
//    
//}
