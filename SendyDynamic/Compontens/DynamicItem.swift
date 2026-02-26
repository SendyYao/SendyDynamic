//
//  DynamicItem.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/6.
//

import SwiftUI
import Photos

// 定义 TextWithEmotions 结构体
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
struct SingleComment: Codable, Identifiable {
    var id: UUID = UUID()
    var type: String
    var tid: Int
    var uin: String
    var nick: TextWithEmotions
    var avatar: String
    var content: CommentContent
    var time: String
    var replies: [SingleComment]? = []
    
    enum CodingKeys: String, CodingKey {
           case type, tid, uin, nick, avatar, content, time, replies
       }
}

// 定义 DynamicInfo 结构体
struct DynamicInfo: Codable, Identifiable {
    var id = UUID()
    var dateTime: String
    var textContent: String?
    var textContentEmojis: [String]?
    var imgList: [String]?
    var isVideo: Bool? = false
    var phoneInfo: String?
    var visitorNum: String?
    var likedUser: String?
    var comments: [SingleComment]?
    
    enum CodingKeys: String, CodingKey {
           case dateTime, textContent, textContentEmojis, imgList, isVideo, phoneInfo, visitorNum, likedUser, comments
       }
}

// 定义 DynamicInfo 数组
struct InfoList: Codable {
    var info: [DynamicInfo]
}

class DynamicPostData: ObservableObject {
    
    @Published var infoList: [DynamicInfo] = []
    private var hasFetchedAttachInfo: Bool = false
    
    func loadJson() {
        guard let fileUrl = Bundle.main.url(forResource: "dynamicInfo", withExtension: "json") else {
            print("dynamicInfo.json file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileUrl)
            let decodedData = try JSONDecoder().decode(InfoList.self, from: data)
            DispatchQueue.main.async {
                self.infoList = decodedData.info
            }
        } catch {
            print("加载 JSON 时发生错误: \(error)")
        }
        print("Loaded JSON")
    }
    
    func loadAttachInfo(apiUrl: String) async {
        guard !hasFetchedAttachInfo else { return }
        hasFetchedAttachInfo = true
        
        guard let attachInfoUrl = URL(string: "\(apiUrl)AttachInfo.json") else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: attachInfoUrl)
            let attach = try JSONDecoder().decode(InfoList.self, from: data)
            
            await mergeAttachInfo(attach.info)
            
        } catch {
            print("加载 JSON 时发生错误: \(error)")
        }
    }
    
    func loadAnotherUserInfo(index: Int, apiUrl:String) async {
        switch index {
        case 0:
            loadJson()
            await loadAttachInfo(apiUrl: apiUrl)
            
        case 1:
            // print("LoadAnotherUserInfo")
            guard let yaoInfoUrl = URL(string: "\(apiUrl)/Yao/dynamicInfoYao.json") else {
                print("Invalid URL")
                return
            }
            do {
                let (data, _) = try await URLSession.shared.data(from: yaoInfoUrl)
                let yaoInfo = try JSONDecoder().decode(InfoList.self, from: data)
                await updateInfo(yaoInfo.info)
            } catch {
                print("加载 Yao DynamicInfo JSON 时发生错误: \(error)")
                return
            }
        default:
            print("No this user")
        }
    }
    
    @MainActor
    private func mergeAttachInfo(_ newInfo: [DynamicInfo]) {
        var merged = infoList + newInfo
        
        merged.sort {
            $0.parsedDate ?? .distantPast > $1.parsedDate ?? .distantPast
        }
        
        self.infoList = merged
    }
    
    @MainActor
    private func updateInfo(_ newInfo: [DynamicInfo]) {
        self.infoList = newInfo
    }
}

struct DynamicPostItem: View {
    var id: UUID
    var userNick: String
    var userAvatar: String
    var postTime: String
    var content: String
    var emojis: [String]
    var imgList: [String]
    var phoneInfo: String
    var likeUser: String
    var comments: [SingleComment]
    @State private var isTextInteracting = false
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let userAvatar = ImageLoaderOP.shared.loadLocalImage(named: userAvatar) {
                        Image(uiImage: userAvatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    }
                    VStack(alignment: .leading) {
                        Text(userNick)
                            .font(.headline)
                            .foregroundColor(Color("RegularTextForeground"))
                        Text(postTime)
                            .font(.subheadline)
                            .foregroundColor(Color("RegularTextForeground"))
                    }
                }
                .padding(.bottom, 8)
                
