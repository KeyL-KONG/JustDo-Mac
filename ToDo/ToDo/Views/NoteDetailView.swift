//
//  NoteDetailView.swift
//  ToDo
//
//  Created by LQ on 2025/5/28.
//
#if os(macOS)
import SwiftUI
import AlertToast

import AppKit


struct NoteDetailView: View {
    
    @State var isEdit: Bool = false
    @State var isWindow: Bool = false
    @State var noteItem: NoteModel
    @EnvironmentObject var modelData: ModelData
    @State var noteTitle: String = ""
    @State var noteContent: String = ""
    @State var overviewText: String = ""
    @State var summaryText: String = ""
    @State var noteTags: [String] = []
    @State var toggleToRefresh: Bool = false
    @State var overviewExpand: Bool = true
    @State var noteItemsExpand = true
    @State var noteExpand: Bool = true
    @State var summaryExpand: Bool = true
    @State var cursorPosition: Int = 0 {
        didSet {
            print("cursor pos: \(cursorPosition)")
        }
    }
    
    @State var noteRate: Double = 0
    
    static var isUploadingImage: Bool = false
    
    @Environment(\.openWindow) private var openWindow
    
    @State var showImageToast: Bool = false
    @State var imageResultText: String = ""
    @State var expandSummaryView: Bool = false
    
    @State var headingNodes: [HeadingNode] = []
    @State var selectCatalogId: String = ""
    @State var scrollText: String = ""
    
    var noteItems: [NoteItem] {
        noteItem.items.compactMap { id in
            modelData.noteItemList.first { item in
                item.id == id
            }}.sorted { ($0.updateAt?.timeIntervalSince1970 ?? 0) > ($1.updateAt?.timeIntervalSince1970 ?? 0)
            }
    }
    
    @State var editItemState: [String: Bool] = [:]
    @State var itemEditingContent: [String: String] = [:]  // 新增：用于存储编辑中的内容
    
