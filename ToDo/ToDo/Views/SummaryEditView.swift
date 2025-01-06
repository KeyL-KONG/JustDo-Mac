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
    
    var body: some View {
        VStack {
            List {
                Section {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $summaryContent)
                            .font(.system(size: 14))
                        
                        if summaryContent.isEmpty {
                            Text("在这里快速添加新的感想")
                                .foregroundColor(Color(.placeholderTextColor))
                                .padding(.top, 1)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
                    .border(.blue, width: 1)
                    .frame(minHeight: 100)
                }
            }
        }.onAppear {
            summaryContent = summaryItem.content
        }
        .toolbar(content: {
            Spacer()
            Button("保存") {
                saveSummaryItem()
            }.foregroundColor(.blue)
        })
    }
    
    func saveSummaryItem() {
        summaryItem.content = summaryContent
        modelData.saveSummaryItem(summaryItem)
    }
    
}
