//
//  DiscoverViewController.swift
//  RCE
//
//  Created by shaoshuai on 2022/2/22.
//

import WebKit
import SnapKit

class DiscoverViewController: UIViewController {
    
    private lazy var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexString: "0xE6F0F3")
        
        navigationItem.title = "发现"
        navigationController?.navigationBar.isTranslucent = false
        
        webView.backgroundColor = .clear
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if let url = URL(string: "https://m.rongcloud.cn/activity/rtc20") {
            webView.load(URLRequest(url: url))
        }
    }
}
