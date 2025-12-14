//
//  ContentView.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/6.
//

import SwiftUI

struct HitokotoResponse: Codable {
    let code: Int
    let data: HitokotoData
    let msg: String
}

struct HitokotoData: Codable {
    let hitokoto: String
    let from: String
}

struct ToolbarContentView: View {
    
    @State private var hitokoto: String = "加载中…"
    @State private var hasFetchedHitokoto: Bool = false
    
    let posts: [DynamicInfo]
    let onSelectPostID: (UUID) -> Void
    let onSwitchedIndex: (Int) -> Void
    
    // MARK: - 使用iTab API获取每日一言
    func fetchHitokoto() {
        guard !hasFetchedHitokoto else { return }
        guard let apiUrl = URL(string: "https://itab-api.yaonas.space/yiyan/random") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.timeoutInterval = 30
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("请求错误: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No returned data")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("返回原始的JSON数据： \(jsonString)")
            }
            
            do {
                let json = try JSONDecoder().decode(HitokotoResponse.self, from: data)
                DispatchQueue.main.async {
                    self.hitokoto = json.data.hitokoto
                    self.hasFetchedHitokoto = true
                }
            } catch {
                print(apiUrl)
                print("解析错误: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // AppBar
            VStack(spacing: 5) {
                Text("Yi's QQ Dynamic")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text(hitokoto)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color(UIColor.rgb(38, 38, 38)))
            .onAppear{
                fetchHitokoto()
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
                    print("Taped index: \(index); Ready to switch")
                    currentUser = index == 0 ? .yi : .yao
                    userIndex = index
                }
            )
            // SplitView
            ScrollViewReader { proxy in
                ScrollView {
                    // Top 锚点
                    VStack {
                        Color.clear
                            .frame(height: 0)
                            .id("top")
                    }
                    
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(postData.infoList) { post in
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
                    .padding()
                }
                .onChange(of: scrollTarget) { newID in
                    guard let target = newID else {return}
                    // print("ScrollViewReader 收到 scrollTarget: \(target)")
                    
                    DispatchQueue.main.async {
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.55)) {
                            proxy.scrollTo(target, anchor: .top)
                        }
                    }
                }
                .onChange(of: userIndex) { newUserIndex in
                    
                    DispatchQueue.main.async {
                        proxy.scrollTo("top", anchor: .top)
                    }
                    
                    Task {
                        await postData.loadAnotherUserInfo(index: userIndex)
                    }
                }
                .onAppear {
                    postData.loadJson()
                    
                    // Wait the first frame render complete
                    DispatchQueue.main.async {
                        Task {
                            await postData.loadAttachInfo()
                        }
                    }
                }
            }
            .navigationTitle("动态列表")
        }
        .navigationBarTitle("Yi's QQ Dynamic", displayMode: .inline)
    }
}
