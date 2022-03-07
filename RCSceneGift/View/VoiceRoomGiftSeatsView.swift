//
//  VoiceRoomGiftSeatsView.swift
//  RCE
//
//  Created by shaoshuai on 2021/5/25.
//

import UIKit
import SnapKit

public protocol VoiceRoomGiftSeatsViewDelegate: AnyObject {
    func giftSeatsView(_ view: VoiceRoomGiftSeatsView, didSelected seats: [VoiceRoomGiftSeat])
}

final public class VoiceRoomGiftSeatsView: UIView {
    weak var delegate: VoiceRoomGiftSeatsViewDelegate?
    
    private lazy var effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        return UIVisualEffectView(effect: blurEffect)
    }()
    
    private lazy var sendToLabel = UILabel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.register(cellType: VoiceRoomGiftSeatCell.self)
        instance.backgroundColor = .clear
        instance.delegate = self
        instance.dataSource = self
        instance.showsHorizontalScrollIndicator = false
        instance.allowsMultipleSelection = true
        return instance
    }()
    
    private lazy var selectAllButton = UIButton()
    private lazy var selectAllImage: UIImage = {
        let buttonSize = CGSize(width: 55.resize, height: 31.resize)
        return UIGraphicsImageRenderer(size: buttonSize)
            .image { renderer in
                let context = renderer.cgContext
                let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: buttonSize).insetBy(dx: 0.5, dy: 0.5), cornerRadius: 15.resize)
                context.addPath(path.cgPath)
                UIColor.white.setStroke()
                context.strokePath()
            }
    }()
    private lazy var cancelSelectAllImage: UIImage = {
        let buttonSize = CGSize(width: 55.resize, height: 31.resize)
        return UIGraphicsImageRenderer(size: buttonSize)
            .image { renderer in
                let context = renderer.cgContext
                let roundedRect = CGRect(origin: .zero, size: buttonSize).insetBy(dx: 0.5, dy: 0.5)
                let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: 15.resize)
                context.addPath(path.cgPath)
                context.clip()
                UIColor.white.withAlphaComponent(0.2).setFill()
                context.fill(CGRect(origin: .zero, size: buttonSize))
            }
    }()
    private lazy var selectAllTitle: NSAttributedString = {
        let sendTitle = "全选"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14.resize, weight: .medium)
        ]
        return NSAttributedString(string: sendTitle, attributes: attributes)
    }()
    private lazy var cancelSelectAllTitle: NSAttributedString = {
        let sendTitle = "取消"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14.resize, weight: .medium)
        ]
        return NSAttributedString(string: sendTitle, attributes: attributes)
    }()
    
    private lazy var lineView = UIView()
    
    private lazy var users = [VoiceRoomGiftSeat]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        addSubview(effectView)
        addSubview(sendToLabel)
        addSubview(collectionView)
        addSubview(selectAllButton)
        addSubview(lineView)
        
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sendToLabel.text = "送给"
        sendToLabel.font = UIFont.systemFont(ofSize: 14)
        sendToLabel.textColor = .white
        sendToLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(snp.left).offset(26.resize)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(52.resize)
            make.right.equalToSuperview().inset(79.resize)
        }
        
        selectAllButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(12.resize)
            make.width.equalTo(55.resize)
            make.height.equalTo(31.resize)
        }
        
        selectAllButton.addTarget(self, action: #selector(didButtonClicked), for: .touchUpInside)
        selectAllButton.setAttributedTitle(selectAllTitle, for: .normal)
        selectAllButton.setBackgroundImage(selectAllImage, for: .normal)
        
        lineView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        lineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(_ users: [VoiceRoomGiftSeat]) {
        self.users = users
        collectionView.reloadData()
        updateButton()
        selectAllButton.isHidden = users.count == 1
    }
    
    private func updateButton() {
        let hasUnselected = users.contains(where: { $0.isSelected == false })
        if hasUnselected {
            selectAllButton.setBackgroundImage(selectAllImage, for: .normal)
            selectAllButton.setAttributedTitle(selectAllTitle, for: .normal)
        } else {
            selectAllButton.setBackgroundImage(cancelSelectAllImage, for: .normal)
            selectAllButton.setAttributedTitle(cancelSelectAllTitle, for: .normal)
        }
        let selectedItems = users.filter { $0.isSelected }
        delegate?.giftSeatsView(self, didSelected: selectedItems)
    }
    
    @objc private func didButtonClicked() {
        let hasUnselected = users.contains(where: { $0.isSelected == false })
        (0..<users.count).forEach { index in
            users[index].setSelected(hasUnselected)
        }
        collectionView.reloadData()
        updateButton()
    }
}

extension VoiceRoomGiftSeatsView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(for: indexPath, cellType: VoiceRoomGiftSeatCell.self)
            .update(users[indexPath.row])
    }
}

extension VoiceRoomGiftSeatsView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard users.count > 1 else { return }
        users[indexPath.item].setSelected(!users[indexPath.item].isSelected)
        collectionView.reloadItems(at: [indexPath])
        updateButton()
    }
}

extension VoiceRoomGiftSeatsView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        return CGSize(width: height, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
