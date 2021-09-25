//
//  OptionsViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/13.
//

import UIKit

struct ActionDependency {
    let action:(() -> Void)
    let name: String
}

struct PresentOptionDependency {
    let title: String
    let actions: [ActionDependency]
}

class OptionsViewController: UIViewController {
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        return instance
    }()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 16, weight: .medium)
        instance.textColor = .white
        instance.text = ""
        return instance
    }()
    private lazy var stackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .vertical
        instance.spacing = 15
        instance.alignment = .fill
        instance.distribution = .equalSpacing
        instance.layer.cornerRadius = 22
        return instance
    }()
    private var buttonlist = [UIButton]()
    
    private let dependency: PresentOptionDependency
    private lazy var tapGestureView = RCTapGestureView(self)
    
    init(dependency: PresentOptionDependency) {
        self.dependency = dependency
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = dependency.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    private func buildLayout() {
        view.addSubview(tapGestureView)
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(titleLabel)
        container.addSubview(stackView)
        
        tapGestureView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        container.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26.resize)
            make.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.bottom.equalToSuperview().inset(28)
            make.left.right.equalToSuperview().inset(28)
        }
        
        setupActionButtons()
    }
    
    func setupActionButtons() {
        for (index, element) in dependency.actions.enumerated() {
            let instance = UIButton()
            instance.backgroundColor = R.color.hexCDCDCD()?.withAlphaComponent(0.2)
            instance.titleLabel?.font = .systemFont(ofSize: 14)
            instance.setTitle(element.name, for: .normal)
            instance.tag = index
            instance.addTarget(self, action: #selector(handleButtonAction(sender:)), for: .touchUpInside)
            instance.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
            instance.layer.cornerRadius = 8
            instance.clipsToBounds = true
            instance.heightAnchor.constraint(equalToConstant: 44).isActive = true
            buttonlist.append(instance)
            stackView.addArrangedSubview(instance)
        }
    }
    
    @objc func handleButtonAction(sender: UIButton) {
        let action = dependency.actions[sender.tag]
        action.action()
    }
}
