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
                            .frame(minHeight: 120)
                            .cornerRadius(8)
                    } else {
                        Text(summaryContent)
                            .background(Color.init(hex: "#d6eaf8"))
                            .cornerRadius(8)
                            .padding(10)
                            .frame(minHeight: 120)
                    
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
        }
        .toolbar(content: {
            Spacer()
            let text = isEditing ? "保存" : "编辑"
            Button(text) {
                if isEditing {
                    saveSummaryItem()
                }
            }.foregroundColor(.blue)
        })
    }
    
    func saveSummaryItem() {
        summaryItem.content = summaryContent
        modelData.saveSummaryItem(summaryItem)
    }
    
}
