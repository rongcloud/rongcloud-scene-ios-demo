//
//  FeedbackReasonView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/7/20.
//

import UIKit
import SVProgressHUD

protocol FeedbackReasonViewProtocol: AnyObject {
    func reasonsDidSelected(reason: String)
    func canelDidClick()
}

class FeedbackReasonView: UIView {
    weak var delegate: FeedbackReasonViewProtocol?
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16)
        instance.textColor = UIColor(hexString: "020037")
        instance.text = "请问哪个方面需改进呢？"
        return instance
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 106, height: 66)
        layout.minimumLineSpacing = 23
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.backgroundColor = .white
        instance.register(cellType: FeedbackReasonCollectionViewCell.self)
        instance.dataSource = self
        instance.delegate = self
        instance.isScrollEnabled = false
        instance.allowsMultipleSelection = true
        return instance
    }()
    private lazy var uploadButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 18)
        instance.setTitle("提交反馈", for: .normal)
        instance.setTitleColor(UIColor(hexString: "#7983FE"), for: .normal)
        instance.addTarget(self, action: #selector(handleUpload), for: .touchUpInside)
        return instance
    }()
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 18)
        instance.setTitle("我再想想", for: .normal)
        instance.setTitleColor(UIColor(hexString: "#020037"), for: .normal)
        instance.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return instance
    }()
    private lazy var separatorline1: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#979797").withAlphaComponent(0.5)
        return instance
    }()
    private lazy var separatorline2: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#979797").withAlphaComponent(0.5)
        return instance
    }()
    private let list = FeedbackReasonType.allCases
    private var reasons = [FeedbackReasonType]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(uploadButton)
        addSubview(cancelButton)
        addSubview(separatorline1)
        addSubview(separatorline2)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.width.equalTo(236)
            make.centerX.equalToSuperview()
            make.height.equalTo(160)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(uploadButton)
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(44)
        }
        
        separatorline1.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(uploadButton)
            make.height.equalTo(1)
        }
        
        separatorline2.snp.makeConstraints { make in
            make.top.equalTo(separatorline1.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(1)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func handleUpload() {
        guard reasons.count > 0 else {
            SVProgressHUD.showError(withStatus: "请至少选择一项原因")
            return
        }
        delegate?.reasonsDidSelected(reason: reasons.map(\.title).joined(separator: ","))
    }
    
    @objc private func handleCancel() {
        delegate?.canelDidClick()
    }
}

extension FeedbackReasonView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: FeedbackReasonCollectionViewCell.self)
        cell.updateCell(reason: list[indexPath.row])
        return cell
    }
}

extension FeedbackReasonView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        reasons.append(list[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = reasons.firstIndex(of: list[indexPath.row]) {
            reasons.remove(at: index)
        }
    }
}
