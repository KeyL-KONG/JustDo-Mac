//
//  ToDoEditPrincipleView.swift
//  ToDo
//
//  Created by LQ on 2025/4/13.
//

import SwiftUI

struct ToDoEditPrincipleView: View {
    
    @EnvironmentObject var modelData: ModelData
    var selectItem: PrincipleModel
    var selectionChange: ((String) -> ())
    
    @State var titleText: String = ""
    @State var selectedTag: String = ""
    
    var body: some View {
        VStack {
            List {
                Section {
                    TextEditor(text: $titleText)
                        .font(.system(size: 14))
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .background(Color.init(hex: "#e8f6f3"))
                        .frame(minHeight: 120)
                        .cornerRadius(8)
                }
                Section {
                    Picker("选择标签", selection: $selectedTag) {
                        ForEach(modelData.tagList.map({$0.title}), id: \.self) { title in
                            if let tag = modelData.tagList.first(where: { $0.title == title}) {
                                Text(tag.title).tag(tag)
                            }
                        }
                    }
                }
            }
        }
        .toolbar(content: {
            Spacer()
            Button("保存") {
                savePrincipleItem()
            }.foregroundColor(.blue)
        })
        .onAppear {
            self.titleText = selectItem.content
            if let tag = modelData.tagList.first(where: { $0.id == selectItem.tag }) {
                selectedTag = tag.title
            }
        }
    }
    
    func savePrincipleItem() {
        selectItem.content = titleText
        if let tag = modelData.tagList.first(where: { $0.title == selectedTag }) {
            selectItem.tag = tag.id
        } else {
            selectItem.tag = ""
        }
        modelData.updatePrincipleItem(selectItem)
    }
}
