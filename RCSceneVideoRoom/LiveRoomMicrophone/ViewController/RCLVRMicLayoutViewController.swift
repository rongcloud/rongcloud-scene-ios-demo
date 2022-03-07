//
//  RCLVRMicLayoutViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/9.
//

import UIKit
import SVProgressHUD

extension RCLiveVideoMixType {
    var title: String {
        switch self {
        case .oneToOne: return "默认"
        case .oneToSix: return "浮窗"
        case .gridTwo: return "双人"
        case .gridThree: return "三人"
        case .gridFour: return "四宫格"
        case .gridSeven: return "七宫格"
        case .gridNine: return "九宫格"
        default: return "默认"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .oneToOne: return R.image.live_video_mix_default()
        case .oneToSix: return R.image.live_video_mix_one_six()
        case .gridTwo: return R.image.live_video_mix_grid_2()
        case .gridThree: return R.image.live_video_mix_grid_3()
        case .gridFour: return R.image.live_video_mix_grid_4()
        case .gridSeven: return R.image.live_video_mix_grid_7()
        case .gridNine: return R.image.live_video_mix_grid_9()
        default: return R.image.live_video_mix_default()
        }
    }
}

class RCLVRMicLayoutViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 14
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.register(cellType: RCLVRLayoutCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.contentInsetAdjustmentBehavior = .never
        instance.contentInset = UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
        instance.backgroundColor = .clear
        instance.dataSource = self
        instance.delegate = self
        return instance
    }()
    
    private lazy var items: [RCLiveVideoMixType] = [
        .oneToOne, .oneToSix, .gridTwo, .gridThree, .gridFour, .gridSeven, .gridNine
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if let index = items.firstIndex(of: RCLiveVideoEngine.shared().currentMixType) {
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        }
    }

}

extension RCLVRMicLayoutViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView
            .dequeueReusableCell(for: indexPath, cellType: RCLVRLayoutCell.self)
            .update(items[indexPath.item])
    }
}

extension RCLVRMicLayoutViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true)
        guard let controller = self.parent as? RCLVMicViewController else { return }
        controller.delegate?.didSwitchMixType(items[indexPath.item])
    }
}

extension RCLVRMicLayoutViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 22 * 2 - 14) / 2
        let height = 48.resize
        return CGSize(width: width, height: height)
    }
}
