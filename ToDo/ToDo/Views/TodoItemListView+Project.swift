//
//  TodoItemListView+Project.swift
//  ToDo
//
//  Created by LQ on 2024/8/12.
//

import SwiftUI

struct TodoProjectDetailItem: Identifiable {
    let title: String
    var item: EventItem
    var detailItems: [TodoProjectDetailItem]? = nil
    
    var id: String {
        return item.id
    }
}

extension TodoItemListView {
    
    var projectItems: [TodoProjectDetailItem] {
        var detailItems = [TodoProjectDetailItem]()
        let projectList = modelData.itemList.filter { $0.actionType == .project }
        projectList.forEach { project in
            let eventItems = modelData.itemList.filter { $0.projectId.count > 0 && $0.projectId == project.id }.compactMap { event in
                return TodoProjectDetailItem(title: event.title, item: event)
            }
            let detailItem = TodoProjectDetailItem(title: project.title, item: project, detailItems: eventItems)
            detailItems.append(detailItem)
        }
        return detailItems
    }
    
    func projectView() -> some View {
        return VStack {
            List(selection: $selectItemID) {
                Section {
                    ForEach(projectItems, id: \.id) { project in
                        DisclosureGroup {
                            ForEach(project.detailItems?.compactMap{ $0.item} ?? [], id:\.id) { item in
                                itemRowView(item: item, showDeadline: false)
                            }
                        } label: {
                            itemRowView(item: project.item, showDeadline: false)
                        }

                    }
                }
            }
        }
    }
    
}
