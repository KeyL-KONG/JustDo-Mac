//
//  iOSTaskListView.swift
//  ToDo
//
//  Created by LQ on 2025/6/28.
//

import SwiftUI
#if os(iOS)

struct iOSTaskListView: View {
    
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel
    @State private var showingSheet = false
    @State var isShowingTimer: Bool = false
    var selectDate: Date
    var timeTab: TimeTab
    @State private var searchText: String = ""
    
    static var selectedItem: EventItem?
    
    @State var eventItems: [EventItem] = []
    @State var projectItems: [EventItem] = []
    @State var unPlanItems: [EventItem] = []
    @State var reviewItems: [EventItem] = []
    @State var recentExpireItems: [EventItem] = []
    @State var willReachItems: [EventItem] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                itemListView()
            }
            .overlay(alignment: .bottomTrailing, content: {
                Button(action: {
                    Self.selectedItem = nil
                    showingSheet.toggle()
                }, label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 55, height: 55)
                        .background(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
                })
                .padding(15)
            })
            .onChange(of: selectDate, { oldValue, newValue in
                if oldValue != newValue {
                    updateTaskItems()
                }
            })
            .onChange(of: modelData.updateItemIndex, { oldValue, newValue in
                updateTaskItems()
            })
            .onChange(of: searchText) { oldValue, newValue in
                updateTaskItems()
            }
            .sheet(isPresented: $showingSheet) {
                if let selectedItem = Self.selectedItem {
                    EditTaskView(showSheetView: $showingSheet, selectedItem: selectedItem, setPlanTime: true, setReward: false, setDeadlineTime: false)
                        .environmentObject(modelData)
                } else {
                    EditTaskView(showSheetView: $showingSheet, setPlanTime: (timeTab != .all), setReward: false, defaultSelectDate: selectDate, setDeadlineTime: false)
                       .environmentObject(modelData)
                }
            }
            .onAppear {
                updateTaskItems()
            }
            .searchable(text: $searchText, prompt: "搜索任务...")
        }
    }
}

// MARK: today
extension iOSTaskListView {
    
    func itemListView() -> some View {
        List {
            Section {
                ForEach(eventItems, id: \.self.id) { item in
                    ListItemRow(item: item, selectDate: selectDate) {
                        Self.selectedItem = item
                        showingSheet.toggle()
                    } longPress: {
                        
                    }.environmentObject(modelData)
                        .swipeActions {
                            Button(role: .destructive) {
                                modelData.deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button(action: {
                                timerModel.startTimer(item: item)
                            }, label: {
                                Label("Start", systemImage: "Flag")
                            }).tint(.blue)
                        }.id(UUID().uuidString)
                }
            } header: {
                HStack {
                    Text("待办事项")
                    Spacer()
                }
            }
            
            if projectItems.count > 0 {
                Section {
                    ForEach(projectItems, id: \.self.id) { item in
                        ListItemRow(item: item, showDeadline: true, selectDate: selectDate) {
                            Self.selectedItem = item
                            showingSheet.toggle()
                        } longPress: {
                            
                        }.environmentObject(modelData)
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelData.deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button(action: {
                                    timerModel.startTimer(item: item)
                                }, label: {
                                    Label("Start", systemImage: "Flag")
                                }).tint(.blue)
                            }.id(UUID().uuidString)
                    }
                } header: {
                    HStack {
                        Text("待办项目")
                        Spacer()
                    }
                }
            }
            
            if willReachItems.count > 0 {
                Section {
                    ForEach(willReachItems, id: \.self.id) { item in
                        ListItemRow(item: item, selectDate: selectDate) {
                            Self.selectedItem = item
                            showingSheet.toggle()
                        } longPress: {
                            
                        }.environmentObject(modelData)
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelData.deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }.id(UUID().uuidString)
                    }
                } header: {
                    HStack {
                        Text("即将到达事项")
                        Spacer()
                    }
                }
            }
            
            if unPlanItems.count > 0 {
                Section {
                    ForEach(unPlanItems, id: \.self.id) { item in
                        ListItemRow(item: item, selectDate: selectDate) {
                            Self.selectedItem = item
                            showingSheet.toggle()
                        } longPress: {
                            
                        }.environmentObject(modelData)
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelData.deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }.id(UUID().uuidString)
                    }
                } header: {
                    HStack {
                        Text("待计划事项")
                        Spacer()
                    }
                }
            }
            
            if recentExpireItems.count > 0 {
                Section {
                    ForEach(recentExpireItems, id: \.self.id) { item in
                        ListItemRow(item: item, showDeadline: true, selectDate: selectDate) {
                            Self.selectedItem = item
                            showingSheet.toggle()
                        } longPress: {
                            
                        }.environmentObject(modelData)
                        .swipeActions {
                            Button(role: .destructive) {
                                modelData.deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button(action: {
                                timerModel.startTimer(item: item)
                            }, label: {
                                Label("Start", systemImage: "Flag")
                            }).tint(.blue)
                        }.id(UUID().uuidString)
                    }
                } header: {
                    HStack {
                        Text("过期事项")
                        Spacer()
                    }
                }
            }
            
            if reviewItems.count > 0 {
                Section {
                    ForEach(reviewItems, id: \.self.id) { item in
                        ListItemRow(item: item, showFinishTime: true, selectDate: selectDate) {
                            Self.selectedItem = item
                            showingSheet.toggle()
                        } longPress: {
                            
                        }.environmentObject(modelData)
                        .swipeActions {
                            Button(action: {
                                timerModel.startTimer(item: item)
                            }, label: {
                                Label("Start", systemImage: "Flag")
                            }).tint(.blue)
                        }.id(UUID().uuidString)
                    }
                } header: {
                    HStack {
                        Text("复盘事项")
                        Spacer()
                    }
                }
            }

        }
        .listStyle(.insetGrouped)
        .refreshable {
            modelData.loadFromServer()
        }
    }
}

