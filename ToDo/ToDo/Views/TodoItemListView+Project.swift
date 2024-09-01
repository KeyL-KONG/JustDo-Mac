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
    
//    var projectItems: [TodoProjectDetailItem] {
//        var detailItems = [TodoProjectDetailItem]()
//        let projectList = itemList.filter { $0.actionType == .project }
//        projectList.forEach { project in
//            let eventItems = modelData.itemList.filter { $0.projectId.count > 0 && $0.projectId == project.id  && $0.fatherId.isEmpty }.compactMap { event in
//                
//                let subDetailItems = modelData.itemList.filter { $0.fatherId.count > 0 && $0.fatherId == event.id }.compactMap { TodoProjectDetailItem(title: $0.title, item: $0)
//                }
//                return TodoProjectDetailItem(title: event.title, item: event, detailItems: subDetailItems)
//            }
//            let detailItem = TodoProjectDetailItem(title: project.title, item: project, detailItems: eventItems)
//            detailItems.append(detailItem)
//        }
//        return detailItems
//    }
    
    func projectItems(with tag: ItemTag) -> [TodoProjectDetailItem] {
        var detailItems = [TodoProjectDetailItem]()
        let projectList = itemList.filter { $0.actionType == .project && tag.id == $0.tag }
        projectList.forEach { project in
            let eventItems = modelData.itemList.filter { $0.projectId.count > 0 && $0.projectId == project.id  && $0.fatherId.isEmpty }.compactMap { event in
                
                let subDetailItems = modelData.itemList.filter { $0.fatherId.count > 0 && $0.fatherId == event.id }.compactMap { TodoProjectDetailItem(title: $0.title, item: $0)
                }
                print("sub detail items:\(subDetailItems.count)")
                return TodoProjectDetailItem(title: event.title, item: event, detailItems: subDetailItems)
            }
            let detailItem = TodoProjectDetailItem(title: project.title, item: project, detailItems: eventItems)
            detailItems.append(detailItem)
        }
        return detailItems
    }
    
    var tagList: [ItemTag] {
        modelData.tagList.sorted {  $0.priority > $1.priority }
    }
    
    func projectView() -> some View {
        return VStack {
            List(selection: $selectItemID) {
                ForEach(tagList, id: \.self) { tag in
                    let projectItems = projectItems(with: tag)
                    if projectItems.count > 0 {
                        Section(header: Text(tag.title)) {
                            ForEach(projectItems, id: \.self.item.id) { project in
                                DisclosureGroup {
                                    let detailItems = project.detailItems ?? []
                                    ForEach(detailItems, id:\.self.item.id) { detailItem in
                                        if let subItems = detailItem.detailItems, subItems.count > 0 {
                                            DisclosureGroup {
                                                ForEach(subItems, id: \.self.item.id) { subItem in
                                                    projectItemRowView(item: subItem.item)
                                                }
                                            } label: {
                                                projectItemRowView(item: detailItem.item)
                                            }


                                        } 
                                        else {
                                            projectItemRowView(item: detailItem.item)
                                        }
                                    }
                                } label: {
                                    projectItemRowView(item: project.item)
                                }

                            }
                        }
                    }
                }
                
            }
        }
    }
    
    func projectItemRowView(item: EventItem) -> some View {
        return itemRowView(item: item, showTag: false, showDeadline: false, showItemCount: true)
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
    
    func copyTaskItem(item: EventItem) {
        let newItem = EventItem()
        newItem.title = item.title
        newItem.actionType = item.actionType
        newItem.tag = item.tag
        newItem.projectId = item.projectId
        newItem.fatherId = item.fatherId
        newItem.importance = item.importance
        newItem.eventType = item.eventType
        newItem.rewardId = item.rewardId
        newItem.planTime = item.planTime
        modelData.updateItem(newItem)
    }
    
}
