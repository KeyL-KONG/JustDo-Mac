//
//  NoteQuickView.swift
//  ToDo
//
//  Created by ByteDance on 2025/6/3.
//

import SwiftUI

struct NoteQuickView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Environment(\.dismiss) var dismiss
    
    @State var titleText: String = ""
    @State var contentText: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("标题", text: $titleText)
            }.padding()
            
            HStack(alignment: .top) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 3)
                    .frame(height: 80)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $contentText)
                        .font(.system(size: 14))
                        .onChange(of: contentText) { newValue in
                            if newValue.contains("\n") {
                                contentText = newValue.replacingOccurrences(of: "\n", with: "")
                                addNoteItem()
                            }
                        }
                        .onSubmit {
                            addNoteItem()
                        }
                        .background(
                            Button(action: addNoteItem) {}
                                .frame(width: 0, height: 0)
                                .opacity(0)
                                .keyboardShortcut(.return)
                        )
                    
                    if contentText.isEmpty {
                        Text("在这里快速添加新的笔记")
                            .foregroundColor(Color(.placeholderTextColor))
                            .padding(.top, 1)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: 20)
                .padding(.top, 5)
                
                Button {
                    addNoteItem()
                } label: {
                    Image(systemName: "return")
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
                .buttonStyle(BorderlessButtonStyle())
                
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
    }
    
    func addNoteItem() {
        let note = NoteModel()
        note.title = titleText
        note.content = contentText
        modelData.updateNote(note)
        titleText = ""
        contentText = ""
        dismiss()
    }
}