                TextWithEmojis(content: content, emojis: emojis, needInteract: true, isTextInteracting: $isTextInteracting)
                    .padding(.bottom, 12)
                
                if !imgList.isEmpty {
                    ImageBox(imgList: imgList)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                
                Text(phoneInfo)
                    .font(.footnote)
                    .foregroundColor(Color("RegularTextForeground"))
                    .padding(.leading, 10)
                    .padding(.bottom, 5)
                
                VStack {
                    Divider()
                        .frame(height: 1)
                        .background(Color(UIColor.rgb(31, 31, 31)))
                    
                    Spacer().frame(height: 3)
                }
                .padding(.horizontal, UIScreen.main.bounds.width * 0.025)
                
                Text(likeUser)
                    .padding(.top, 5)
                    .font(.system(size: 12))
                    .foregroundColor(Color(UIColor.rgb(102, 153, 204)))
                
                // Comment List
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(comments) { comment in
                        CommentView(comment: comment)
                        Divider().background(Color("RegularTextForeground").opacity(0.3))
                    }
                }
            }
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
//            .cardTapToDismissSelection(isTextInteracting: isTextInteracting)
        }
    }
}

struct CardView<Content: View>: View {
    
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
    }
}

final class DeselectableTextView: UITextView, UIGestureRecognizerDelegate {
    
    var onLongPress: (() -> Void)?
    private var didAddLongPress = false
    var onInteractionChanged: ((Bool) -> Void)?
    
    private(set) var isInteractingWithText = false {
        didSet {
            if oldValue != isInteractingWithText {
                onInteractionChanged?(isInteractingWithText)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isInteractingWithText = true
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isInteractingWithText = false
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isInteractingWithText = false
        super.touchesCancelled(touches, with: event)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        guard !didAddLongPress else { return }
        didAddLongPress = true
        
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress)
        )
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ g: UILongPressGestureRecognizer) {
        guard g.state == .began else { return }
        onLongPress?()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        isInteractingWithText = true
        super.touchesMoved(touches, with: event)
    }

}

struct SelectableTextView: UIViewRepresentable {
    
    let attributedText: NSAttributedString
    let width: CGFloat
    @Binding var dynamicHeight: CGFloat
    let onLongPress: () -> Void
    var isInteractingWithText: Binding<Bool>
    
