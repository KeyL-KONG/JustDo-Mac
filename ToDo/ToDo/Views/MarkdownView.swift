//
//  MarkdownView.swift
//  ToDo
//
//  Created by LQ on 2025/4/3.
//

import SwiftUI
#if os(macOS)
struct MarkdownView: View {
    
    @EnvironmentObject var modelData: ModelData
    @State var isEditingMark: Bool = false
    @State var mark: String = ""
    @State var toggleToRefresh: Bool = false
    
    @State var item: EventItem
    
    var body: some View {
        ScrollView {
            VStack {
                if toggleToRefresh {
                    Text("")
                } else {
                    Text("")
                }
                if isEditingMark {
                    HStack {
                        TextEditor(text: $mark)
                            .font(.system(size: 14))
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(Color.init(hex: "#e8f6f3"))
                            .cornerRadius(8)
                            .frame(minHeight: 400)
                        Spacer()
                        VStack {
                            MarkdownWebView(mark, itemId: item.id)
                            Spacer()
                        }
                        .frame(minHeight: 400)
                    }
                } else {
                    MarkdownWebView(mark, itemId: item.id)
                }
                Spacer()
            }
            .padding()
            .background(isEditingMark ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
            .cornerRadius(10)
        }
            
        .onAppear {
            mark = item.mark
            isEditingMark = true
            addObservers()
        }
        .onDisappear(perform: {
            saveItem()
        })
        .toolbar() {
            HStack {
                Text(item.title)
                Spacer()
                Button("\(isEditingMark ? "保存" : "编辑")") {
                    self.isEditingMark.toggle()
                    if !self.isEditingMark {
                        saveItem()
                    }
                }
            }
        }
    }
    
    func saveItem() {
        print("save item")
        item.mark = mark
        modelData.updateItem(item)
    }
    
}

extension MarkdownView {
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
                    self.mark = self.mark + url.formatImageUrl
                    self.toggleToRefresh.toggle()
                    print("upload data success: \(url.formatImageUrl)")
                }
            }
        }
    }
#endif
}

#endif
