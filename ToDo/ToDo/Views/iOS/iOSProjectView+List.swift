//
//  iOSProjectView+List.swift
//  ToDo
//
//  Created by LQ on 2025/7/20.
//

import SwiftUI

#if os(iOS)

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

extension iOSProjectView {
    
    var subItemList: [EventItem] {
        modelData.itemList.filter { item in
            return item.projectId.count > 0 || item.fatherId.count > 0
        }
    }
    
    func projectListView() -> some View {
        List {
            ForEach(tagList, id: \.self) { tag in
                let projectItems = projectItems(with: tag)
                if projectItems.count > 0 {
                    Section(header: HStack(content: {
                        Text(tag.title).bold().foregroundStyle(tag.titleColor)
                        Spacer()
                    })) {
                        ForEach(projectItems) { project in
                            recursiveItemView(item: project)
                        }
                    }
                }
            }
        }
    }
    
}

extension iOSProjectView {
    
    func projectItems(with tag: ItemTag) -> [TodoProjectDetailItem] {
        var detailItems = [TodoProjectDetailItem]()
        let projectList = modelData.itemList.filter { event in
            if self.showUnArchiOny && event.isArchive {
                return false
            }
            if self.showUnFinish && event.isFinish {
                return false
            }
            return event.actionType == .project && tag.id == event.tag && event.fatherId.isEmpty && event.projectId.isEmpty }
        
        // 用于追踪已处理的项目ID，防止循环引用
        var processedIds = Set<String>()
        
        // 递归函数用于构建子任务树
        func buildSubItems(for parentId: String) -> [TodoProjectDetailItem] {
            // 如果该ID已经处理过，直接返回空数组避免循环
            guard !processedIds.contains(parentId) else { return [] }
            
            // 将当前ID添加到已处理集合中
            processedIds.insert(parentId)
            
            let items = subItemList
                .filter { item in
                    if self.showUnArchiOny && item.isArchive {
                        return false
                    }
                    if self.showUnFinish && item.isFinish {
                        return false
                    }
                    return item.fatherId == parentId || item.projectId == parentId
                }
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
                    if self.showUnArchiOny && event.isArchive {
                        return false
                    }
                    if self.showUnFinish && event.isFinish {
                        return false
                    }
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
                    .padding(.leading, CGFloat(level) * 20)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
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
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
            )
        }
    }
    
    func projectItemRowView(item: EventItem) -> some View {
        ListItemRow(item: item) {
            Self.selectedItem = item
            self.showingSheet.toggle()
        } longPress: {
            
        }
    }
    
}

#endif
