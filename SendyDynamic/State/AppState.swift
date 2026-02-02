//
//  AppState.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/16.
//

import SwiftUI

@MainActor
class AppState: ObservableObject {
    
    @Published var platform: Platform = .iPad
    @Published var dynamicAPI: String = ""
    @Published var apiReady = false
    
    func showCurrentNetworkInfo() async -> Void {
        let utils = SendyUtils.shared
        
        if utils.isNetworkReachable() {
            print("Network is available")
        }
        
        if utils.isReachableViaWiFi() {
            print("WI-FI Env")
        }
        
        let isLocal = await utils.canReachLocalAPI(urlString: "http://192.168.2.141:8848", timeout: 1.5)
        
        if isLocal {
            print("Local Network Env")
            dynamicAPI = "http://192.168.2.141:8848/Dynamic/"
        } else {
            print("Not Local Network Env")
            dynamicAPI = "https://nas-web.yaohub.com/Dynamic/"
        }
        
        print("Dynamic API set to: \(dynamicAPI)")
        apiReady = true
    }
    
    enum Platform {
        case iPhone
        case iPad
    }
}
