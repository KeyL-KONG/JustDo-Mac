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
    
    var subItemList: [EventItem] {
        modelData.itemList.filter { $0.actionType == .task && $0.projectId.count > 0 }
    }
    
    func projectItems(with tag: ItemTag) -> [TodoProjectDetailItem] {
        var detailItems = [TodoProjectDetailItem]()
        let projectList = itemList.filter { $0.actionType == .project && tag.id == $0.tag }
        
        // 用于追踪已处理的项目ID，防止循环引用
        var processedIds = Set<String>()
        
        // 递归函数用于构建子任务树
        func buildSubItems(for parentId: String) -> [TodoProjectDetailItem] {
            // 如果该ID已经处理过，直接返回空数组避免循环
            guard !processedIds.contains(parentId) else { return [] }
            
            // 将当前ID添加到已处理集合中
            processedIds.insert(parentId)
            
            let items = subItemList
                .filter { $0.fatherId == parentId }
                .sorted(by: { event1, event2 in
                    if event1.isFinish, !event2.isFinish {
                        return true
                    } else if event2.isFinish, !event1.isFinish {
                        return false
                    } else {
                        return event1.planTime?.timeIntervalSince1970 ?? 0 >= event2.planTime?.timeIntervalSince1970 ?? 0
                    }
                })
                .compactMap { item in
                    // 递归获取当前项目的子任务
                    let subItems = buildSubItems(for: item.id)
                    return TodoProjectDetailItem(
                        title: item.title,
                        item: item,
                        detailItems: subItems
                    )
                }
            
            // 处理完后移除当前ID，允许其他分支使用
            processedIds.remove(parentId)
            
            return items
        }
        
        projectList.forEach { project in
            // 重置已处理ID集合
            processedIds.removeAll()
            
            // 获取项目的直接子任务（fatherId为空的）
            let eventItems = subItemList
                .filter { $0.projectId == project.id && $0.fatherId.isEmpty }
                .sorted(by: { event1, event2 in
                    if !event1.isFinish, event2.isFinish {
                        return true
                    } else if !event2.isFinish, event1.isFinish {
                        return false
                    } else {
                        return event1.planTime?.timeIntervalSince1970 ?? 0 >= event2.planTime?.timeIntervalSince1970 ?? 0
                    }
                })
                .compactMap { event in
                    // 为每个子任务构建其子任务树
                    let subItems = buildSubItems(for: event.id)
                    return TodoProjectDetailItem(
                        title: event.title,
                        item: event,
                        detailItems: subItems
                    )
                }
            
            let detailItem = TodoProjectDetailItem(
                title: project.title,
                item: project,
                detailItems: eventItems
            )
            detailItems.append(detailItem)
        }
        
        return detailItems
    }
    
    var tagList: [ItemTag] {
        modelData.tagList.sorted {  $0.priority > $1.priority }
    }
    
    func projectView() -> some View {
        VStack {
            List(selection: $selectItemID) {
                ForEach(tagList, id: \.self) { tag in
                    let projectItems = projectItems(with: tag)
                    if projectItems.count > 0 {
                        Section(header: Text(tag.title)) {
                            ForEach(projectItems) { project in
                                // 使用递归视图替换原来的嵌套 DisclosureGroup
                                recursiveItemView(item: project)
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

    
    private func recursiveItemView(item: TodoProjectDetailItem, level: Int = 0) -> AnyView {
        if let subItems = item.detailItems, !subItems.isEmpty {
            return AnyView(
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedItems.contains(item.id) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedItems.insert(item.id)
                            } else {
                                expandedItems.remove(item.id)
                            }
                        }
                    )
                ) {
                    if expandedItems.contains(item.id) {
                        ForEach(subItems) { subItem in
                            recursiveItemView(item: subItem, level: level + 1)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: expandedItems.contains(item.id) ? "chevron.down" : "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                            .frame(width: 20)
                            .onTapGesture {
                                    if expandedItems.contains(item.id) {
                                        expandedItems.remove(item.id)
                                    } else {
                                        expandedItems.insert(item.id)
                                    }
                                
                            }
                        
                        projectItemRowView(item: item.item)
                    }
                    .padding(.leading, CGFloat(level) * 20)
                }
            )
        } else {
            return AnyView(
                HStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 20)
                    
                    projectItemRowView(item: item.item)
                }
                .padding(.leading, CGFloat(level) * 20)
            )
        }
    }
    
}
