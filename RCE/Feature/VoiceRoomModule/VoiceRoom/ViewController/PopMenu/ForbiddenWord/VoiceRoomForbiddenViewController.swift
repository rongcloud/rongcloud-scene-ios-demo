//
//  VoiceRoomForbiddenViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/2.
//

import UIKit
import SVProgressHUD

protocol VoiceRoomForbiddenDelegate: AnyObject {
    func forbiddenListDidChange()
}

enum ForbiddenCellType {
    case append
    case word(VoiceRoomForbiddenWord)
}

class VoiceRoomForbiddenViewController: UIViewController {
    private let roomId: String
    private var list = [ForbiddenCellType]()
    private lazy var collectionView: UICollectionView = {
        let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.itemSize = CGSize(width: 100, height: 30)
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.register(cellType: ForbiddenWordCollectionViewCell.self)
        instance.register(cellType: AppendForbiddenCollectionViewCell.self)
        instance.delegate = self
        instance.dataSource = self
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var containerView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17)
        instance.textColor = .white
        instance.text = "屏蔽词"
        return instance
    }()
    private lazy var effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        return UIVisualEffectView(effect: blurEffect)
    }()
    private lazy var separatorline: UIView = {
        let instance = UIView()
        instance.backgroundColor = .white.withAlphaComponent(0.2)
        return instance
    }()
    private lazy var forbiddenTitleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        instance.text = "设置屏蔽词 (0/10)"
        return instance
    }()
    private lazy var forbiddenDescLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12)
        instance.textColor = .white.withAlphaComponent(0.65)
        instance.text = "包含屏蔽词的发言将不会被其他用户看到"
        return instance
    }()
    
    init(roomId: String) {
        self.roomId = roomId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        fetchForbiddenList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: 22)
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        view.addSubview(containerView)
        containerView.addSubview(effectView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(separatorline)
        containerView.addSubview(forbiddenTitleLabel)
        containerView.addSubview(forbiddenDescLabel)
        containerView.addSubview(collectionView)
        
        containerView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
        }
        
        separatorline.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        forbiddenTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(separatorline.snp.bottom).offset(16)
        }
        
        forbiddenDescLabel.snp.makeConstraints { make in
            make.left.equalTo(forbiddenTitleLabel)
            make.top.equalTo(forbiddenTitleLabel.snp.bottom).offset(4)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(forbiddenDescLabel.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func showAppendAlert() {
        let alert = UIAlertController(title: "添加屏蔽词", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.addTarget(self,
                                action: #selector(self.handleTextFieldEditing(_:)),
                                for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak alert] _ in
            guard let text = alert?.textFields?.first?.text, !text.isEmpty else {
                SVProgressHUD.showError(withStatus: "屏蔽词不能为空")
                return
            }
            self.appendForbidden(name: text)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showDeleteAlert(item: VoiceRoomForbiddenWord) {
        let alert = UIAlertController(title: "是否删除屏蔽词", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.deleteForbidden(item: item)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleTextFieldEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        guard textField.markedTextRange == nil else {
            return
        }
        textField.text = String(text.prefix(10))
    }
}

extension VoiceRoomForbiddenViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = list[indexPath.row]
        switch item {
        case .append:
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: AppendForbiddenCollectionViewCell.self)
            return cell
        case .word:
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ForbiddenWordCollectionViewCell.self)
            cell.updateCell(item: list[indexPath.row])
            return cell
        }
    }
}

extension VoiceRoomForbiddenViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = list[indexPath.row]
        switch item {
        case .append:
            guard list.count < 11 else {
                SVProgressHUD.showError(withStatus: "最多只能添加10个屏蔽词")
                return
            }
            showAppendAlert()
        case let .word(word):
            showDeleteAlert(item: word)
        }
    }
}

extension VoiceRoomForbiddenViewController {
    func fetchForbiddenList() {
        networkProvider.request(RCNetworkAPI.forbiddenList(roomId: roomId)) { result in
            switch result {
            case .success(let response):
                let data = response.data
                let responseModel = try? JSONDecoder().decode(VoiceRoomForbiddenResponse.self, from: data)
                let wordlist = responseModel?.data ?? []
                self.list = [.append] + wordlist.map {
                    ForbiddenCellType.word($0)
                }
                self.forbiddenTitleLabel.text = "设置屏蔽词 (\(wordlist.count)/10)"
                SceneRoomManager.shared.forbiddenWordlist = wordlist.map(\.name)
                self.collectionView.reloadData()
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    func appendForbidden(name: String) {
        networkProvider.request(RCNetworkAPI.appendForbidden(roomId: roomId, name: name)) { result in
            switch result {
            case .success(let response):
                let data = response.data
                guard let responseModel = try? JSONDecoder().decode(AppResponse.self, from: data), responseModel.validate() else {
                    SVProgressHUD.showError(withStatus: "添加失败")
                    return
                }
                self.fetchForbiddenList()
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    func deleteForbidden(item: VoiceRoomForbiddenWord) {
        networkProvider.request(RCNetworkAPI.deleteForbidden(id: "\(item.id)")) { result in
            switch result {
            case .success(let response):
                let data = response.data
                guard let responseModel = try? JSONDecoder().decode(AppResponse.self, from: data), responseModel.validate() else {
                    SVProgressHUD.showError(withStatus: "删除失败")
                    return
                }
                self.fetchForbiddenList()
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}
