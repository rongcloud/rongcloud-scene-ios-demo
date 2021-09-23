//
//  VoiceRoomDataSource.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/7.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa

final class RxTableViewSectionedReloadDataSourceWithReloadSignal<S: SectionModelType>: RxTableViewSectionedReloadDataSource<S> {
    private let relay = PublishRelay<Void>()
    var dataReloaded : Signal<Void> {
        return relay.asSignal()
    }
    
    override func tableView(_ tableView: UITableView, observedEvent: Event<[S]>) {
        super.tableView(tableView, observedEvent: observedEvent)
        relay.accept(())
    }
}
