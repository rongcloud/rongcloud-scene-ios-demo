//
//  ChangeBackgroundViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/18.
//

import UIKit

protocol ChangeBackgroundImageProtocol: AnyObject {
    func didConfirmImage(urlSuffix: String)
}

class ChangeBackgroundViewController: UIViewController {
    weak var delegate: ChangeBackgroundImageProtocol?
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16, weight: .medium)
        instance.textColor = .white
        instance.text = "切换房间背景"
        return instance
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 105.resize, height: 105.resize)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        instance.backgroundColor = .clear
        instance.dataSource = self
        instance.delegate = self
        instance.register(cellType: BackgroundImageCollectionViewCell.self)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        return instance
    }()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var confirmButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle("确定", for: .normal)
        instance.setTitleColor(.white, for: .normal)
        instance.addTarget(self, action: #selector(handleConfirmButtonClick), for: .touchUpInside)
        return instance
    }()
    private let imagelist: [String]
    private var selectedRow: Int?
    
    init(imagelist: [String], delegate: ChangeBackgroundImageProtocol) {
        self.imagelist = imagelist
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableClickingDismiss()
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(titleLabel)
        container.addSubview(collectionView)
        container.addSubview(confirmButton)

        container.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(314.resize)
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20.resize)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(24.resize)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().inset(25.resize)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.roundCorners(corners: [.topLeft, .topRight], radius: 22)
    }
    
    @objc private func handleConfirmButtonClick() {
        guard let row = selectedRow else {
            return
        }
        delegate?.didConfirmImage(urlSuffix: imagelist[row])
        dismiss(animated: true, completion: nil)
    }
}

extension ChangeBackgroundViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagelist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: BackgroundImageCollectionViewCell.self)
        cell.updateCell(item: imagelist[indexPath.row])
        return cell
    }
}

extension ChangeBackgroundViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRow = indexPath.row
    }
}
