//
//  videoPropertiesSettingViewController.swift
//  RCE
//
//  Created by hanxiaoqing on 2021/11/26.
//

import UIKit
import Reusable

enum VideoSettingOption {
    case resolutionRatios([ResolutionRatio])
    case framesPerSecond([Int])
    case bitRates(Int)
}

extension VideoSettingOption {
    var settingDescription: String {
        switch self {
        case .resolutionRatios(_):
            return "分辨率"
        case .framesPerSecond(_):
            return "帧率"
        case .bitRates(_):
            return "推荐码率"
        }
    }
}


enum ResolutionRatio: String {
    case video640X480P = "640X480"
    case video720X480P = "720X480"
    case video1280X720P = "1280X720"
    case video1920X1080P = "1920X1080"
}

extension ResolutionRatio {
    var resolutionDescription: String {
        switch self {
        case .video640X480P:
            return  "640 * 480 (4:3)"
        case .video720X480P:
            return  "720 * 480 (3:2)"
        case .video1280X720P:
            return "1280 * 720 (16:9)"
        case .video1920X1080P:
            return "1920 * 1080 (16:9)"
        }
    }
    var minBitRate: Int {
        switch self {
        case .video640X480P:
            return 200
        case .video720X480P:
            return 200
        case .video1280X720P:
            return 250
        case .video1920X1080P:
            return 400
        }
    }
    func recommendBitRates(fps: Int) -> Int {
        var value: Int = 0
        switch self {
        case .video640X480P:
            value = 900
        case .video720X480P:
            value = 1000
        case .video1280X720P:
            value = 2200
        case .video1920X1080P:
            value = 4000
        }
        if fps == 24 || fps == 30 {
            value = Int(Double(value) * 1.5)
        }
        return value
    }
}

protocol VideoPropertiesDelegate: NSObjectProtocol {
    func videoPropertiesDidChanged(_ resolutionRatio: ResolutionRatio, fps: Int, bitRate: Int)
}


class VideoPropertiesSetViewController: UIViewController {
    
    private lazy var containerView: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(byteRed: 3, green: 6, blue: 47)
        return instance
    }()
    
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        instance.text = "视频设置"
        return instance
    }()
    
    private lazy var lineView: UIView = {
        let instance = UIView()
        instance.alpha = 0.4
        instance.backgroundColor = .white
        return instance
    }()
    
    private lazy var settingTableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .grouped)
        instance.register(cellType: VideoSettingGroupCell.self)
        instance.allowsSelection = false
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        instance.dataSource = self
        instance.delegate = self
        return instance
    }()
    
    weak var delegate: VideoPropertiesDelegate? = nil
    
    
    var selectSectionIndexPath: [Int:IndexPath] = [Int:IndexPath]()
    
    var selectResolutionRatio: ResolutionRatio = .video1280X720P
    
    var selectFps: Int = 15
    
    var computeBitRate: Int = 800
    
    private var settings: [VideoSettingOption] = [.resolutionRatios([.video640X480P, .video720X480P, .video1280X720P, .video1920X1080P]), .framesPerSecond([10, 15, 24, 30]), .bitRates(800)]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        enableClickingDismiss()
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(lineView)
        containerView.addSubview(settingTableView)
        
        buildLayoutOfViews()
        
        selectSectionIndexPath[0] = IndexPath(item: 2, section: 0)
        // 默认选中15帧率（section=1，内部cell位置：(item: 1, section: 1)）
        selectSectionIndexPath[1] = IndexPath(item: 1, section: 1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    private func buildLayoutOfViews() {
        containerView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-400)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(15)
            $0.centerX.equalTo(containerView)
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.8)
        }
        settingTableView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(15)
            $0.left.right.bottom.equalToSuperview()
        }
    }
}

extension VideoPropertiesSetViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: VideoSettingGroupCell.self)
        cell.delegate = self
        
        let selectIndex = selectSectionIndexPath[indexPath.section];
        let settingOption = settings[indexPath.section]
        
        switch indexPath.section {
        case 0:
            cell.updateContent(settingOption, rowItemsCount:2, selectIndex:selectIndex)
        case 1:
            cell.updateContent(settingOption, rowItemsCount:4, selectIndex:selectIndex)
        case 2:
            cell.updateContent(settingOption, rowItemsCount:1, selectIndex:selectIndex)
        default: do { }
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        20
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let settingOption = settings[section]
        return settingOption.settingDescription
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 90 + 15 * 2
        case 1: return 45 + 15
        case 2: return 45 + 15
        default: do { return 100 }
        }
    }
}

extension VideoPropertiesSetViewController: VideoSettingGroupCellDelegate {
    func didSelectedInnerCollectItem(_ at: IndexPath, inCell: VideoSettingGroupCell, settingOption: VideoSettingOption?) {
        let bitRatesCell = settingTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! VideoSettingGroupCell
        // 改变分辨率，改变帧率，码率
        switch settingOption {
        case .resolutionRatios(let ratios):
            // change bitRates
            selectResolutionRatio = ratios[at.item]
            computeBitRate = selectResolutionRatio.recommendBitRates(fps: selectFps)
            bitRatesCell.update(values: ["\(computeBitRate)kbps"])
        case .framesPerSecond(let fps):
            selectFps = fps[at.item]
            computeBitRate = selectResolutionRatio.recommendBitRates(fps: selectFps)
            settings[2] = .bitRates(computeBitRate)
            bitRatesCell.update(values: ["\(computeBitRate)kbps"])
        case .bitRates(let bitRate):
            print(bitRate)
        case .none: do { }
        }
        
        inCell.selectItemAt(index: at.item)
        delegate?.videoPropertiesDidChanged(selectResolutionRatio, fps: selectFps, bitRate: computeBitRate)
    }
}



