//
//  ContentView.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/6.
//

import SwiftUI

struct ToolbarContentView: View {
    
    @State private var hitokoto: String = "加载中…"
    
    let posts: [DynamicInfo]
    let onSelectPostID: (UUID) -> Void
    let onSwitchedIndex: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // AppBar
            VStack(spacing: 5) {
                Text("Yi's QQ Dynamic")
                    .font(.headline)
                    .foregroundColor(Color("SidebarTitleText"))
                
                Text(hitokoto)
                    .font(.subheadline)
                    .foregroundColor(Color("SidebarSubtitleText"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color("RegularBackground"))
            .task {
                hitokoto = await AdditionalContent.shared.fetchHitokoto()
            }
            
            // MARK: Switch QQ Dynamic User
            
            SidebarSwitcher(
                onSwitched: onSwitchedIndex
            )
            
            Divider()
            
            // Year-Month List View
            SidebarList(
                posts: posts,
                onSelect: onSelectPostID
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: EmptyView(), trailing: EmptyView())
    }
}

enum CurrentUser {
    case yi
    case yao
    
    var nick: String {
        self == .yi ? "弈" : "垚"
    }
    
    var avatar: String {
        self == .yi ? "50" : "yao"
    }
}

struct ContentView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.horizontalSizeClass) private var hSize
    
    var body: some View {
        Group {
            if appState.platform == .iPad {
                PadContentView()
            } else {
                PhoneContentView()
            }
        }
        .onAppear {
            updatePlatform()
        }
        .onChange(of: hSize) {
            updatePlatform()
        }
    }
    
    private func updatePlatform() {
        if hSize == .regular {
            appState.platform = .iPad
            print("iPad Platform")
        } else {
            appState.platform = .iPhone
            print("iPhone Platform")
        }
    }
}