    var body: some View {
        ScrollView {
            VStack {
                if toggleToRefresh {
                    Text("")
                } else {
                    Text("")
                }
                HStack {
                    if isEdit {
                        RemovableTagListView(showCloseButton: true, tags:noteTags, addTagEvent: { tag in
                            self.saveTag(tag)
                        }, removeTagEvent: { tag in
                            self.noteTags.removeAll { $0 == tag }
                        }, selectTagEvent: { tags in
                            self.noteTags += tags
                        }).environmentObject(modelData)
                    } else if noteTags.count > 0 {
                        RemovableTagListView(showCloseButton: false, tags: noteTags)
                            .environmentObject(modelData)
                    }
                    Spacer()
                    
                    RatingView(maxRating: 5, rating: $noteRate, onRateChange: { rate in
                        self.saveItem()
                    })
                    
                    Button("添加内容") {
                        let item = NoteItem()
                        item.content = "新增笔记内容"
                        modelData.updateNoteItem(item) { success in
                            if success {
                                self.noteItem.items.append(item.id)
                                modelData.updateNote(self.noteItem)
                            }
                        }
                    }
                }.padding(.horizontal)
                
                if isEdit {
                    HStack {
                        TextField("标题", text: $noteTitle)
                    }
                }
                
                let notShowOverViewHeader = !isEdit && overviewText.isEmpty
                
                if !notShowOverViewHeader {
                    overviewHeaderView()
                }
                
                if overviewExpand {
                    if isEdit {
                        TextEditor(text: $overviewText)
                            .font(.system(size: 14))
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(Color.init(hex: "#117a65").opacity(0.1))
                            .cornerRadius(8)
                            .frame(minHeight: 100)
                        
                    } else if overviewText.count > 0 {
                    
                        MarkdownWebView(overviewText, itemId: noteItem.id)
                            .padding()
                            .background(Color.init(hex: "117a65").opacity(0.1))
                            .cornerRadius(10)
                
                    }
                }
                
                if noteItem.items.count > 0 {
                    noteItemHeaderView()
                    
                    if noteItemsExpand {
                        ForEach(noteItems, id: \.self.id) { item in
                            if isEditNoteItem(item) {
                                ZStack {
                                    TextEditor(text: Binding(get: {
                                        return itemEditingContent[item.id] ?? item.content
                                    }, set: { val in
                                        itemEditingContent[item.id] = val
                                    }))
                                        .font(.system(size: 14))
                                        .padding(10)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.brown.opacity(0.1))
                                        .cornerRadius(8)
                                        .frame(minHeight: 100)
                                }.overlay(alignment: .topTrailing) {
                                    Button {
                                        item.content = itemEditingContent[item.id] ?? item.content  // 将编辑后的值写回item
                                        updateEditNoteItem(item, isEdit: false)
                                        modelData.updateNoteItem(item)
                                    } label: {
                                        Text("保存").foregroundStyle(.blue)
                                    }
                                }
                                
                            } else if item.content.count > 0 {
                                ZStack {
                                    MarkdownWebView(item.content, itemId: item.id)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 15)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                }.overlay(alignment: .bottomTrailing) {
                                    if let updateAt = noteItem.updateAt {
                                        Text(updateAt.simpleDateStr)
                                    }
                                }.overlay(alignment: .topTrailing) {
                                    Button {
                                        itemEditingContent[item.id] = item.content  // 编辑前将当前值存入State变量
                                        updateEditNoteItem(item, isEdit: true)
                                    } label: {
                                        Text("编辑").foregroundStyle(.blue)
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        noteItem.items.removeAll { $0 == item.id }
                                        modelData.deleteNoteItem(item)
                                        modelData.updateNote(noteItem)
                                    } label: {
                                        Text("删除").foregroundStyle(.red)
                                    }
                                }
                            }
                        }
                    }
                }
                
                noteHeaderView()
                
                if noteExpand {
                    if isEdit {
                        if isWindow {
                            HStack {
                                CustomTextEditor(text: $noteContent, cursorPosition: $cursorPosition) { pos in
                                    //self.cursorPosition = pos
                                }
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                    .frame(minHeight: 400)
                                Spacer()
                                VStack {
                                    MarkdownWebView(noteContent, itemId: noteItem.id)
                                    Spacer()
                                }
                                .frame(minHeight: 400)
                            }
                            
                        } else {
                            CustomTextEditor(text: $noteContent, cursorPosition: $cursorPosition)
                                .font(.system(size: 14))
                                .padding()
                                .scrollContentBackground(.hidden)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                .frame(minHeight: 400)
                        }
                        
                    }
                    else if noteContent.count > 0 {
                        MarkdownWebView(noteContent, itemId: noteItem.id, scrollText: scrollText)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(alignment: .topTrailing) {
                                if expandSummaryView {
                                    catalogView()
                                } else {
                                    expandButtonView()
                                }
                            }
                    }
                }
                
                
                let notShowSummaryHeader = !isEdit && summaryText.isEmpty
                
                if !notShowSummaryHeader {
                    summaryHeaderView()
                }
                
                if summaryExpand {
                    if isEdit {
                        TextEditor(text: $summaryText)
                            .font(.system(size: 14))
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                            .frame(minHeight: 100)
                        
                    } else if summaryText.count > 0 {
                        MarkdownWebView(summaryText, itemId: noteItem.id)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
                
            }
        }
        .toast(isPresenting: $showImageToast, alert: {
            AlertToast(displayMode: .hud, type: .regular, title: self.imageResultText)
        })
        .toolbar {
            
            if !isWindow {
                Button("添加") {
                    let note = NoteModel()
                    note.title = "新建笔记"
                    modelData.updateNote(note)
                }
                
                Button {
                    showNoteWindow()
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("在新窗口预览")
            } else {
                Text(noteTitle)
            }
            
            Button("\(isEdit ? "保存" : "编辑")") {
                self.isEdit.toggle()
                if !self.isEdit {
                    saveItem()
                }
            }
        }
        .onChange(of: modelData.updateNoteId, { oldValue, newValue in
            if newValue == noteItem.id {
                updateNoteData()
            }
        })
        .onAppear {
            self.updateNoteData()
            self.addObservers()
        }
        
    }
    
    
    func updateNoteData() {
        self.noteContent = noteItem.content
        self.noteTitle = noteItem.title
        self.overviewText = noteItem.overview
        self.summaryText = noteItem.summary
        self.noteRate = Double(noteItem.rate)
        self.noteTags = noteItem.tags.compactMap({ tagId in
            modelData.noteTagList.first {
                $0.id == tagId
            }?.content
        })
    }
}

extension NoteDetailView {
    