    func makeUIView(context: Context) -> UITextView {
        let textView = context.coordinator.textView
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        
        textView.backgroundColor = .clear
        textView.textContainer.widthTracksTextView = true
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.textContainer.widthTracksTextView = true
        
        textView.dataDetectorTypes = []
        textView.allowsEditingTextAttributes = false
        
        textView.onInteractionChanged = { interacting in
            DispatchQueue.main.async {
                self.isInteractingWithText.wrappedValue = interacting
            }
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
        
        DispatchQueue.main.async {
            guard width > 0 else { return }
            
            let size = uiView.sizeThatFits(
                CGSize(width: width, height: .greatestFiniteMagnitude)
            )
            
            if abs(dynamicHeight - size.height) > 0.5 {
                dynamicHeight = size.height
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator {
        let textView = DeselectableTextView()
    }
}

/// 处理文本和表情的显示
struct TextWithEmojis: View {
    var content: String
    var emojis: [String]
    var fontSize: CGFloat = 14
    var emojiSize: CGFloat = 24
    var needInteract: Bool = false
    @State private var textHeight: CGFloat = .zero
    @State private var isPressed = false
    var isTextInteracting: Binding<Bool>? = nil
    
    private var nonInteractText: some View {
        HStack(spacing: 0) {
            Text(content)
                .font(.system(size: fontSize))
                .foregroundColor(Color("RegularTextForeground"))
            
            ForEach(Array(emojis.enumerated()), id: \.offset) { _, emoji in
                if let emoji = ImageLoaderOP.shared.loadLocalImage(named: emoji) {
                    Image(uiImage: emoji)
                        .resizable()
                        .scaledToFit()
                        .frame(width: emojiSize, height: emojiSize)
                }
            }
        }
    }
    
    private var pressEffect: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondary.opacity(0.15))
            .scaleEffect(isPressed ? 0.97 : 1)
            .opacity(isPressed ? 1 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isPressed)
    }
    
    private func copyAll() {
        let attr = buildAttributedText()
        
        UIPasteboard.general.string = attr.string
    }
    
    private func shareAll() {
        let attr = buildAttributedText()
        
        let vc = UIActivityViewController(
            activityItems: [attr.string],
            applicationActivities: nil
        )
        
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene})
            .first,
              let rootVC = windowScene.keyWindow?.rootViewController else {
            return
        }
        
        // For iPad
        if let popover = vc.popoverPresentationController {
            popover.sourceView = rootVC.view
            popover.sourceRect = CGRect(
                x: rootVC.view.bounds.midX,
                y: rootVC.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        rootVC.present(vc, animated: true)
    }
    
    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            print("Copy all")
            copyAll()
        } label: {
            Label("Copy all", systemImage: "doc.on.doc")
        }
        Button {
            print("Share")
            shareAll()
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }
    
    func buildAttributedText() -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        
        let result = NSMutableAttributedString(
            string: content,
            attributes: [
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: UIColor(Color("RegularTextForeground")),
                .paragraphStyle: paragraphStyle
            ]
        )
        
        for emoji in emojis {
            guard let image = ImageLoaderOP.shared.loadLocalImage(named: emoji) else { continue }
            
            let attachment = NSTextAttachment()
            attachment.image = image
            
            attachment.bounds = CGRect(
                x: 0,
                y: (UIFont.systemFont(ofSize: fontSize).capHeight - emojiSize / 2),
                width: emojiSize,
                height: emojiSize
            )
            
            let attr = NSAttributedString(attachment: attachment)
            result.append(attr)
        }
        
        return result
    }
    
    var body: some View {
        Group {
            if needInteract {
                let attributed = buildAttributedText()
                GeometryReader { geo in
                    ZStack {
                        pressEffect
                        SelectableTextView(
                            attributedText: attributed,
                            width: geo.size.width,
                            dynamicHeight: $textHeight,
                            onLongPress: {
                                print("onLongPress")
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                isPressed = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    isPressed = false
                                }
                            },
                            isInteractingWithText: isTextInteracting ?? .constant(false)
                        )
                        .frame(height: textHeight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(height: textHeight)
                .contextMenu {
                    contextMenuContent
                }
            } else {
                nonInteractText
            }
        }
    }
}

enum ImageSource {
    case network(URL)
    case local(String)

    init(fileName: String, dynamicAPI: String) {
        if fileName.contains("apsc"),
           let url = URL(string: "\(dynamicAPI+fileName).jpg") {
            self = .network(url)
        } else if fileName.contains("photos/"),
                  let url = URL(string: "\(dynamicAPI)Yao/\(fileName)") {
            self = .network(url)
        } else {
            self = .local(fileName)
        }
    }
}

struct NetworkImageView<Content: View>: View {
    
    let url: URL
    let size: CGFloat
    let content: (UIImage) -> Content
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = image {
                content(image)
            } else {
                ProgressView()
                    .onAppear {
                        loadIfNeeded()
                    }
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .cornerRadius(6)
    }
    
    private func loadIfNeeded() {
        guard !isLoading else { return }
        
        if let cachedImage = ImageCache.shared.getImage(for: url) {
            image = cachedImage
            return
        }
        
        isLoading = true
        ImageLoaderOP.shared.loadImage(url: url) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                if let result = result {
                    ImageCache.shared.setImage(result, for: url)
                    self.image = result
                }
            }
        }
    }
}

/// Build ImageBox
struct ImageBox: View {
    @EnvironmentObject var appState: AppState
    var imgList: [String] // 图片列表
    
