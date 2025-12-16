//
//  SendyDynamicApp.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/6.
//

import SwiftUI

@main
struct SendyDynamicApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    await appState.showCurrentNetworkInfo()
                }
        }
    }
}
