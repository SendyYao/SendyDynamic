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
    @State private var hasLoadedData: Bool = false
    @State private var viewerImage: ViewerImage?
    
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
                            userNick: state.currentUser.nick,
                            userAvatar: state.currentUser.avatar,
                            postTime: post.dateTime,
                            content: post.textContent ?? "",
                            emojis: post.textContentEmojis ?? [],
                            imgList: post.imgList ?? [],
                            phoneInfo: post.phoneInfo ?? "",
                            likeUser: post.likedUser ?? "",
                            comments: post.comments ?? [],
                            viewerImage: $viewerImage
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
            .onChange(of: state.currentUser.index) {
                
                DispatchQueue.main.async {
                    proxy.scrollTo("top", anchor: .top)
                }
                
                Task {
                    await data.loadAnotherUserInfo(index: state.currentUser.index, apiUrl: state.dynamicAPI)
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
                // print("appState.dynamicAPI:", state.dynamicAPI)
                
                // 调用 postData.loadAttachInfo，确保在 dynamicAPI 更新后执行
                await data.loadAttachInfo(apiUrl: state.dynamicAPI)
            }
        }
        .fullScreenCover(item: $viewerImage) { item in
            ImageViewer(image: item.image)
                .presentationBackground(.clear)
        }
        .navigationTitle("动态列表")
    }
}
