//
//  PhoneContentView.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/23.
//

import SwiftUI

struct PhoneAppBar: View {
    
    @State private var hitokoto: String = "加载中… "
    
    let onSidebarTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onSidebarTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Spacer()
            
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
            .task {
                hitokoto = await AdditionalContent.shared.fetchHitokoto()
            }
            
            Spacer()
            
            Color.clear
                .frame(width: 24)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(.ultraThinMaterial)
    }
}

enum PhoneRoute: Hashable {
    case sidebar
}

struct PhoneContentView: View {
    
    @EnvironmentObject var appState: AppState
    @StateObject private var postData = DynamicPostData()
    @State private var scrollTarget: UUID?
    @State private var userIndex: Int = 0
    @State private var currentUser: CurrentUser = .yi
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                
                PhoneAppBar(
                    onSidebarTap: {
                        path.append(PhoneRoute.sidebar)
                    }
                )
                
                Divider()
                
                DynamicList(
                    data: postData,
                    scrollTarget: $scrollTarget,
                    userIndex: $userIndex,
                    currentUser: $currentUser
                )
                .navigationBarHidden(true)
                .navigationDestination(for: PhoneRoute.self) { route in
                    switch route {
                    case .sidebar:
                        SidebarPage(
                            posts: postData.infoList,
                            onSelectPostID: { id in
                                scrollTarget = id
                            },
                            onSwitchedIndex: { index in
                                print("Taped index: \(index); Ready to switch, now dynamicAPI: \(appState.dynamicAPI)")
                                currentUser = index == 0 ? .yi : .yao
                                userIndex = index
                            }
                        )
                    }
                }
            }
        }
    }
}

struct SidebarPage: View {
    
    let posts: [DynamicInfo]
    let onSelectPostID: (UUID) -> Void
    let onSwitchedIndex: (Int) -> Void
    @State private var hasDismissed = false
    
    @Environment(\.dismiss) private var dismiss
    
    func dismissOnce() {
        guard !hasDismissed else { return }
        hasDismissed = true
        dismiss()
    }
    
    var body: some View {
        VStack(spacing: 5) {
            // MARK: Switch QQ Dynamic User
            
            SidebarSwitcher { index in
                onSwitchedIndex(index)
                dismissOnce()
            }
            
            Divider()
            
            SidebarList(
                posts: posts
            ) { postID in
                onSelectPostID(postID)
                dismissOnce()
            }
        }
    }
}
