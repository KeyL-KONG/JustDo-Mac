//
//  SummaryEditView.swift
//  ToDo
//
//  Created by LQ on 2025/1/4.
//

import SwiftUI

struct SummaryEditView: View {
    
    @EnvironmentObject var modelData: ModelData
    var summaryItem: SummaryItem
    @State var summaryContent: String = ""
    @State var summaryTags: [String] = []
    
    @State var isEditing: Bool = true
    
    var summaryTagListTitle: [String] {
        modelData.summaryTagList.compactMap { $0.content }
    }
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("标签")) {
                    HStack {
                        if isEditing {
                            RemovableTagListView(showCloseButton: true, tags:summaryTags, addTagEvent: { tag in
                                self.summaryTags.append(tag)
                                self.saveTag(tag)
                            }, removeTagEvent: { tag in
                                self.summaryTags.removeAll { $0 == tag }
                            }, selectTagEvent: { tags in
                                self.summaryTags += tags
                            }).environmentObject(modelData)
                        } else if summaryTags.count > 0 {
                            RemovableTagListView(showCloseButton: false, tags: summaryTags)
                                .environmentObject(modelData)
                        }
                        Spacer()
                    }
                }
                
                Section(header: Text("内容")) {
                    HStack {
                        if isEditing {
                            TextEditor(text: $summaryContent)
                                .font(.system(size: 14))
                                .padding(10)
                                .background(Color.init(hex: "#e8f6f3"))
                                .scrollContentBackground(.hidden)
                                .cornerRadius(8)
                        } else {
                            MarkdownWebView(summaryContent, itemId: summaryItem.id)
                                .padding(10)
                                .cornerRadius(8)
                        }
                    }.background((isEditing ? Color.init(hex: "#e8f6f3") : Color.init(hex: "#d6eaf8")))
                        .padding(5)
                        
                }
                
//                Section(header: Text("设置")) {
//                    VStack {
//                        HStack {
//                            
//                        }
//                    }
//                }
            }
        }.onAppear {
            summaryContent = summaryItem.content
            isEditing = summaryContent.isEmpty
            summaryTags = summaryItem.tags.compactMap({ tagId in
                modelData.noteTagList.first {
                    $0.id == tagId
                }?.content
            })
        }
        .toolbar(content: {
            Spacer()
            let text = isEditing ? "保存" : "编辑"
            Button(text) {
                if isEditing {
                    saveSummaryItem()
                }
                self.isEditing = !self.isEditing
            }.foregroundColor(.blue)
        })
    }
    
    func saveSummaryItem() {
        summaryItem.content = summaryContent
        summaryItem.tags = summaryTags.compactMap({ tagContent in
            modelData.noteTagList.first {
                $0.content == tagContent
            }?.id
        })
        modelData.updateSummaryItem(summaryItem)
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
