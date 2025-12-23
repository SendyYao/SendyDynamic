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
    @State private var userIndex: Int = 0
    @State private var currentUser: CurrentUser = .yi
    
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
                    currentUser = index == 0 ? .yi : .yao
                    userIndex = index
                }
            )
            DynamicList(data: postData, scrollTarget: $scrollTarget, userIndex: $userIndex, currentUser: $currentUser)
        }
        .navigationBarTitle("Yi's QQ Dynamic", displayMode: .inline)
    }
}
