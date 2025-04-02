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
            VStack {
                if isEditingMark {
                    TextEditor(text: $mark)
                        .font(.system(size: 14))
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .background(Color.init(hex: "#e8f6f3"))
                        .cornerRadius(8)
                } else {
                    MarkdownWebView(mark)
                }
                Spacer()
            }
            .padding()
            .background(isEditingMark ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
            .cornerRadius(10)
            .onAppear {
            mark = item.mark
            isEditingMark = true
        }
        .toolbar() {
            HStack {
                Text(item.title)
                Spacer()
                Button("\(isEditingMark ? "完成" : "编辑")") {
                    self.isEditingMark.toggle()
                    if !self.isEditingMark {
                        saveItem()
                    }
                }
            }
        }
    }
    
    func saveItem() {
        item.mark = mark
        modelData.updateItem(item)
    }
    
}
