//
//  PadContentView.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/23.
//


import SwiftUI

struct PadContentView: View {
    
    @EnvironmentObject var appState: AppState
    @StateObject private var postData = DynamicPostData()
    @State private var scrollTarget: UUID?
    
    var body: some View {
        NavigationView {
            ToolbarContentView(
                posts: postData.infoList,
                onSelectPostID: { id in
                    // print("ContentView 收到 onSelect，设置 scrollTarget = \(id)")
                    scrollTarget = id
                },
                onSwitchedIndex: { index in
                    print("Taped index: \(index); Ready to switch, now dynamicAPI: \(appState.dynamicAPI)")
                    appState.currentUser = index == 0 ? .yi : .yao
                }
            )
            DynamicList(data: postData, scrollTarget: $scrollTarget)
        }
        .navigationBarTitle("Yi's QQ Dynamic", displayMode: .inline)
    }
}
