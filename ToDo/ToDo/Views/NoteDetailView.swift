//
//  NoteDetailView.swift
//  ToDo
//
//  Created by LQ on 2025/5/28.
//

import SwiftUI

struct NoteDetailView: View {
    
    @State var isEdit: Bool = false
    @State var noteItem: NoteModel
    @EnvironmentObject var modelData: ModelData
    @State var noteContent: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    if isEdit {
                        RemovableTagListView(showCloseButton: true, tags:noteItem.tags, addTagEvent: { tag in
                            
                        }, removeTagEvent: { tag in
                            
                        }, selectTagEvent: { tags in
                            
                        }).environmentObject(modelData)
                    } else {
                        RemovableTagListView(showCloseButton: false, tags: noteItem.tags)
                            .environmentObject(modelData)
                    }
                    Spacer()
                }
                
                if isEdit {
                    TextEditor(text: $noteContent)
                        .font(.system(size: 14))
                        .padding()
                        .scrollContentBackground(.hidden)
                        .background(Color.init(hex: "f8f9f9"))
                        .cornerRadius(10)
                        .frame(minHeight: 400)
                } else if noteContent.count > 0 {
                    MarkdownWebView(noteContent, itemId: noteItem.id)
                        .padding()
                        .background(Color.init(hex: "d4e6f1"))
                        .cornerRadius(10)
                }
                
                Spacer()
                
            }
        }
        
        .toolbar {
            Button("\(isEdit ? "保存" : "编辑")") {
                self.isEdit.toggle()
                if !self.isEdit {
                    saveItem()
                }
            }
            
            Button("添加") {
                let note = NoteModel()
                note.title = "新建笔记"
                modelData.updateNote(note)
            }
        }
        .onAppear {
            self.noteContent = noteItem.content
        }
    }
}

extension NoteDetailView {
    
    func saveItem() {
        noteItem.content = noteContent
        modelData.updateNote(noteItem)
    }
    
}
