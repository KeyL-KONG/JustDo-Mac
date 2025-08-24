//
//  iOSThinkListView.swift
//  ToDo
//
//  Created by LQ on 2025/8/23.
//

import SwiftUI

struct iOSThinkListView: View {
    @EnvironmentObject var modelData: ModelData
    @State var summaryText: String = ""
    @State var inputHeight: CGFloat = 0.0
    @State var noteItems: [NoteItem] = []
    @State var showDeleteAlert: Bool = false
    static var deleteItem: NoteItem?
    @State var showSelectedItem: Bool = false
    static var selectedItem: NoteItem?
    
    @State var noteTags: [String] = []
    @State var selectedTag: String?
    @State var tagTimes: [String: Int] = [:]
    
    let allNoteTag = "所有"
    let unListTag = "未整理"
    
    var body: some View {
        VStack {
            HorizontalTagListView(tags: noteTags, selectedTag: $selectedTag)
            
            List {
                ForEach(noteItems, id: \.self.id) { item in
                    Section {
                        itemView(item)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: {
                                Self.selectedItem = item
                                showSelectedItem.toggle()
                            })
                            .swipeActions {
                                Button {
                                    Self.deleteItem = item
                                    self.showDeleteAlert.toggle()
                                } label: {
                                    Text("删除").foregroundStyle(.red)
                                }.tint(.red)
                            }
                    }.padding(.top, 5)
                        .padding(.bottom, 20)
                        .background(alignment: .bottomTrailing) {
                            HStack {
                                let tags = item.tags.compactMap { tagId in modelData.noteTagList.first { $0.id == tagId}?.content }
                                
                                if tags.count > 0 {
                                    TagList(tags: tags) { tag in
                                        Text(tag)
                                            .font(.system(size: 8))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(.blue)
                                            .clipShape(RoundedRectangle(cornerRadius: 3))
                                    }
                                }
                                
                                Spacer()
                                let timeStr = item.createTime!.simpleDateStr
                                Text(timeStr).font(.system(size: 12)).foregroundColor(.secondary)
                            }
                            .offset(y: 5)
                        }
                }
            }
            
            Spacer()
            
            HStack(spacing: 8, content: {
#if os(iOS)
                ResizableTF(txt: $summaryText, height: $inputHeight).frame(height: self.inputHeight < 150 ? self.inputHeight : 150)
                    .padding(.horizontal)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                #endif
                
                Button(action: {
                    saveNoteItem()
                    endEdit()
                    self.summaryText = ""
                }, label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(10)
                })
            })
            .padding(.horizontal)
            .padding(.vertical)
        }
        .alert("删除想法", isPresented: $showDeleteAlert, actions: {
            Button {
                showDeleteAlert = false
            } label: {
                Text("取消").foregroundStyle(.gray)
            }.tint(.gray)
            
            Button {
                if let deleteItem = Self.deleteItem {
                    modelData.deleteNoteItem(deleteItem)
                    Self.deleteItem = nil
                }
            } label: {
                Text("删除").foregroundStyle(.red)
            }.tint(.red)

        }, message: {
            let title = (Self.deleteItem?.content ?? "").truncated(limit: 15)
            Text("是否删除 <\(title)>")
        })
        .onChange(of: modelData.updateNoteItemIndex, { oldValue, newValue in
            self.updateTagTimes()
            self.updateItems()
        })
        .onChange(of: modelData.updateNoteTagIndex, { old, new in
            self.updateTagTimes()
            self.updateTags()
            self.updateItems()
        })
        .onChange(of: selectedTag, { oldValue, newValue in
            self.updateItems()
        })
        .sheet(isPresented: $showSelectedItem, content: {
            if let item = Self.selectedItem {
                iOSEditThinkView(showItem: $showSelectedItem, item: item)
                    .environmentObject(modelData)
            }
        })
        .onAppear {
            self.updateTagTimes()
            self.updateTags()
            self.selectedTag = allNoteTag
            self.updateItems()
        }
    }
}

extension iOSThinkListView {
    
    func itemView(_ item: NoteItem) -> some View {
        VStack {
            HStack {
                Text(item.content).font(.system(size: 16)).foregroundColor(.black).multilineTextAlignment(.leading)
                    .contentShape(Rectangle())
                Spacer()
            }
        }
    }
    
    func saveNoteItem() {
        let noteItem = NoteItem()
        noteItem.content = summaryText
        modelData.updateNoteItem(noteItem)
    }
    
    func updateTags() {
        self.noteTags = [allNoteTag, unListTag] + modelData.noteTagList.filter({ tag in
            return self.tagTimes[tag.id] != nil
        }).sorted(by: { first, second in
            return (self.tagTimes[first.id] ?? 0) >= (self.tagTimes[second.id] ?? 0)
        }).compactMap { tag in
            if let time = self.tagTimes[tag.id] {
                return tag.content + " \(time)"
            }
            return tag.content
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
    
    func updateItems() {
        self.noteItems = modelData.noteItemList.filter({ item in
            if selectedTag == allNoteTag {
                return true
            }
            if selectedTag == unListTag {
                return item.tags.isEmpty
            }
            if let selectedTag = modelData.noteTagList.first(where: {  tag in
                return self.selectedTag?.contains(tag.content) ?? false
            }) {
                return item.tags.contains(selectedTag.id)
            }
            return false
        }).sorted(by: { ($0.createTime?.timeIntervalSince1970 ?? 0) > ($1.createTime?.timeIntervalSince1970 ?? 0)
        })
    }
    
    func endEdit() {
#if os(iOS)
        UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
        #endif
    }
    
}
