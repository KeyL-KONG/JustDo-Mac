//
//  ToDoListView.swift
//  ToDo
//
//  Created by LQ on 2024/8/10.
//

import SwiftUI
import LeanCloud

struct ToDoListView: View, Equatable {
    static func == (lhs: ToDoListView, rhs: ToDoListView) -> Bool {
        return lhs.timerModel.title == rhs.timerModel.title
    }
    
    @EnvironmentObject var modelData: ModelData
    @State var uniqueID: String = ""
    @ObservedObject var timerModel: TimerModel
    @State private var selection: ToDoSection = .today
    @State private var selectItem: BaseModel? = nil
    @State private var selectItemID: String = ""
    @State private var toggleRefresh: Bool = false
    @State var selectionMode: TodoMode = .synthesis
    @State var searchText: String = ""
    @State var selectedTask: BaseModel? {
        didSet {
            print("select task")
        }
    }
    
    var itemList: [EventItem] {
        return items(with: selection)
    }
    
    func items(with section: ToDoSection) -> [EventItem] {
        var itemList: [EventItem] = []
        
        if searchText.count > 0 {
            itemList = itemList.filter { $0.title.contains(searchText)}
        }
        
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
        
        switch section {
        case .today:
            itemList = itemList.filter { event in
                return !event.isArchive
            }
            break
        case .calendar:
            itemList = itemList.filter { event in
                return !event.isArchive
            }
            break
        case .project:
            itemList = itemList.filter({ $0.actionType == .project && !$0.isArchive })
        case .unplan:
            break
        case .recent:
            itemList = itemList.filter({ event in
                guard event.planTime != nil else {
                    return false
                }
                return event.actionType == .task && !event.isArchive
            })
        case .all:
            itemList = itemList.filter { $0.actionType != .tag }
        case .list(let itemTag):
            itemList = itemList.filter { event in
                itemTag.id == event.tag && event.actionType == .task
            }
        default:
            break
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
            SidebarView(selection: $selection, todayItems: items(with: .today)).environmentObject(modelData)
                .onChange(of: selection) { oldValue, newValue in
                    if let selectItemID = itemList.first?.id, oldValue != newValue {
                        self.selectItemID = selectItemID
                        print("select section: \(selection.displayName), item: \(String(describing: itemList.first?.title))")
                    }
                }
        } content: {
            if selection == .review {
                ReviewNewView(selectTaskChange: { task in
                    self.selectedTask = task
                })
                    .environmentObject(modelData)
                    .frame(minWidth: 400)
            } else {
                TodoItemListView(selection: selection, title: selection.displayName, items: itemList, selectItemID: $selectItemID, selectionMode: $selectionMode, addItemEvent: { item in
                    selectItemID = item.id
                }, timerModel: timerModel).environmentObject(modelData)
                    //.id(UUID().uuidString)
                    .onChange(of: selectItemID) { oldValue, newValue in
                        if let item = modelData.itemList.first(where: { $0.id == newValue
                        }) {
                            self.selectItem = item
                            toggleRefresh = !toggleRefresh
                            print("select item: \(item.title)")
                        } else if let item = modelData.summaryItemList.first(where: { $0.id == newValue }) {
                            self.selectItem = item
                            toggleRefresh = !toggleRefresh
                        }
                    }
                    .frame(minWidth: 1200)
            }
            
        } detail: {
            if selection == .review || selection == .summary {
                if let selectedTask, let eventItem = modelData.itemList.first(where: { $0.id == selectedTask.id
                }) {
                    ToDoEditView(selectItem: eventItem) {
                        toggleRefresh.toggle()
                    }.environmentObject(modelData).id(eventItem.id)
                } else if let selectedTask, let rewardItem = modelData.rewardList.first(where: { $0.id == selectedTask.id }) {
                    EditRewardView(selectedItem: rewardItem).environmentObject(modelData).id(rewardItem.id)
                }
                else if let selectedTask, let summaryItem = modelData.summaryItemList.first(where: { $0.id == selectedTask.id
                }) {
                    SummaryEditView(summaryItem: summaryItem).id(summaryItem.id).environmentObject(modelData)
                }
                else {
                    EmptyView()
                }
                
            } else {
                if let eventItem = selectItem as? EventItem {
                    ToDoEditView(selectItem: eventItem, updateEvent: {
                        //modelData.notifyEventItemsUpdate()
                    }).environmentObject(modelData)
                        .id(selectItemID)
                        .frame(minWidth: 400)
                } else if let summaryItem = selectItem as? SummaryItem {
                    SummaryEditView(summaryItem: summaryItem)
                        .environmentObject(modelData).id(selectItemID)
                }
                
            }
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
