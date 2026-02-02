//
//  AdditionalContent.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/23.
//

import Foundation

struct HitokotoResponse: Codable {
    let code: Int
    let data: HitokotoData
    let msg: String
}

struct HitokotoData: Codable {
    let hitokoto: String
    let from: String
}

final class AdditionalContent {
    
    static let shared = AdditionalContent()
    
    private init() {}
    
    private var cachedHitokoto: String = "加载中…"
    private var hasFetchedHitokoto: Bool = false
    
    // MARK: - 使用iTab API获取每日一言
    func fetchHitokoto() async -> String {
        if hasFetchedHitokoto { return cachedHitokoto }
        
        guard let apiUrl = URL(string: "https://itab-api.yaohub.com/yiyan/random") else {
            return "Invalid URL"
        }
            
        do {
            let (data, _) = try await URLSession.shared.data(from: apiUrl)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("返回原始的JSON数据： \(jsonString)")
            }
            
            let json = try JSONDecoder().decode(HitokotoResponse.self, from: data)
            cachedHitokoto = json.data.hitokoto
            hasFetchedHitokoto = true
            return cachedHitokoto
        } catch {
            print("解析错误: \(error.localizedDescription)")
            return "每日一言 获取失败"
        }
    }
}
