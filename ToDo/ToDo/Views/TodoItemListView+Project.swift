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
            let eventItems = modelData.itemList.filter { $0.projectId.count > 0 && $0.projectId == project.id  && $0.fatherId.isEmpty }.compactMap { event in
                
                let subDetailItems = modelData.itemList.filter { $0.fatherId.count > 0 && $0.fatherId == event.id }.compactMap { TodoProjectDetailItem(title: $0.title, item: $0)
                }
                return TodoProjectDetailItem(title: event.title, item: event, detailItems: subDetailItems)
            }
            eventItems.forEach { detailItem in
                
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
                    ForEach(projectItems, id: \.self.item.id) { project in
                        DisclosureGroup {
                            let detailItems = project.detailItems ?? []
                            ForEach(detailItems, id:\.self.item.id) { detailItem in
                                if let subItems = detailItem.detailItems, subItems.count > 0 {
//                                    ForEach(subItems, id: \.self.item.id) { subItem in
//                                        DisclosureGroup {
//                                            
//                                        } label: {
//                                            
//                                        }
//                                    }
                                    
                                    DisclosureGroup {
                                        ForEach(subItems, id: \.self.item.id) { subItem in
                                            itemRowView(item: subItem.item, showDeadline: false)
                                        }
                                    } label: {
                                        itemRowView(item: detailItem.item, showDeadline: false)
                                    }


                                } else {
                                    itemRowView(item: detailItem.item, showDeadline: false)
                                }
                            }
                        } label: {
                            itemRowView(item: project.item, showDeadline: false)
                        }

                    }
                }
            }
        }
    }
    
    func addProjectSubItem(root: EventItem) {
        let item = EventItem()
        item.title = "新建子任务"
        if root.actionType == .task {
            item.projectId = root.projectId
            item.fatherId = root.id
        } else {
            item.projectId = root.id
        }
        item.actionType = .task
        item.tag = root.tag
        modelData.updateItem(item)
    }
    
}
