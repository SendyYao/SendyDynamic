//
//  SendyDynamicTests.swift
//  SendyDynamicTests
//
//  Created by XuYao on 2025/12/6.
//

import Testing
import Foundation

struct TextWithEmotions: Codable {
    var text: String
    var emotions: [String] = []
}

// 定义 CommentContent 结构体
struct CommentContent: Codable {
    var text: String
    var emotions: [String] = []
    var reply_to: TextWithEmotions?
}

// 定义 SingleComment 结构体
struct SingleComment: Codable {
    var type: String
    var tid: Int
    var uin: String
    var nick: TextWithEmotions
    var avatar: String
    var content: CommentContent
    var time: String
    var replies: [SingleComment] = []
}

// 定义 DynamicInfo 结构体
struct DynamicInfo: Codable {
    var dateTime: String?
    var textContent: String?
    var textContentEmojis: [String]?
    var imgList: [String]?
    var isVideo: Bool? = false
    var phoneInfo: String?
    var visitorNum: String?
    var likedUser: String?
    var comments: [SingleComment]?
}

// 定义 DynamicInfo 数组
struct InfoList: Codable {
    var info: [DynamicInfo]
}

struct SendyDynamicTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func loadJson() async throws {
        guard let fileUrl = Bundle.main.url(forResource: "dynamicInfo", withExtension: "json") else {
            fatalError("dynamicInfo.json file not found")
        }
        do {
            let data = try Data(contentsOf: fileUrl)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("返回原始的JSON数据： \(jsonString)")
            }
        } catch {
            print("Can't get json")
        }
        
    }
    
    @Test func testParse() async throws {
            guard let fileUrl = Bundle.main.url(forResource: "dynamicInfo", withExtension: "json") else {
                fatalError("dynamicInfo.json file not found")
            }
            do {
                let data = try Data(contentsOf: fileUrl)
                let infoList = try JSONDecoder().decode(InfoList.self, from: data)
                infoList.info.forEach{item in
                    print(item.textContent ?? "")
                }
            } catch {
                print("解析错误: \(error.localizedDescription)")
            }
    }
}
