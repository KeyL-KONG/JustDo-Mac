//
//  ToDoItemListView+Principle.swift
//  ToDo
//
//  Created by LQ on 2025/4/13.
//

import SwiftUI

extension TodoItemListView {
    
    var principleItems: [PrincipleModel] {
        modelData.principleItems
    }
    
    var ungroupPrincipleItems: [PrincipleModel] {
        modelData.principleItems.filter { $0.tag.isEmpty }
    }
    
    func principleView() -> some View {
        List(selection: $selectItemID) {
            let tags = modelData.tagList
            ForEach(tags) { tag in
                let items = principleItems.filter { $0.tag == tag.id }
                if items.count > 0 {
                    Section(header: Text(tag.title)) {
                        ForEach(items, id: \.id) { item in
                            principleItemView(item)
                                .tag(item.id)
                        }
                    }
                }
            }
            
            if ungroupPrincipleItems.count > 0 {
                Section {
                    ForEach(ungroupPrincipleItems, id: \.id) { item in
                        principleItemView(item)
                        .tag(item.id)
                    }
                } header: {
                    Text("未分组")
                }
            }
        }
    }
    
    func principleItemView(_ item: PrincipleModel) -> some View {
        HStack {
            Text(item.content)
            Spacer()
        }
    }
    
    func addNewPrincipleItem() {
        let item = PrincipleModel()
        item.content = "新原则"
        modelData.updatePrincipleItem(item)
    }
    
}
