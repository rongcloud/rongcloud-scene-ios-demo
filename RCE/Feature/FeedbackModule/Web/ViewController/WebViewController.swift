//
//  WebViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/7/22.
//

import UIKit
import WebKit
import SVProgressHUD

final class WebViewController: UIViewController {
    
    private lazy var webView = WKWebView()
    private lazy var tapView = RCTapGestureView(self)
    
    private(set) lazy var backButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.back_indicator_image(), for: .normal)
        instance.addTarget(self, action: #selector(back), for: .touchUpInside)
        return instance
    }()
    
    private let urlString: String
    private let titleString: String
    init(_ urlString: String, title: String) {
        self.urlString = urlString
        self.titleString = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = titleString
        view.backgroundColor = .white
        view.addSubview(tapView)
        view.addSubview(webView)
        tapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if urlString.hasPrefix("http"), let url = URL(string: urlString) {
            let requst = URLRequest(url: url)
            webView.load(requst)
        } else {
            let url = URL(fileURLWithPath: urlString)
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    @objc private func back() {
        dismiss(animated: true, completion: nil)
    }
}

extension WebViewController {
    static func show(_ controller: UIViewController, title: String, path: String) {
        let web = WebViewController(path, title: title)
        let nav = UINavigationController(rootViewController: web)
        nav.modalTransitionStyle = .coverVertical
        nav.modalPresentationStyle = .overFullScreen
        controller.present(nav, animated: true, completion: nil)
    }
}