    func isEditNoteItem(_ item: NoteItem) -> Bool {
        return editItemState[item.id] ?? false
    }
    
    func updateEditNoteItem(_ item: NoteItem, isEdit: Bool) {
        editItemState[item.id] = isEdit
    }
    
    // 修改按钮响应方法
    private func showNoteWindow() {
        openWindow(id: CommonDefine.noteWindow, value: noteItem)
    }
    
    func saveItem() {
        noteItem.content = noteContent
        noteItem.overview = overviewText
        noteItem.summary = summaryText
        noteItem.rate = Int(noteRate)
        noteItem.tags = noteTags.compactMap({ tagContent in
            modelData.noteTagList.first {
                $0.content == tagContent
            }?.id
        })
        noteItem.title = noteTitle
        modelData.updateNote(noteItem)
    }
    
    func saveTag(_ tag: String) {
        if modelData.noteTagList.contains(where: { $0.content == tag }) {
            self.noteTags.append(tag)
            return
        }
        let tagModel = TagModel()
        tagModel.content = tag
        modelData.updateTagNote(tagModel)
    }
    
    func deleteTag(_ tag: String) {
        guard let tagModel = modelData.noteTagList.first(where: { $0.content == tag
        }) else {
            return
        }
        modelData.deleteTag(tagModel)
    }
}

extension NoteDetailView {
    
    private func addObservers() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                checkPasteboardChanged()
                return nil
            }
            return event
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(CommonDefine.addNewThink),
            object: nil,
            queue: .main
        ) { notification in
            if let content = notification.userInfo?["content"] as? String, let id = notification.userInfo?["id"] as? String {
                let item = SummaryItem()
                item.content = content
                if let note = modelData.noteList.first(where: { $0.id == id
                }), note.tags.count > 0 {
                    item.tags = note.tags
                }
                item.associateIds.append(id)
                modelData.updateSummaryItem(item)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(CommonDefine.highlightText),
            object: nil,
            queue: .main
        ) { notification in
            if let content = notification.userInfo?["content"] as? String, let id = notification.userInfo?["id"] as? String {
                // 在原始内容前后添加==符号
                let highlightedContent = "==\(content)=="
                
                // 替换笔记内容中的匹配文本
                noteContent = noteContent.replacingOccurrences(
                    of: content, 
                    with: highlightedContent,
                    options: .literal,
                    range: nil
                )
                
                saveItem()
            }
        }
    }
    
    private func checkPasteboardChanged() {
        onPasteboardChanged()
    }
    
    private func onPasteboardChanged() {
        print("on pasteboard changed")
        guard let pastedItem = NSPasteboard.general.pasteboardItems?.first, let pasteType = pastedItem.types.first else {
            return
        }
        if let imageData = pastedItem.data(forType: pasteType), let image = NSImage(data: imageData) {
            uploadImage(image: image)
        } else if let _ = pastedItem.data(forType: .string) {
            NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
        }
    }
    
#if os(macOS)
    private func uploadImage(image: NSImage) {
        print("upload image")
        if Self.isUploadingImage {
            return
        }
        if let data = image.toData() {
            Self.isUploadingImage = true
            CloudManager.shared.upload(with: data) { url, error in
                Self.isUploadingImage = false
                if let error = error {
                    print("upload data failed: \(error)")
                    self.imageResultText = "upload fail"
                    self.showImageToast.toggle()
                } else if let url = url {
                    // 新增光标位置处理
                    let insertionText = url.formatImageUrl
                    let currentContent = self.noteContent
                    print("insert text: \(insertionText), pos: \(self.cursorPosition)")
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(insertionText, forType: .string)
                    self.imageResultText = "upload success"
                    self.showImageToast.toggle()
                }
            }
        }
    }
