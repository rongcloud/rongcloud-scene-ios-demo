//
//  RCNetworkReach.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/9.
//

import Reachability

fileprivate var reachability: Reachability?

class RCNetworkReach {
    static func active() {
        do {
            reachability = try Reachability()
            try reachability!.startNotifier()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    static func deactive() {
        reachability?.stopNotifier()
        reachability = nil
    }
}