// MARK: data
extension iOSTaskListView {
    
    func updateTaskItems() {
        
        // 添加搜索过滤逻辑
        let searchLowercased = searchText.lowercased()
        let matchesSearch: (EventItem) -> Bool = { item in
            if searchText.isEmpty {
                return true
            }
            let titleMatch = item.title.lowercased().contains(searchLowercased)
            let contentMatch = item.mark.lowercased().contains(searchLowercased)
            return titleMatch || contentMatch
        }
        
        if !searchText.isEmpty {
            self.eventItems = modelData.itemList.filter({ event in
                return matchesSearch(event)
            }).sorted(by: { first, second in
                if first.isFinish != second.isFinish {
                    return !first.isFinish
                }
                return first.createTime?.timeIntervalSince1970 ?? 0 > second.createTime?.timeIntervalSince1970 ?? 0
            })
            self.unPlanItems = []
            self.reviewItems = []
            self.recentExpireItems = []
            self.willReachItems = []
            self.projectItems = []
            return
        }
        
        self.eventItems = modelData.itemList.filter({ event in
            guard event.actionType == .task else { return false }
            if let planTime = event.planTime, planTime.isSameTime(timeTab: timeTab, date: selectDate), event.setPlanTime {
                return true
            }
            return false
        })
        .sorted { (event1: EventItem, event2: EventItem) in
            if event1.isFinish != event2.isFinish {
                return event1.isFinish ? false : true
            } else if event1.importance != event2.importance {
                return event1.importance.value > event2.importance.value
            } else {
                return event1.tagPriority(tags: modelData.tagList) > event2.tagPriority(tags: modelData.tagList)
            }
        }
        
        self.projectItems = modelData.itemList.filter({ event in
            guard event.actionType == .project else {
                return false
            }
            guard let planTime = event.planTime?.startOfDay, let deadlineTime = event.deadlineTime?.endOfDay, event.setPlanTime, event.setDealineTime else {
                return false
            }
            if let finishTime = event.finishTime, timeTab == .day && event.isFinish && finishTime.isInSameDay(as: selectDate) {
                return false
            }
            return planTime <= selectDate && selectDate <= deadlineTime
        }).sorted { (event1: EventItem, event2: EventItem) in
            if event1.isFinish != event2.isFinish {
                return event1.isFinish ? false : true
            } else if event1.importance != event2.importance {
                return event1.importance.value > event2.importance.value
            } else if let time1 = event1.displayDeadlineTime, let time2 = event2.displayDeadlineTime {
                let days1 = time1.daysBetween(selectDate)
                let days2 = time2.daysBetween(selectDate)
                return days1 < days2
            }
            else {
                return event1.tagPriority(tags: modelData.tagList) > event2.tagPriority(tags: modelData.tagList)
            }
        }
        
        self.unPlanItems = modelData.itemList.filter({ event in
            guard event.planTime == nil else { return false }
            guard let createTime = event.createTime else { return false }
            return createTime.isSameTime(timeTab: timeTab, date: selectDate) && event.actionType == .task
        })
        
        self.reviewItems = modelData.itemList.filter({ event in
            guard let finishTime = event.finishTime, event.needReview else { return false }
            if timeTab == .day {
                let days = selectDate.daysBetween(finishTime)
                return days >= 0 && days <= 7
            }
            return finishTime.isSameTime(timeTab: timeTab, date: selectDate)
        }).sorted(by: { event1, event2 in
            if event1.finishReview != event2.finishReview {
                return event1.finishReview ? true : false
            } else if event1.finishReview {
                return event1.reviewDate ?? .now > event2.reviewDate ?? .now
            } else {
                return event1.finishTime ?? .now > event2.finishTime ?? .now
            }
        })
        
        if timeTab == .day {
            self.recentExpireItems = modelData.itemList.filter({ event in
                guard let planTime = event.planTime, event.setPlanTime else { return false }
                return event.actionType == .task && !event.isFinish && selectDate.daysBetween(planTime) <= 7 && !selectDate.isSameTime(timeTab: .day, date: planTime) && selectDate > planTime
            })
            if selectDate.startOfDay >= Date().startOfDay {
                self.willReachItems = modelData.itemList.filter({ event in
                    guard let planTime = event.planTime, event.setPlanTime else { return false }
                    if selectDate.startOfDay < Date().startOfDay {
                        return false
                    }
                    let days = planTime.daysBetween(selectDate)
                    return !event.isFinish && !planTime.isSameTime(timeTab: .day, date: selectDate) && days <= 3 && planTime > selectDate
                })
            } else {
                self.willReachItems = []
            }
        }
        
        
        print("update task items: \(eventItems.count)")
    }
    
}

#endif
