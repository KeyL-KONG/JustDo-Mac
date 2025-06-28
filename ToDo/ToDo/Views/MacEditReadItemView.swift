//
//  MacEditReadItemView.swift
//  ReadList
//
//  Created by ByteDance on 2023/9/24.
//

import SwiftUI
#if os(macOS)
struct MacEditReadItemView: View {
    
    enum FocusedField {
        case url
        case title
        case content
        case note
    }
    
    @EnvironmentObject var modelData: ModelData
    @State var readItem: ReadModel
    
    @State var urlText: String = ""
    @State var titleText: String = ""
    @State var contentText: String = ""
    @FocusState private var focusedField: FocusedField?
    
    @State var readTags: [String] = []
    @State var rating: Double = 0.0
    @State var isEditTag: Bool = false
    
    @State var updateCallback: () -> ()
    
    var finishTimes: [ReadTimeItem] {
        readItem.finishTimes.compactMap { .init(time: $0) }
    }
    
    var body: some View {
        VStack {
            List {
                Section("URL") {
                    TextField("URL", text: $urlText, axis: .vertical)
                        .focused($focusedField, equals: .url)
                }
                
                Section("标题") {
                    TextField("标题", text: $titleText, axis: .vertical)
                        .focused($focusedField, equals: .title)
                }
                
                Section(header: HStack(content: {
                    Text("标签")
                    Spacer()
                    Button {
                        if self.isEditTag {
                            saveReadItem()
                        }
                        self.isEditTag = !self.isEditTag
                    } label: {
                        let title = isEditTag ? "保存" : "编辑"
                        Text(title)
                    }

                })) {
                    if isEditTag {
                        RemovableTagListView(showCloseButton: true, tags:readTags, addTagEvent: { tag in
                            self.readTags.append(tag)
                            self.saveTag(tag)
                        }, removeTagEvent: { tag in
                            self.readTags.removeAll { $0 == tag }
                        }, selectTagEvent: { tags in
                            self.readTags += tags
                        }).environmentObject(modelData)
                    } else if readTags.count > 0 {
                        RemovableTagListView(showCloseButton: false, tags: readTags)
                            .environmentObject(modelData)
                    }
                    
                }
                
                Section("评价") {
                    RatingView(maxRating: 5, rating: $rating).previewLayout(.sizeThatFits)
                }
                
                Section("笔记") {
                    
                    Text(contentText.isEmpty ? "输入笔记内容" : contentText)
                        .font(.body)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .foregroundColor(Color.gray)
                        .opacity(contentText.isEmpty ? 1 : 0)
                        .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                                .padding(.horizontal, 5)
                        )
                        .overlay(
                            TextEditor(text: $contentText)
                                .font(.body)
                                .foregroundColor(Color.black)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 15)
                                .focused($focusedField, equals: .title)
                        )
                    
                }
                
                if let url = URL(string: readItem.url) {
                    Section("内容") {
                        ScrollView {
                            WebView(url: url)
                                .frame(minHeight: 500)
                        }
                    }
                }
                
            }
            .listStyle(.plain)
        }
        .onAppear {
            urlText = readItem.url
            titleText = readItem.title
            contentText = readItem.note
            focusedField = .content
            readTags = readItem.tags.compactMap({ tagId in
                modelData.noteTagList.first {
                    $0.id == tagId
                }?.content
            })
            rating = readItem.rate
            isEditTag = readItem.tags.isEmpty
            
            // 添加通知监听
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("UpdateNoteContent"),
                object: nil,
                queue: .main
            ) { notification in
                if let content = notification.userInfo?["content"] as? String {
                    let content = "- \(content)"
                    if contentText.isEmpty {
                        contentText = content
                    } else {
                        contentText += "\n\n \(content)"
                    }
                    saveReadItem()
                }
            }
        }
        .onChange(of: contentText) { newValue in
            readItem.note = newValue
            updateCallback()
        }
        .toolbar {
            ToolbarItem {
                Button {
                    saveReadItem()
                    updateCallback()
                } label: {
                    Text("保存").foregroundColor(.blue)
                }
            }
        }
        
    }
    
    private func saveReadItem() {
        readItem.url = urlText
        readItem.title = titleText
        readItem.note = contentText
        readItem.tags = readTags.compactMap({ tagContent in
            modelData.noteTagList.first {
                $0.content == tagContent
            }?.id
        })
        readItem.rate = rating
        modelData.updateReadModel(readItem)
    }
    
    func saveTag(_ tag: String) {
        if modelData.noteTagList.contains(where: { $0.content == tag }) {
            return
        }
        let tagModel = TagModel()
        tagModel.content = tag
        modelData.updateTagNote(tagModel)
    }
    
}

struct ReadTimeItem: Identifiable, Hashable {
    let time: Date
    
    var id: String {
        return time.timeIntervalSince1970.stringValue ?? ""
    }
}

#endif
