//
//  iOSEditThinkView.swift
//  ToDo
//
//  Created by LQ on 2025/8/23.
//

import SwiftUI

struct iOSEditThinkView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Binding var showItem: Bool
    @State var item: NoteItem?
    @State var titleText: String = ""
    @State var contentText: String = ""
    @State var tags: [String] = []
    @State var selectTags: [String] = []
    @State var tagText: String = ""
    @State var tagTimes: [String: Int] = [:]
    
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case title
        case content
        case tag
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("")
                    .navigationBarTitle(Text("编辑想法"), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        showItem = false
                    }, label: {
                        Text("取消").bold()
                    }), trailing: Button(action: {
                        saveItem()
                        showItem = false
                    }, label: {
                        Text("保存").bold()
                    }))
                
                List {
                    Section {
                        TextField("标题", text: $titleText, axis: .vertical)
                            .focused($focusedField, equals: .title)
                            .padding(.horizontal, 12)  // 水平内边距
                            .padding(.vertical, 8)    // 垂直内边距
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))  // 背景色
                            )
                    }.listRowSeparator(.hidden)
                    
                    Section {
                        TextEditor(text: $contentText)
                            .font(.system(size: 14))
                            //.padding(10)
                            .scrollContentBackground(.hidden)
                            //.background(Color.blue.opacity(0.3))
                            .frame(minHeight: 150, maxHeight: .infinity)
                            //.cornerRadius(8)
                            .focused($focusedField, equals: .content)
                            .padding(.horizontal, 12)  // 水平内边距
                            .padding(.vertical, 8)    // 垂直内边距
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))  // 背景色
                            )
                    }.listRowSeparator(.hidden)
                        .padding(.top, 10)
                    
                    Section {
                        ZStack {
                            TextField("标签", text: $tagText, axis: .vertical)
                                .focused($focusedField, equals: .tag)
                                .padding(.horizontal, 12)  // 水平内边距
                                .padding(.vertical, 8)    // 垂直内边距
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))  // 背景色
                                )
                                .onChange(of: tagText) { oldValue, newValue in
                                    if tags.contains(where: { $0 == newValue }), !selectTags.contains(newValue) {
                                        selectTags.append(newValue)
                                    }
                                }
                                
                        }.overlay(alignment: .bottomTrailing) {
                            if tagText.count > 0 && !tags.contains(tagText) {
                                Spacer()
                                Button {
                                    addTag()
                                    tagText = ""
                                } label: {
                                    Text("添加").foregroundStyle(.blue)
                                }.padding(.vertical, 8)
                                    .padding(.trailing, 12)

                            }
                        }
                        
                        ScrollView {
                            MultiSelectTagListView(tags: tags, selectedTags: $selectTags)
                        }.frame(maxHeight: 150)
                        
                    }.listRowSeparator(.hidden)
                        .padding(.top, 10)
                }
                
                .listStyle(.plain)
            }
        }
        .onChange(of: tagText, { oldValue, newValue in
            updateTags()
        })
        .onAppear {
            updateTagTimes()
            updateData()
            if let item, item.tags.isEmpty {
                focusedField = .tag
            }
        }
    }
}

extension iOSEditThinkView {
    
    func updateData() {
        if let item {
            titleText = item.title
            contentText = item.content
            if item.tags.count > 0 {
                selectTags = modelData.noteTagList.filter({ tag in
                    item.tags.contains(tag.id)
                }).compactMap { $0.content }
            }
            tags = modelData.noteTagList.sorted(by: { first, second in
                return (self.tagTimes[first.id] ?? 0) >= (self.tagTimes[second.id] ?? 0)
            }).compactMap { $0.content }
        }
    }
    
    func addTag() {
        if modelData.noteTagList.contains(where: { tag in
            tag.content == tagText
        }) {
            return
        }
        let noteTag = TagModel()
        noteTag.content = tagText
        modelData.updateTagNote(noteTag)
    }
    
    func updateTags() {
        if item != nil {
            tags = (modelData.noteTagList.filter { tag in
                if tagText.isEmpty { return true }
                return tag.content.contains(tagText)
            }.sorted(by: { first, second in
                return (self.tagTimes[first.id] ?? 0) >= (self.tagTimes[second.id] ?? 0)
            }).compactMap { $0.content} + selectTags).uniqueArray
        }
    }
    
    func updateTagTimes() {
        var tagTimes = [String: Int]()
        modelData.noteItemList.compactMap { $0.tags }.reduce([], +).forEach { tag in
            if let times = tagTimes[tag] {
                tagTimes[tag] = times + 1
            } else {
                tagTimes[tag] = 1
            }
        }
        self.tagTimes = tagTimes
    }
    
    func saveItem() {
        let item = self.item ?? NoteItem()
        item.title = titleText
        item.content = contentText
        item.tags = selectTags.compactMap { tag in
            modelData.noteTagList.first { $0.content == tag}?.id }
        modelData.updateNoteItem(item)
    }
    
}
