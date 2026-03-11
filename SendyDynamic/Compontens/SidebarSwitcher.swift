//
//  SidebarSwitcher.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/12.
//

import Foundation
import SwiftUI

struct User {
    let Avatar: String
    let Label: String
}

struct SidebarSwitcher: View {
    
    @EnvironmentObject var appState: AppState
    @State private var isExpanded: Bool = false   // 默认折叠
    
    let onSwitched: (Int) -> Void
    
    var userList: [User] = [
        User(Avatar: "50", Label: "Yi"),
        User(Avatar: "yao", Label: "Yao")
    ]
    
    private let imageLoader = ImageLoaderOP.shared
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                HStack(spacing: 50) {
                    ForEach(Array(userList.enumerated()), id: \.offset) {index, user in
                        VStack(alignment: .center) {
                            if let avatar = imageLoader.loadLocalImage(named: user.Avatar) {
                                Image(uiImage: avatar)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                appState.currentUser.index == index ? Color.blue : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                    .onTapGesture {
                                        appState.currentUser = index == 0 ? .yi : .yao
                                        onSwitched(index)
                                    }
                            }
                            Text(user.Label)
                                .font(appState.currentUser.index == index ? .caption.bold() : .caption)
                                .foregroundColor(appState.currentUser.index == index ? .primary : .gray)
                        }
                    }
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color("RegularBackground"))
            },
            label: {
                Text("Switch User")
                    .font(.headline)
                    .foregroundColor(Color("ContrastTextForeground"))
            }
        )
        .padding()
        .background(Color("RegularBackground"))
    }
}
