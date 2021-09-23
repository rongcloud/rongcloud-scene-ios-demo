//
//  MJRefresh+Reactive.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/28.
//

import Foundation
import MJRefresh
import RxCocoa
import RxSwift

class RCRefreshHeader: UIRefreshControl {
  override init() {
    super.init(frame: .zero)
    tintColor = .black
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class RCLoadMoreFooter: MJRefreshBackNormalFooter {
    init() {
        super.init(frame: .zero)
        loadingView?.style = .medium
        arrowView?.image = nil
        stateLabel?.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UITableView {
    var mjHeader: MJRefreshHeader {
        guard let header = mj_header else {
            fatalError("doesn't init refresh header")
        }
        return header
    }
}

extension UICollectionView {
    var mjHeader: MJRefreshHeader {
        guard let header = mj_header else {
            fatalError("doesn't init refresh header")
        }
        return header
    }
}

extension UITableView {
    var mjFooter: MJRefreshFooter {
        guard let footer = mj_footer else {
            fatalError("doesn't init refresh footer")
        }
        return footer
    }
}

extension UICollectionView {
    var mjFooter: MJRefreshFooter {
        guard let footer = mj_footer else {
            fatalError("doesn't init refresh footer")
        }
        return footer
    }
}

class Target: NSObject, Disposable {
    private var retainSelf: Target?
    override init() {
        super.init()
        self.retainSelf = self
    }
    func dispose() {
        self.retainSelf = nil
    }
}

// 自定义target，用来接收MJRefresh的刷新事件
private final
class MJRefreshTarget<Component: MJRefreshComponent>: Target {
    weak var component: Component?
    let refreshingBlock: MJRefreshComponentAction
    
    init(_ component: Component , refreshingBlock: @escaping MJRefreshComponentAction) {
        self.refreshingBlock = refreshingBlock
        self.component = component
        super.init()
        component.setRefreshingTarget(self, refreshingAction: #selector(onRefeshing))
    }
    
    @objc func onRefeshing() {
        refreshingBlock()
    }
    
    override func dispose() {
        super.dispose()
        self.component?.refreshingBlock = nil
    }
}

// 扩展Rx 给MJRefreshComponent 添加refresh的rx扩展
extension Reactive where Base: MJRefreshComponent {
    var refresh: ControlProperty<MJRefreshState> {
        let source: Observable<MJRefreshState> = Observable.create { [weak component = self.base] observer  in
            MainScheduler.ensureExecutingOnScheduler()
            guard let component = component else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            // 发出初始值MJRefreshStateIdle
            observer.on(.next(component.state))
            
            let observer = MJRefreshTarget(component) {
                //  在用户下拉时 发出MJRefreshComponent 的状态
                observer.on(.next(component.state))
            }
            return observer
        }.take(until: deallocated)
        
        // 在setter里设置MJRefreshComponent 的状态
        // 当一个Observable<MJRefreshState>发出，假如这个state是MJRefreshStateIdle，那么MJRefreshComponent 就会结束刷新
        let bindingObserver = Binder<MJRefreshState>(self.base) { (component, state) in
            component.state = state
        }
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}

