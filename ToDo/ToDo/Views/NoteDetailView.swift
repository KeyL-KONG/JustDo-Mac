//
//  NoteDetailView.swift
//  ToDo
//
//  Created by LQ on 2025/5/28.
//

import SwiftUI

struct NoteDetailView: View {
    
    @State var isEdit: Bool = false
    @State var isWindow: Bool = false
    @State var noteItem: NoteModel
    @EnvironmentObject var modelData: ModelData
    @State var noteTitle: String = ""
    @State var noteContent: String = "" {
        didSet {
            print("note content change: \(noteContent)")
        }
    }
    @State var noteTags: [String] = []
    @State var toggleToRefresh: Bool = false
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ScrollView {
            VStack {
                if toggleToRefresh {
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
                }
                
                if isEdit {
                    HStack {
                        TextField("标题", text: $noteTitle)
                    }
                }
                
                if isEdit {
                    if isWindow {
                        HStack {
                            TextEditor(text: $noteContent)
                                .font(.system(size: 14))
                                .padding(10)
                                .scrollContentBackground(.hidden)
                                .background(Color.init(hex: "#e8f6f3"))
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
                        TextEditor(text: $noteContent)
                            .font(.system(size: 14))
                            .padding()
                            .scrollContentBackground(.hidden)
                            .background(Color.init(hex: "f8f9f9"))
                            .cornerRadius(10)
                            .frame(minHeight: 400)
                    }
                    
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
        .onAppear {
            self.noteContent = noteItem.content
            self.noteTitle = noteItem.title
            self.noteTags = noteItem.tags.compactMap({ tagId in
                modelData.noteTagList.first {
                    $0.id == tagId
                }?.content
            })
            self.addObservers()
        }
    }
}

extension NoteDetailView {
    
    // 修改按钮响应方法
    private func showNoteWindow() {
        openWindow(id: CommonDefine.noteWindow, value: noteItem)
    }
    
    func saveItem() {
        noteItem.content = noteContent
        noteItem.tags = noteTags.compactMap({ tagContent in
            modelData.noteTagList.first {
                $0.content == tagContent
            }?.id
        })
        noteItem.title = noteTitle
        modelData.updateNote(noteItem)
    }
    
    func saveTag(_ tag: String) {
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
        if let data = image.toData() {
            CloudManager.shared.upload(with: data) { url, error in
                if let error = error {
                    print("upload data failed: \(error)")
                } else if let url = url {
                    self.noteContent += url.formatImageUrl
                    self.toggleToRefresh.toggle()
                    print("upload data success: \(url.formatImageUrl)")
                }
            }
        }
    }
#endif
    
    
}
