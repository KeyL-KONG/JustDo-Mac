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
                    Text("事项")
                    Spacer()
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
            //guard event.actionType == .task else { return false }
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
        
//        switch timeTab {
//        case .day:
//            eventItems = modelData.itemList.filter({ event in
//                guard event.actionType == .task else { return false }
//                guard let planTime = event.planTime, planTime.isSameTime(timeTab: timeTab, date: selectDate) else {
//                    return false
//                }
//                return true
//            })
//            .sorted { (event1: EventItem, event2: EventItem) in
//                if event1.isFinish != event2.isFinish {
//                    return event1.isFinish ? false : true
//                } else if event1.importance != event2.importance {
//                    return event1.importance.value > event2.importance.value
//                } else {
//                    return event1.tagPriority(tags: modelData.tagList) > event2.tagPriority(tags: modelData.tagList)
//                }
//            }
//        default:
//            break
//        }
        print("update task items: \(eventItems.count)")
    }
    
}

#endif
