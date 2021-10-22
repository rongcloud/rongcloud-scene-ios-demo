//
//  RCLiveModuleViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/10.
//

import UIKit

class RCLiveModuleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        m_viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        m_viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        m_viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        m_viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        m_viewDidDisappear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        m_viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        m_viewDidLayoutSubviews()
    }
    
}

extension RCLiveModuleViewController {
    dynamic func m_viewDidLoad() {}
    dynamic func m_viewWillAppear(_ animated: Bool) {}
    dynamic func m_viewDidAppear(_ animated: Bool) {}
    dynamic func m_viewWillDisappear(_ animated: Bool) {}
    dynamic func m_viewDidDisappear(_ animated: Bool) {}
    dynamic func m_viewWillLayoutSubviews() {}
    dynamic func m_viewDidLayoutSubviews() {}
}
