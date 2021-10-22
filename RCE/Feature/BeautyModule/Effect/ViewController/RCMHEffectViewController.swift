//
//  RCMHEffectViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/2.
//

import UIKit

class RCMHEffectViewController: UIViewController {
    
    private lazy var containerView = UIView()
    private var effectView: MHSpecificAssembleView = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180)
        return MHSpecificAssembleView(frame: frame)
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-180)
        }
        containerView.addSubview(effectView)
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        effectView.delegate = self
    }

}

extension RCMHEffectViewController: MHSpecificAssembleViewDelegate {
    func handleSpecific(withType type: Int) {
        guard let type = MHJitterType(rawValue: type) else {
            return
        }
        manager.setJitterType(type)
    }
    
    func handleMagnity(withType type: Int) {
        manager.isUseHaha = type != 0
        guard let type = MHDistortType(rawValue: type) else {
            return
        }
        manager.setDistortType(type, withIsMenu: false)
    }
    
    func handleWatermark(with model: MHBeautiesModel) {
        manager.setWatermarkRect(CGRect(x: 0.08, y: 0.08, width: 0.1, height: 0.1))
        guard let alignment = MHWatermarkAlign(rawValue: model.aliment) else {
            return
        }
        manager.setWatermark(model.imgName, alignment: alignment)
    }
    
    func handleSpecificStickerActionEffect(_ stickerContent: String, sticker model: StickerDataListModel, action: Int32) {
        manager.isUseSticker = action != 0
        manager.setSticker(stickerContent, action: action)
        DispatchQueue.main.async {
            switch action {
            case 0: ()
            default: ()
            }
//            stickerView.clearUI()
        }
    }
}

//    [self.beautyManager setSticker:stickerContent action:action];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        switch (action) {
//            case 0:
//            {
//                self.statusLabel.hidden = YES;
//                self.statusLabel.text = @"";
//            }
//                break;
//            case 1:
//            {
//                self.statusLabel.hidden = NO;
//                self.statusLabel.text = YZMsg(@"请抬头");
//            }
//                break;
//            case 2:
//            {
//                self.statusLabel.hidden = NO;
//                self.statusLabel.text = YZMsg(@"请张嘴");
//            }
//                break;
//            case 3:
//            {
//                self.statusLabel.hidden = NO;
//                self.statusLabel.text = YZMsg(@"请眨眼");
//            }
//                break;
//                
//            default:
//                break;
//        }
//        
//        if ([MHSDK shareInstance].menuArray.count > 0) {
//            for (MHBeautiesModel * model in self.array) {
//                NSString * itemName = model.beautyTitle;
//                if ([itemName isEqualToString:@"贴纸"]) {
//                    [self.stickersView clearStikerUI];
//                }
//            }
//        }
//        
//    });
//    
//}
