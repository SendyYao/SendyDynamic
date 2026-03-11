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
    @State private var isSignleLineHitoko = true
    
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
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(isSignleLineHitoko ? .center : .leading)
                    .padding(.horizontal, 10)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    let width = hitokoto
                                        .size(withAttributes: [
                                            .font: UIFont.preferredFont(forTextStyle: .subheadline)
                                        ]).width
                                    isSignleLineHitoko = width <= geo.size.width + 1
                                }
                        }
                    )
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
