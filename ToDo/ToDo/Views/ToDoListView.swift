//
//  ToDoListView.swift
//  ToDo
//
//  Created by LQ on 2024/8/10.
//

import SwiftUI
import LeanCloud

struct ToDoListView: View {
    
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel
    @State private var selection: ToDoSection = .today
    @State private var selectItem: EventItem? = nil
    @State private var selectItemID: String = ""
    @State private var toggleRefresh: Bool = false
    @State var selectionMode: TodoMode = .synthesis
    
    var itemList: [EventItem] {
        var itemList: [EventItem] = []
        
        switch selectionMode {
        case .synthesis:
            itemList = modelData.itemList
        case .work:
            itemList = modelData.itemList.filter({ event in
                guard let tag = modelData.tagList.first(where: { $0.id == event.tag }) else {
                    return false
                }
                return tag.title == "工作"
            })
        }
        
        switch selection {
        case .today:
            itemList = itemList.filter { event in
                guard let planTime = event.planTime else {
                    return false
                }
                return planTime.isInToday && event.actionType == .task
            }
        case .calendar:
            itemList = itemList.filter({ event in
                return event.actionType == .task
            })
        case .project:
            itemList = itemList.filter({ $0.actionType == .project })
        case .unplan:
            break
        case .recent:
            itemList = itemList.filter({ event in
                guard event.planTime != nil else {
                    return false
                }
                return event.actionType == .task
            })
        case .all:
            break
        case .list(let itemTag):
            itemList = itemList.filter { event in
                itemTag.id == event.tag && event.actionType == .task
            }
        }
        return itemList.sorted { first, second in
            if first.isFinish != second.isFinish {
                return first.isFinish ? false : true
            }
            else if first.importance.value != second.importance.value {
                return first.importance.value > second.importance.value
            }
            else if let firstTag = modelData.tagList.first(where: { $0.id == first.tag }), let secondTag = modelData.tagList.first(where: { $0.id == second.tag }), firstTag.priority != secondTag.priority {
                return firstTag.priority > secondTag.priority
            }
            else {
                return first.createTime?.timeIntervalSince1970 ?? 0 > second.createTime?.timeIntervalSince1970 ?? 0
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection).environmentObject(modelData)
                .onChange(of: selection) { oldValue, newValue in
                    if let selectItemID = itemList.first?.id, oldValue != newValue {
                        self.selectItemID = selectItemID
                        print("select section: \(selection.displayName), item: \(String(describing: itemList.first?.title))")
                    }
                }
        } content: {
            TodoItemListView(selection: selection, title: selection.displayName, items: itemList, selectItemID: $selectItemID, selectionMode: $selectionMode, addItemEvent: { item in
                selectItemID = item.id
            }, timerModel: timerModel).environmentObject(modelData)
                //.id(UUID().uuidString)
                .onChange(of: selectItemID) { oldValue, newValue in
                    if let item = modelData.itemList.first(where: { $0.id == newValue
                    }) {
                        self.selectItem = item
                        print("select item: \(item.title)")
                    }
                }
        } detail: {
            ToDoEditView(selectItem: selectItem, updateEvent: {
                toggleRefresh.toggle()
            }).environmentObject(modelData)
                .id(UUID().uuidString)
            
        }
        .onAppear {
            selectItemID = itemList.first?.id ?? ""
            print("select id: \(selectItemID), itemList count: \(itemList.count)")
        }
    }
    
    func updateItem(_ item: EventItem) {
        modelData.updateItem(item)
    }
}