    @State private var loadedImages: Set<String> = []
    @State private var selectedImage: ViewerImage?
    
    private let imageLoader = ImageLoaderOP.shared
    
    @ViewBuilder
    private func imageMenuContent(for image: UIImage) -> some View {
        Button {
            print("Save photos")
            saveImageToPhotos(image)
        } label: {
            Label("Save this photo", systemImage: "square.and.arrow.down.fill")
        }
    }
    
    private func saveImageToPhotos(_ image: UIImage) {
        
        guard let jpegData = image.jpegData(compressionQuality: 1.0) else {
            print("Can't convert this image")
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized || status == .limited {
                PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .photo, data: jpegData, options: nil)
//                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if success {
                            print("Save photo successfully")
                        } else {
                            print("Save photo failed: \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            } else {
                print("No access permission")
            }
        }
    }
    
    var body: some View {
        // 根据图片数量动态调整每行显示的图片数
        let crossAxisCount: Int
        var size: CGFloat
        switch imgList.count {
        case 1:
            crossAxisCount = 1; size = 345
        case 2:
            crossAxisCount = 1; size = 207
        case 4:
            crossAxisCount = 2; size = 207
            
        // Fix layout bug when imgList.count == 5
        case 5...6:
            crossAxisCount = 2; size = 138.75
        case 7...:
            crossAxisCount = 3; size = 138.75

        default:    // 0 或 3
            crossAxisCount = 1; size = 138.75
        }
        
        if appState.platform == .iPhone {
            size = size / 1.35
        }

        // 使用 LazyVGrid 来创建网格布局
        let rows = Array(repeating: GridItem(.fixed(size), spacing: 8), count: crossAxisCount)
        return ScrollView {
            LazyHGrid(rows: rows, spacing: 8) {
                ForEach(imgList, id: \.self) { fileName in
                    // 显示每张图片
                    let source = ImageSource(fileName: fileName, dynamicAPI: appState.dynamicAPI)
                    Group {
                        switch source {
                        case .network(let url):
                            NetworkImageView(
                                url: url,
                                size: size
                            ) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .contextMenu {
                                        imageMenuContent(for: image)
                                    }
                            }
                        case .local(let name):
                            if let image = ImageLoaderOP.shared.loadLocalImage(named: name) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size, height: size)
                                    .clipped()
                                    .cornerRadius(6)
                                    .contextMenu {
                                        imageMenuContent(for: image)
                                    }
                            }
                        }
                    }
                }
            }
            .padding(8)
        }
    }
}

struct CommentView: View {
    var comment: SingleComment
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(alignment: .top, spacing: 10) {
                if let userAvatar = ImageLoaderOP.shared.loadLocalImage(named: comment.avatar) {
                    Image(uiImage: userAvatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("BorderColor"), lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    
                    HStack() {
                        Text(comment.nick.text + ": ")
                            .font(.subheadline)
                            .foregroundColor(Color("ContrastTextForeground"))
                        
                        TextWithEmojis(content: comment.content.text, emojis: comment.content.emotions)
                    }
                    
                    Text(comment.time)
                        .font(.caption)
                        .foregroundColor(Color("RegularTextForeground"))
                }
                
            }
            if comment.replies != nil {
                let repliesChian = comment.buildReplyChain()
                ForEach(repliesChian) { item in
                    ReplyView(
                        reply: item.reply,
                        parentNick: item.parentNick
                    )
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ReplyView: View {
    var reply: SingleComment
    var parentNick: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // 头像
            if let userAvatar = ImageLoaderOP.shared.loadLocalImage(named: reply.avatar) {
                Image(uiImage: userAvatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color("BorderColor"), lineWidth: 1))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                
                HStack() {
                    // 回复昵称和内容
                    Text("\(reply.nick.text) 回复 \(parentNick):")
                        .font(.subheadline)
                        .foregroundColor(Color("ContrastTextForeground"))
                    
                    // 回复文本和表情
                    TextWithEmojis(content: reply.content.text, emojis: reply.content.emotions)
                }
                
                // 回复时间
                Text(reply.time)
                    .font(.caption)
                    .foregroundColor(Color("RegularTextForeground"))
            }
        }
        .padding(.leading, 16)
        .padding(.vertical, 4)
    }
}

extension UIColor {
    // 用于扩展UIColor，支持RGB设置
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }
}