#endif
}

extension NoteDetailView {
    
    func overviewHeaderView() -> some View {
        HStack {
            Text("概述").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "48c9b0"))
            Spacer()
            
            Button {
                self.overviewExpand = !self.overviewExpand
            } label: {
                Image(systemName: overviewExpand ? "chevron.down" : "chevron.right").foregroundStyle(Color.init(hex: "48c9b0"))
            }
            .buttonStyle(.plain)
        }.padding(.top, 5)
        .padding(.horizontal, 5)
    }
    
    func noteHeaderView() -> some View {
        HStack {
            Text("笔记").bold().font(.system(size: 16))
                .foregroundStyle(Color.blue)
            Spacer()
            Button {
                self.noteExpand = !self.noteExpand
            } label: {
                Image(systemName: noteExpand ? "chevron.down" : "chevron.right").foregroundStyle(Color.blue)
            }
            .buttonStyle(.plain)
        }.padding(.top, 5)
        .padding(.horizontal, 5)
    }
    
    func summaryHeaderView() -> some View {
        HStack {
            Text("总结").bold().font(.system(size: 16))
                .foregroundStyle(Color.orange)
            Spacer()
            
            Button {
                self.summaryExpand = !self.summaryExpand
            } label: {
                Image(systemName: summaryExpand ? "chevron.down" : "chevron.right").foregroundStyle(Color.orange)
            }
            .buttonStyle(.plain)
        }.padding(.top, 5)
        .padding(.horizontal, 5)
    }
    
}

extension NoteDetailView {
    
    func noteItemHeaderView() -> some View {
        HStack {
            Text("记录").bold().font(.system(size: 16))
                .foregroundStyle(Color.brown)
            Spacer()
            
            Button {
                self.noteItemsExpand = !self.noteItemsExpand
            } label: {
                Image(systemName: noteItemsExpand ? "chevron.down" : "chevron.right").foregroundStyle(Color.brown)
            }
            .buttonStyle(.plain)
        }.padding(.top, 5)
        .padding(.horizontal, 5)
    }
    
}

extension NoteDetailView {
    
    func expandButtonView() -> some View {
        Button {
            self.updateHeadNodes()
            self.expandSummaryView = !self.expandSummaryView
        } label: {
            let imageName = self.expandSummaryView ? "arrow.right.circle.fill" : "arrow.backward.circle.fill"
            Image(systemName: imageName).font(.system(size: 16))
        }
        .buttonStyle(.plain)
        .padding()
    }
    
    func recursiveItemView(node: HeadingNode) -> AnyView {
        if node.children.isEmpty {
            return AnyView(
                HStack(content: {
                    Text(node.title)
                    Spacer()
                }).tag(node.id)
            )
        } else {
            return AnyView(
                DisclosureGroup(isExpanded: .constant(true), content: {
                    ForEach(node.children, id: \.self) { node in
                        if node.title.count > 0 {
                            HStack {
                                Text(node.title)
                                Spacer()
                            }.tag(node.id)
                        }
                    }
                }, label: {
                    HStack {
                        Text(node.title)
                        Spacer()
                    }.tag(node.id)
                })
            )
        }
    }
    
    func catalogView() -> some View {
        List(selection: $selectCatalogId) {
            ForEach(headingNodes, id: \.self.id) { node  in
                recursiveItemView(node: node)
            }
        }
        .cornerRadius(8)
        .frame(maxWidth: 200)
        .padding()
        .onChange(of: selectCatalogId, { oldValue, newValue in
            if let node = headingNodes.first(where: { $0.id == newValue
            }) {
                scrollText = node.title
            }
        })
        .overlay(alignment: .topTrailing) {
            Button {
                self.expandSummaryView = !self.expandSummaryView
            } label: {
                let imageName = self.expandSummaryView ? "arrow.right.circle.fill" : "arrow.backward.circle.fill"
                Image(systemName: imageName).font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .offset(x: -20, y: 20)
        }
    }
    
    func updateHeadNodes() {
        self.headingNodes = MarkdownParser.parse(markdown: noteContent)
    }
    
}
#endif
