//
//  RCSceneRoomSettingViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/6.
//

import UIKit
import RCSceneFoundation

public class RCSceneRoomSettingViewController: UIViewController {
    private weak var delegate: RCSceneRoomSettingProtocol?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = RCSceneRoomSettingCell.autoSize()
        layout.minimumInteritemSpacing = 30.resize
        layout.minimumLineSpacing = 28.resize
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.contentInset = UIEdgeInsets(top: 40.resize, left: 30.resize, bottom: 40.resize, right: 30.resize)
        instance.dataSource = self
        instance.delegate = self
        instance.backgroundColor = .clear
        instance.register(cellType: RCSceneRoomSettingCell.self)
        instance.isScrollEnabled = false
        return instance
    }()
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var arrowImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.fold()
        return instance
    }()
    private let items: [Item]
    
    public init(items: [Item], delegate: RCSceneRoomSettingProtocol?) {
        self.items = items
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        Adaptor.set(design: CGSize(width: 375, height: 667))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.roundCorners(corners: [.topLeft, .topRight], radius: 21)
    }
    
    deinit {
        print("Setting Controller deinit")
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(collectionView)
        container.addSubview(arrowImageView)
        
        container.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(345.resize)
        }
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        arrowImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8.resize)
        }
    }
}

extension RCSceneRoomSettingViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: RCSceneRoomSettingCell.self)
        cell.updateCell(item: items[indexPath.row])
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
}

extension RCSceneRoomSettingViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            fatalError("代理未设置")
        }
        
        let item = items[indexPath.row]
        
        if delegate.eventWillTrigger(item) {
            return dismiss(animated: true)
        }
        
        switch item {
        case .roomLock(let lock):
            if lock {
                let controller = PasswordViewController(delegate)
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .overFullScreen
                let presenter = presentingViewController
                dismiss(animated: true) {
                    presenter?.present(controller, animated: true)
                }
            } else {
                dismiss(animated: true) {
                    delegate.eventDidTrigger(item, extra: nil)
                }
            }
        case .roomName(let title):
            let controller = UIAlertController(title: "修改房间名称", message: nil, preferredStyle: .alert)
            let sureAction = UIAlertAction(title: "确定", style: .default) { _ in
                guard let text = controller.textFields?.first?.text else {
                    return
                }
                delegate.eventDidTrigger(.roomName(text), extra: nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            controller.addTextField { textField in
                textField.placeholder = title
                textField.addTarget(controller,
                                    action: #selector(controller.handleRoomNameTextEditing(_:)),
                                    for: .editingChanged)
            }
            controller.addAction(cancelAction)
            controller.addAction(sureAction)
            let presenter = presentingViewController
            dismiss(animated: true) {
                presenter?.present(controller, animated: true)
            }
        case .roomNotice(let notice):
            let controller = NoticeViewController(true, notice: notice, delegate: delegate)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .overFullScreen
            let presenter = presentingViewController
            dismiss(animated: true) {
                presenter?.present(controller, animated: true)
            }
        case .forbidden(let words):
            let controller = ForbiddenViewController(words, delegate: delegate)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .overFullScreen
            let presenter = presentingViewController
            dismiss(animated: true) {
                presenter?.present(controller, animated: true)
            }
        default:
            dismiss(animated: true) {
                delegate.eventDidTrigger(item, extra: nil)
            }
        }
    }
}

extension UIAlertController {
    @objc func handleRoomNameTextEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        guard textField.markedTextRange == nil else {
            return
        }
        textField.text = String(text.prefix(10))
    }
}
