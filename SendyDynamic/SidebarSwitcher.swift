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
    
    @State private var isExpanded: Bool = true   // 默认展开
    @State private var selectedIndex: Int = 0   // 默认高亮第一个
    
    let onSwitched: (Int) -> Void
    
    var userList: [User] = [
        User(Avatar: "50", Label: "Yi"),
        User(Avatar: "yao", Label: "Yao")
    ]
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                HStack(spacing: 50) {
                    ForEach(Array(userList.enumerated()), id: \.offset) {index, user in
                        VStack(alignment: .center) {
                            Image(uiImage: UIImage(imageLiteralResourceName: user.Avatar))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedIndex == index ? Color.blue : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                                .onTapGesture {
                                    selectedIndex = index          // 🔥 切换高亮
                                    onSwitched(index)
                                }
                            Text(user.Label)
                                .font(selectedIndex == index ? .caption.bold() : .caption)
                                .foregroundColor(selectedIndex == index ? .primary : .gray)
                        }
                    }
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(UIColor.rgb(38, 38, 38)))
            },
            label: {
                Text("Switch User")
                    .font(.headline)
                    .foregroundColor(Color.white)
            }
        )
        .padding()
        .background(Color(UIColor.rgb(38, 38, 38)))
    }
}
