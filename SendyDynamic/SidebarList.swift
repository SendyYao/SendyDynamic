//
//  SidebarList.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/7.
//

import Foundation
import SwiftUI

struct MonthItem: Identifiable {
    let id: UUID   // 对应 DynamicInfo.id
    let month: Int
}

struct YearSection: Identifiable {
    let id = UUID()
    let year: Int
    let months: [MonthItem]
}

struct MonthEntry {
    let year: Int
    let month: Int
    let postID: UUID
}

struct SidebarList: View {
    
    let posts: [DynamicInfo]
    let onSelect: (UUID) -> Void
    
    @State private var expandedYears: Set<Int> = []
    
    private var sections: [YearSection] {
        buildYearSections(from: posts)
    }
    
    func buildYearString(from year: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter.string(from: NSNumber(value: year)) ?? "\(year)"
    }
    
    func onMonthSelected(monthItem: MonthItem) {
        print("👉 点击的 Month ID:", monthItem.id)

        if let post = posts.first(where: { $0.id == monthItem.id }) {
            print("🎯 找到对应的贴文：\(post.dateTime) - \(String(describing: post.textContent))")
        } else {
            print("❌ 没有找到对应 ID 的贴文！")
        }
    }

    var body: some View {
        
        List {
            ForEach(sections) { sec in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedYears.contains(sec.year) },
                        set: { newValue in
                            if newValue {
                                expandedYears.insert(sec.year)
                            } else {
                                expandedYears.remove(sec.year)
                            }
                        }
                    ),
                    content: {
                        ForEach(sec.months) { monthItem in
                            Button {
                                onSelect(monthItem.id)
                            } label: {
                                Text("\(monthItem.month) 月")
                                    .padding(.vertical, 4)
                            }
                        }
                    },
                    label: {
                        let yearString = buildYearString(from: sec.year)
                        Text("\(yearString) 年")
                            .font(.headline)
                    }
                )
            }
        }
        .listStyle(SidebarListStyle())
    }
}

extension SidebarList {
    
    func buildYearSections(from posts: [DynamicInfo]) -> [YearSection] {
        let entries: [MonthEntry] = posts.map { p in
            MonthEntry(
                year: p.parsedYear,
                month: p.parsedMonth,
                postID: p.id
            )
        }
        
        let grouped = Dictionary(grouping: entries) { $0.year }
        
        let sections: [YearSection] = grouped
            .map { year, monthEntries in
                
                let monthDict = Dictionary(grouping: monthEntries) { $0.month }
                
                let monthItems: [MonthItem] = monthDict.map { month, list in
                    MonthItem(id: list.first!.postID, month: month) }
                    .sorted { $0.month > $1.month }
                
                return YearSection(year: year, months: monthItems)
            }
            .sorted { $0.year > $1.year }
        
        return sections
    }
}
