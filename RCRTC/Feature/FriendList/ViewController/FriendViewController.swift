//
//  FriendViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/2.
//

import UIKit

final class FriendViewController: UIViewController {

    private lazy var titleView = FriendTitleView()
    private var titleViewObserver: NSKeyValueObservation?
    private var fansViewController: FriendListViewController?
    private var focusViewController: FriendListViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.965, green: 0.973, blue: 0.976, alpha: 1)
        setupConstriants()
        
        titleViewObserver = titleView
            .observe(\.currentIndex, options: .new) { [weak self] _, change in
                guard let index = change.newValue else { return }
                self?.itemSelected(index)
            }
        titleView.currentIndex = 0
    }
    
    deinit {
        titleViewObserver?.invalidate()
        titleViewObserver = nil
    }
    
    private func createListView(_ type: FriendType) -> FriendListViewController {
        let instance = FriendListViewController(type)
        view.addSubview(instance.view)
        instance.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(titleView.snp.bottom)
        }
        addChild(instance)
        return instance
    }
    
    private func itemSelected(_ index: Int) {
        fansViewController?.view.isHidden = index == 1
        focusViewController?.view.isHidden = index == 0
        if index == 0 {
            if fansViewController == nil {
                fansViewController = createListView(.fans)
            } else {
                fansViewController?.refreshList()
            }
        }
        if index == 1 {
            if focusViewController == nil {
                focusViewController = createListView(.follow)
            } else {
                focusViewController?.refreshList()
            }
        }
    }
}

extension FriendViewController {
    private func setupConstriants() {
        view.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(52)
        }
    }
}
