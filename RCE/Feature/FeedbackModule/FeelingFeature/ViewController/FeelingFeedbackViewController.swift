//
//  FeelingFeedbackViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/7/13.
//

import UIKit
import RxSwift
import SVProgressHUD

class FeelingFeedbackViewController: UIViewController {
    private var disposeBag = DisposeBag()
    private let feedbackView = FeedbackView(frame: .zero)
    private let feedbackReasonView = FeedbackReasonView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    private func buildLayout() {
        feedbackView.delegate = self
        feedbackReasonView.delegate = self
        feedbackReasonView.alpha = 0
        view.backgroundColor = UIColor(hexString: "03062F").withAlphaComponent(0.4)
        view.addSubview(feedbackView)
        view.addSubview(feedbackReasonView)
        feedbackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.center.equalToSuperview()
        }
        
        feedbackReasonView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.center.equalToSuperview()
        }
    }
    
    private func showReasonView() {
        UIView.animate(withDuration: 0.3) {
            self.feedbackView.alpha = 0
            self.feedbackReasonView.alpha = 1
        } completion: { _ in
        }
    }
    
    private func upload(reason: String?, isGood: Bool) {
        networkProvider.rx.request(.feedback(isGoodFeedback: isGood, reason: reason)).filterSuccessfulStatusCodes().asObservable().map(AppResponse.self).subscribe(onNext: {
            [weak self] value in
            guard let self = self else { return }
            if value.validate() {
                SVProgressHUD.showSuccess(withStatus: "提交成功")
                self.onLickEventUpdated()
            } else {
                SVProgressHUD.showSuccess(withStatus: "提交失败，请重试")
            }
            UserDefaults.standard.feedbackCompletion()
        }).disposed(by: disposeBag)
    }
    
    private func onLickEventUpdated() {
        let controller = presentingViewController
        dismiss(animated: true) {
            controller?.currentVisableViewController()?.navigator(.promotion)
        }
    }
}

extension FeelingFeedbackViewController: FeedbackViewProtocol {
    func cancelDidClick() {
        UserDefaults.standard.clearCountDown()
        dismiss(animated: true, completion: nil)
    }
    
    func likeDidClick() {
        upload(reason: nil, isGood: true)
    }
    
    func notLikeDidClick() {
        showReasonView()
    }
}

extension FeelingFeedbackViewController: FeedbackReasonViewProtocol {
    func reasonsDidSelected(reason: String) {
        upload(reason: reason, isGood: false)
    }
    
    func canelDidClick() {
        dismiss(animated: true, completion: nil)
    }
}
