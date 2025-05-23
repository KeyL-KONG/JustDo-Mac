//
//  MarkdownView.swift
//  ToDo
//
//  Created by LQ on 2025/4/3.
//

import SwiftUI

struct MarkdownView: View {
    
    @EnvironmentObject var modelData: ModelData
    @State var isEditingMark: Bool = false
    @State var mark: String = ""
    
    @State var item: EventItem
    
    var body: some View {
        ScrollView {
            VStack {
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