extension DynamicInfo {
    
    private var currentYear: Int { 2025 }
    
    private var cleanedDateTime: String {
        let prefixes = ["编辑于"]
        var result = dateTime
        
        for p in prefixes {
            result = result.replacingOccurrences(of: p, with: "")
        }
        return result
    }
    
    var parsedYear: Int {
        
        let cleanedTime = cleanedDateTime
        
        if cleanedTime.contains("年") {
            let parts = cleanedTime.split(separator: "年", maxSplits: 1)
            return Int(parts[0]) ?? currentYear
        } else {
            return currentYear // 2023
        }
    }
    
    var parsedMonth: Int {
        
        let full = dateTime.replacingOccurrences(of: " ", with: "")
        
        // 修复提取月份部分
        let monthPattern = "\\d{1,2}月" // 正则匹配1或2位的月份数字加上"月"
        if let range = full.range(of: monthPattern, options: .regularExpression) {
            let monthSubstring = full[range]
            let month = monthSubstring.replacingOccurrences(of: "月", with: "")
            return Int(month) ?? 1 // 如果提取失败则返回 1 月
        }
        return 1 // 默认返回 1 月
    }
    
    // MARK: - 👇 提取日
    private var parsedDay: Int {
        let full = cleanedDateTime.replacingOccurrences(of: " ", with: "")
        let dayPattern = "\\d{1,2}日"
            
        if let range = full.range(of: dayPattern, options: .regularExpression) {
            let daySub = full[range]
            return Int(daySub.replacingOccurrences(of: "日", with: "")) ?? 1
        }
        return 1
    }

    // MARK: - 👇 提取时间（支持 “14:33”, “14:33:58”, 也可能完全没有时间）
    private var parsedTime: (hour: Int, minute: Int, second: Int) {
        let full = cleanedDateTime
            
        // 正则匹配 H:mm 或 HH:mm 或 HH:mm:ss
        let timePattern = "\\d{1,2}:\\d{1,2}(:\\d{1,2})?"
        if let range = full.range(of: timePattern, options: .regularExpression) {
            let timeString = String(full[range])
            let parts = timeString.split(separator: ":")
            
            let h = Int(parts[0]) ?? 0
            let m = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0
            let s = parts.count > 2 ? (Int(parts[2]) ?? 0) : 0
            
            return (h, m, s)
        }
            return (0, 0, 0) // 没时间就返回 0 点
        }
    
    var parsedDate: Date? {
        var comps = DateComponents()
        comps.year = parsedYear
        comps.month = parsedMonth
        comps.day = parsedDay
        comps.hour = parsedTime.hour
        comps.minute = parsedTime.minute
        
        return Calendar.current.date(from: comps)
    }
}

struct ReplyWithParent: Identifiable {
    let reply: SingleComment
    let parentNick: String
    
    var id: UUID { reply.id }
}

extension SingleComment {

    /// 构建带 parentNick 的回复列表
    func buildReplyChain() -> [ReplyWithParent] {
        guard let replies = self.replies else { return [] }
        
        var result: [ReplyWithParent] = []
        var previousReplyNick: String? = nil
        
        for (index, reply) in replies.enumerated() {
            let parentNick = (index == 0)
                ? self.nick.text                     // 第一条 → 回复楼主
                : (previousReplyNick ?? self.nick.text)

            // 构建新对象
            result.append(
                ReplyWithParent(reply: reply, parentNick: parentNick)
            )

            previousReplyNick = reply.nick.text       // 更新上一条 nick
        }
        
        return result
    }
}

extension View {
    func cardTapToDismissSelection(isTextInteracting: Bool) -> some View {
        self.overlay(
            Color.clear
                .contentShape(Rectangle())
                .allowsHitTesting(!isTextInteracting)
                .onTapGesture {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
        )
    }
}
