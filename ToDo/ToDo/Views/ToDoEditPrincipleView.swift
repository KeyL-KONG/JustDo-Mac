//
//  ToDoEditPrincipleView.swift
//  ToDo
//
//  Created by LQ on 2025/4/13.
//

import SwiftUI

struct ToDoEditPrincipleView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Binding var selectItemID: String
    var selectItem: PrincipleModel
    var selectionChange: ((String) -> ())
    
    @State var titleText: String = ""
    @State var selectedTag: String = ""
    
    var taskTimeItems: [TaskTimeItem] {
        modelData.taskTimeItems.filter { item in
            return item.eventId == selectItem.id
        }.sorted(by: {
            $0.startTime.timeIntervalSince1970 > $1.startTime.timeIntervalSince1970
        })
    }
    
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
                
                Section {
                    ForEach(taskTimeItems) { item in
                        TimeLineRowView(selectItemID: $selectItemID,
                            item: item,
                            isEditing: Binding(
                                get: { return modelData.isEditing(id: item.id) },
                                set: { value in
                                    modelData.markEdit(id: item.id, edit: value)
                                }
                            ), onlyStarTime: true
                        )
                        .contextMenu {
                            Button(role: .destructive) {
                                // 添加删除确认弹窗
                                modelData.deleteTimeItem(item)
                            } label: {
                                Text("删除").foregroundColor(.red)
                            }
                
                        }
                    }
                } header: {
                    HStack(alignment: .center) {
                        Text("事件记录")
                        Spacer()
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
