//
//  SettingViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

import UIKit
import SVProgressHUD

class SettingViewController: UIViewController {
    let items = SettingItem.allCases
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.register(cellType: SettingTableViewCell.self)
        instance.tableFooterView = UIView()
        instance.delegate = self
        instance.dataSource = self
        return instance
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func logout() {
        UserDefaults.standard.clearLoginStatus()
        RCCoreClient.shared().disconnect(true)
        dismiss(animated: true) {
            NotificationNameLogout.post()
        }
    }
    
    private func showResignAlert() {
        let vc = UIAlertController(title: "注销用户？", message: "注销用户会导致您创建的账户和相关信息从服务器彻底移除，是否确认注销用户？", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.resign()
        }))
        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            
        }))
        present(vc, animated: true, completion: nil)
    }
    
    private func resign() {
        networkProvider.request(.resign) { result in
            switch result {
            case .success(_):
                SVProgressHUD.showSuccess(withStatus: "注销成功")
                self.logout()
            case .failure(_):
                SVProgressHUD.showError(withStatus: "注销失败，请重试")
            }
        }
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        switch item {
        case .logout:
            logout()
        case .registerTerm:
            let path = "https://cdn.ronghub.com/term_of_service_zh.html"
            WebViewController.show(self, title: item.title, path: path)
        case .privacyTerm:
            let path = "https://cdn.ronghub.com/Privacy_agreement_zh.html"
            WebViewController.show(self, title: item.title, path: path)
        case .logoff:
            showResignAlert()
        }
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SettingTableViewCell.self)
        cell.updateCell(item: items[indexPath.row])
        return cell
    }
}
