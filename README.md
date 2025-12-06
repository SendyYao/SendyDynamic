# SendyDynamic

SendyDynamic 是一个面向 **iOS / iPadOS** 的 Swift 应用，用于 **查看与归档 QQ 动态内容**。应用以时间线与月度归档为核心，结合本地 JSON 数据与网络 API，实现了快速浏览、定位与补充加载动态信息的能力。

> ✨ 适合用于：个人动态备份、历史内容回顾、时间线型内容展示的 App 实践示例

---

## ✨ 功能特性

* 📦 **本地动态归档**
  从本地 `Assets/dynamicInfo.json` 加载基础动态数据，支持离线查看。

* 🌐 **附加动态信息加载（API）**
  通过网络 API 拉取附加动态内容（如补充信息、扩展数据等），并与本地数据进行合并展示。

* 🗂 **月度侧边栏归档（Sidebar）**

  * 按「年 / 月」对动态进行分组
  * 点击侧边栏月份可 **快速滚动定位** 到对应的动态位置
  * iPad 上体验更接近分栏阅读，iPhone 上自适应展示

* 🧭 **时间线式动态列表**
  使用 `DynamicPostItem` 作为核心展示单元，按时间顺序排列，结构清晰。

* 💬 **每日一言**
  集成每日一言 API，在应用中展示随机语句，为浏览体验增添轻量内容。

---

## 📱 平台支持

* iOS 17+
* iPadOS 17+

（基于 SwiftUI 构建，针对 iPad 做了侧边栏与布局适配）

---

## 🔄 数据加载流程

1. 启动应用
2. 从 `Assets/dynamicInfo.json` 读取本地动态基础数据
3. 初始化时间线与月度归档索引
4. 调用 API 加载附加动态信息
5. 合并并更新对应的 `DynamicPostItem`

---

## 🚀 快速开始

1. 克隆仓库

   ```bash
   git clone https://github.com/yourname/SendyDynamic.git
   ```

2. 使用 Xcode 打开项目

   ```bash
   open SendyDynamic.xcodeproj
   ```

3. 运行到 iPhone 或 iPad 模拟器 / 真机

---

## 📝 dynamicInfo.json 示例结构

```json
{
    "info": [
        {
            "dateTime": "2月28日 00:15",
            "textContent": "奋斗是青春的代名词，孤独是努力的代价，我无所谓她人的言语，只为到达最高的山顶，最后一百天，不负自己！",
            "imgList": ["psc","psc1","psc2","psc3"],
            "phoneInfo": "来自 荣耀10 Lite (4G) ",
            "visitorNum": "浏览268次",
            "likedUser": "弈、Weirdo.、。、淡写 ╮青春、1eco_、Lumen、Yuzuru.、暖杯巧克力、吸吸鼻涕泡等75人觉得很赞",
            "comments": [
                {
                    "type": "commentroot",
                    "tid": 1,
                    "uin": "1159058188",
                    "nick": {
                        "text": "女色墙（全是美女",
                        "emotions": [

                        ]
                    },
                    "avatar": "301",
                    "content": {
                        "text": ":祝你天天好运",
                        "emotions": ["e10087.gif","e10088.gif"],
                        "reply_to": null
                    },
                    "time": "2月28日 00:45",
                    "replies": []
                }
            ]
        }
    ]
}
```

---

## 📌 设计目标

* 保留时间线的 **真实感与可回溯性**
* 提供快速定位历史内容的能力
* 兼顾 iPhone 与 iPad 的阅读体验

---

## 📄 License

This project is for personal and learning purposes.

---

