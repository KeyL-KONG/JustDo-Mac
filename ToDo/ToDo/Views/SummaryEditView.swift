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
    @State var selectedTag: String = ""
    
    @State var isEditing: Bool = true
    
    var summaryTagListTitle: [String] {
        modelData.summaryTagList.compactMap { $0.content }
    }
    
    var body: some View {
        VStack {
            List {
                Section {
                    if isEditing {
                        TextEditor(text: $summaryContent)
                            .font(.system(size: 14))
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(Color.init(hex: "#e8f6f3"))
                            .frame(minHeight: 120, maxHeight: 500)
                            .cornerRadius(8)
                    } else {
                        MarkdownWebView(summaryContent, itemId: summaryItem.id)
                            .background(Color.init(hex: "#d6eaf8"))
                            .cornerRadius(8)
                            .padding(10)
                            .frame(minHeight: 120, maxHeight: 500)
                    
                    }
                }
                
                Section(header: Text("设置")) {
                    VStack {
                        HStack {
                            
                        }
                    }
                }
            }
        }.onAppear {
            summaryContent = summaryItem.content
            isEditing = summaryContent.isEmpty
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
        modelData.saveSummaryItem(summaryItem)
    }
    
}
