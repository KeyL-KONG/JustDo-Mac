//
//  MacEditReadItemView.swift
//  ReadList
//
//  Created by ByteDance on 2023/9/24.
//

import SwiftUI

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
    
    @State var selectTag: String = ""
    @State var rating: Double = 0.0
    
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
                
                Section("标签") {
    
                    Picker("", selection: $selectTag) {
                        ForEach(modelData.readTagList.map({$0.type}), id: \.self) { title in
                            Text(title).tag(title)
                        }
                    }

                }
                
                Section("评价") {
                    RatingView(maxRating: 5, rating: $rating).previewLayout(.sizeThatFits)
                }
                
//                if finishTimes.count > 0 {
//                    Section("记录") {
//                        ForEach(finishTimes, id: \.self) { item in
//                            HStack {
//                                Text("已读")
//                                Spacer()
//                                Text(item.time.simpleDateStr)
//                            }
//                            .contextMenu {
//                                Button(role: .destructive) {
//                                    if let removeIndex = readItem.finishTimes.firstIndex(where: { $0.timeIntervalSince1970 == item.time.timeIntervalSince1970
//                                    }) {
//                                        readItem.finishTimes.remove(at: removeIndex)
//                                        modelData.updateModel(readItem)
//                                    }
//                                } label: {
//                                    Text("删除").foregroundColor(.red)
//                                }
//                            }
//                        }
//                    }
//                }
                
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
            }
            .listStyle(.plain)
        }
        .onAppear {
            urlText = readItem.url
            titleText = readItem.title
            contentText = readItem.note
            focusedField = .content
            selectTag = readItem.tag
            rating = readItem.rate
            
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
        readItem.tag = selectTag
        readItem.rate = rating
        modelData.updateReadModel(readItem)
    }
    
}

struct ReadTimeItem: Identifiable, Hashable {
    let time: Date
    
    var id: String {
        return time.timeIntervalSince1970.stringValue ?? ""
    }
}
