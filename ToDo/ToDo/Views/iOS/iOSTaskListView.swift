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
    
    static var selectedItem: EventItem?
    
    @State var eventItems: [EventItem] = []
    
    @State var unPlanItems: [EventItem] = []
    
    @State var reviewItems: [EventItem] = []
    
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
            .sheet(isPresented: $showingSheet) {
                if let selectedItem = Self.selectedItem {
                    EditTaskView(showSheetView: $showingSheet, selectedItem: selectedItem, setPlanTime: true, setReward: false)
                        .environmentObject(modelData)
                } else {
                    EditTaskView(showSheetView: $showingSheet, setPlanTime: (timeTab != .all), setReward: false, defaultSelectDate: selectDate)
                       .environmentObject(modelData)
                }
            }
            .onAppear {
                updateTaskItems()
            }
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
                        }.id(item.id)
                }
            } header: {
                HStack {
                    Text("待办事项")
                    Spacer()
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
                            }.id(item.id)
                    }
                } header: {
                    HStack {
                        Text("待计划事项")
                        Spacer()
                    }
                }
            }
            
            if reviewItems.count > 0 {
                Section {
                    ForEach(reviewItems, id: \.self.id) { item in
                        ListItemRow(item: item, selectDate: selectDate) {
                            Self.selectedItem = item
                            showingSheet.toggle()
                        } longPress: {
                            
                        }.environmentObject(modelData)
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
        
        self.eventItems = modelData.itemList.filter({ event in
            guard let planTime = event.planTime, planTime.isSameTime(timeTab: timeTab, date: selectDate) else {
                return false
            }
            return true
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
        
        self.unPlanItems = modelData.itemList.filter({ event in
            guard event.planTime == nil else { return false }
            guard let createTime = event.createTime else { return false }
            return createTime.isSameTime(timeTab: timeTab, date: selectDate) && event.actionType == .task
        })
        
        self.reviewItems = modelData.itemList.filter({ event in
            guard let finishTime = event.finishTime else { return false }
            return event.needReview && finishTime.isSameTime(timeTab: timeTab, date: selectDate)
        }).sorted(by: { event1, event2 in
            if event1.finishReview != event2.finishReview {
                return event1.finishReview ? true : false
            } else if event1.finishReview {
                return event1.reviewDate ?? .now > event2.reviewDate ?? .now
            } else {
                return event1.finishTime ?? .now > event2.finishTime ?? .now
            }
        })
        
        print("update task items: \(eventItems.count)")
    }
    
}

#endif
