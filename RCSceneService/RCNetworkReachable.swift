//
//  RCNetworkReach.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/9.
//

import Reachability
import RCSceneFoundation

fileprivate var reachability: Reachability?

public class RCNetworkReach {
    public static func active() {
        do {
            let hostName = Environment.current.url.host ?? ""
            reachability = try Reachability(hostname: hostName)
            try reachability!.startNotifier()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    public static func deactive() {
        reachability?.stopNotifier()
        reachability = nil
    }
}
