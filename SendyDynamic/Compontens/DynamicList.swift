//
//  DynamicScrollViewReader.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/23.
//

import SwiftUI

struct DynamicList: View {
    
    @EnvironmentObject var state: AppState
    @StateObject var data: DynamicPostData
    @Binding var scrollTarget: UUID?
    @Binding var userIndex: Int
    @Binding var currentUser: CurrentUser
    @State private var hasLoadedData: Bool = false
    
    var body: some View {
        // SplitView
        ScrollViewReader { proxy in
            ScrollView {
                // Top 锚点
                VStack {
                    Color.clear
                        .frame(height: 0)
                        .id("top")
                }
                
                LazyVStack(spacing: 12) {
                    ForEach(data.infoList) { post in
                        DynamicPostItem(
                            id: post.id,
                            userNick: currentUser.nick,
                            userAvatar: currentUser.avatar,
                            postTime: post.dateTime,
                            content: post.textContent ?? "",
                            emojis: post.textContentEmojis ?? [],
                            imgList: post.imgList ?? [],
                            phoneInfo: post.phoneInfo ?? "",
                            likeUser: post.likedUser ?? "",
                            comments: post.comments ?? []
                        )
                        .id(post.id)
                    }
                }
                .padding(.horizontal, 12)
            }
            .onChange(of: scrollTarget) {
                guard let target = scrollTarget else {return}
                // print("ScrollViewReader 收到 scrollTarget: \(target)")
                
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.55)) {
                        proxy.scrollTo(target, anchor: .top)
                    }
                }
            }
            .onChange(of: userIndex) {
                
                DispatchQueue.main.async {
                    proxy.scrollTo("top", anchor: .top)
                }
                
                Task {
                    await data.loadAnotherUserInfo(index: userIndex, apiUrl: state.dynamicAPI)
                }
            }
            .onAppear {
                if !hasLoadedData {
                    data.loadJson()
                    hasLoadedData = true
                }
            }
            .task(id: state.apiReady) {
                guard state.apiReady else { return }
                print("appState.dynamicAPI:", state.dynamicAPI)
                
                // 调用 postData.loadAttachInfo，确保在 dynamicAPI 更新后执行
                await data.loadAttachInfo(apiUrl: state.dynamicAPI)
            }
        }
        .navigationTitle("动态列表")
    }
}
