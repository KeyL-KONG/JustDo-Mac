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
    @State private var selectItem: BaseModel? = nil {
        didSet {
            print("select item change: \((selectItem as? EventItem)?.title)")
        }
    }
    @State private var selectItemID: String = "" {
        didSet {
            print("select item id: \(selectItemID)")
        }
    }
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
                    if oldValue != newValue {
                        if selection == .principle, let selectId = modelData.principleItems.first?.id {
                            self.selectItemID = selectId
                        } else if let selectId = itemList.first?.id {
                            self.selectItemID = selectId
                        }
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
                TodoItemListView(selection: selection, title: selection.displayName, itemList: itemList, selectItemID: $selectItemID, selectionMode: $selectionMode, addItemEvent: { item in
                    selectItemID = item.id
                }, timerModel: timerModel).environmentObject(modelData)
                    //.id(UUID().uuidString)
                    .onChange(of: selectItemID) { oldValue, newValue in
                        func update() {
                            if let item = modelData.itemList.first(where: { $0.id == newValue
                            }) {
                                self.selectItem = item
                                toggleRefresh = !toggleRefresh
                                print("select item: \(item.title)")
                            } else if let item = modelData.summaryItemList.first(where: { $0.id == newValue }) {
                                self.selectItem = item
                                toggleRefresh = !toggleRefresh
                            } else if let item = modelData.principleItems.first(where: {  $0.id == newValue
                            }) {
                                self.selectItem = item
                                toggleRefresh.toggle()
                            }
                        }
                        if Thread.isMainThread {
                            update()
                        } else {
                            DispatchQueue.main.async {
                                update()
                            }
                        }
                        
                    }
                    .frame(minWidth: 600)
            }
            
        } detail: {
            if let selectedTask, selection == .review || selection == .summary || selection == .principle {
                if let eventItem = modelData.itemList.first(where: { $0.id == selectedTask.id
                }) {
                    ToDoEditView(selectItem: eventItem, selectionChange: { selectId in
                        self.selectItemID = selectId
                    }, updateEvent: {
                        toggleRefresh.toggle()
                    }).environmentObject(modelData).id(eventItem.id)
                        .frame(minWidth: 400)
                } else if let rewardItem = modelData.rewardList.first(where: { $0.id == selectedTask.id }) {
                    EditRewardView(selectedItem: rewardItem).environmentObject(modelData).id(rewardItem.id)
                }
                else if let summaryItem = modelData.summaryItemList.first(where: { $0.id == selectedTask.id
                }) {
                    SummaryEditView(summaryItem: summaryItem).id(summaryItem.id).environmentObject(modelData)
                } else if let principleItem = selectedTask as? PrincipleModel {
                    ToDoEditPrincipleView(selectItem: principleItem) { selectId in
                        selectItemID = selectId
                    }
                    .id(principleItem.id)
                    .environmentObject(modelData)
                }
                else {
                    EmptyView()
                }
                
            } else {
                if let eventItem = currentSelectItem() as? EventItem {
                    ToDoEditView(selectItem: eventItem, selectionChange: { selectId in
                        self.selectItemID = selectId
                    }, updateEvent: {
                        
                    }).environmentObject(modelData)
                        .id(selectItemID)
                        .frame(minWidth: 400)
                } else if let summaryItem = currentSelectItem() as? SummaryItem {
                    SummaryEditView(summaryItem: summaryItem)
                        .environmentObject(modelData).id(selectItemID)
                } else if let principleItem = currentSelectItem() as? PrincipleModel {
                    ToDoEditPrincipleView(selectItem: principleItem) { selectId in
                        selectItemID = selectId
                    }
                    .environmentObject(modelData)
                    .id(selectItemID)
                }
                else {
                    Text("empty")
                }
                
            }
        }
        .onAppear {
            selectItemID = itemList.first?.id ?? ""
            print("select id: \(selectItemID), itemList count: \(itemList.count)")
        }
    }
    
    func currentSelectItem() -> BaseModel? {
        if let selectItem, selectItemID.count > 0 {
            if selectItem.id == selectItemID {
                return selectItem
            } else {
                if selectItem is EventItem {
                    return modelData.itemList.first { $0.id == selectItemID }
                } else if selectItem is SummaryItem {
                    return modelData.summaryItemList.first { $0.id == selectItemID }
                } else if selectItem is PrincipleModel {
                    return modelData.principleItems.first { $0.id == selectItemID
                    }
                }
            }
        }
        return selectItem
    }
    
    func updateItem(_ item: EventItem) {
        modelData.updateItem(item)
    }
}
