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

struct CustomDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}

extension TodoItemListView {
    
    var subItemList: [EventItem] {
        modelData.itemList.filter { item in
            if taskFinishState == .finish && !item.isFinish && item.actionType == .task {
                return false
            } else if taskFinishState == .unfinish && item.isFinish && item.actionType == .task {
                return false
            }
            return item.projectId.count > 0 || item.fatherId.count > 0
        }
    }
    
    func projectItems(with tag: ItemTag) -> [TodoProjectDetailItem] {
        var detailItems = [TodoProjectDetailItem]()
        let projectList = itemList.filter { $0.actionType == .project && tag.id == $0.tag && $0.fatherId.isEmpty && $0.projectId.isEmpty }
        
        // 用于追踪已处理的项目ID，防止循环引用
        var processedIds = Set<String>()
        
        // 递归函数用于构建子任务树
        func buildSubItems(for parentId: String) -> [TodoProjectDetailItem] {
            // 如果该ID已经处理过，直接返回空数组避免循环
            guard !processedIds.contains(parentId) else { return [] }
            
            // 将当前ID添加到已处理集合中
            processedIds.insert(parentId)
            
            let items = subItemList
                .filter { $0.fatherId == parentId || $0.projectId == parentId }
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
                .filter { event in
                    if !event.fatherId.isEmpty {
                        return event.fatherId == project.id
                    } else {
                        return event.projectId == project.id
                    }
                }
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
            List {
                ForEach(tagList, id: \.self) { tag in
                    let projectItems = projectItems(with: tag)
                    if projectItems.count > 0 {
                        Section(header: Text(tag.title)) {
                            ForEach(projectItems) { project in
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
        item.planTime = .now
        item.setPlanTime = true
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectItemID = item.id
                    }
                    .padding(.leading, CGFloat(level) * 20)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectItemID == item.id ? Color.accentColor.opacity(0.1) : Color.clear)
                    )
                }
                    .disclosureGroupStyle(CustomDisclosureStyle())
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
                .contentShape(Rectangle())
                .onTapGesture {
                    selectItemID = item.id
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectItemID == item.id ? Color.accentColor.opacity(0.1) : Color.clear)
                )
            )
        }
    }
    
}
