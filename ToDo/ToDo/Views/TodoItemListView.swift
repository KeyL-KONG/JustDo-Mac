//
//  TodoItemListView.swift
//  ToDo
//
//  Created by LQ on 2024/8/10.
//

import SwiftUI
import LeanCloud

struct TodoItemListView: View {
    let selection: ToDoSection
    let title: String
    var items: [EventItem]
    @Binding var selectItemID: String
    @Binding var selectionMode: TodoMode
    var addItemEvent: (EventItem) -> ()
    
    @State var calendarMode: CalendarMode = .week
    
    @State private var inspectIsShown: Bool = false
    //@Binding var selectItem: EventItem?
    @State private var showDeleteAlert: Bool = false
    private static var deleteItem: EventItem? = nil
    @State var toggleToRefresh: Bool = false
    
    @State var currentDate: Date = .now {
        didSet {
            toggleToRefresh.toggle()
        }
    }
    
    @State var scrolledID: Date?
    
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel
    
    let recentThreshold: Int = 7
    var recentItems: [EventItem] {
        items.filter { event in
            guard let planTime = event.planTime else {
                return false
            }
            return !event.isFinish && planTime >= .now && !planTime.isInToday && planTime.daysBetweenDates(date: .now) <= 7
        }.sorted { first, second in
            let firstDays = first.planTime?.daysBetweenDates(date: .now) ?? 0
            let secondDays = second.planTime?.daysBetweenDates(date: .now) ?? 0
            if firstDays != secondDays {
                return firstDays <= secondDays
            }
            else if first.importance.value != second.importance.value {
                return first.importance.value > second.importance.value
            } else if let firstTag = modelData.tagList.first(where: { $0.id == first.tag }), let secondTag = modelData.tagList.first(where: { $0.id == second.tag }), firstTag.priority != secondTag.priority {
                return firstTag.priority > secondTag.priority
            } else {
                return first.createTime?.timeIntervalSince1970 ?? 0 > second.createTime?.timeIntervalSince1970 ?? 0
            }
        }
    }
    
    var unplanItemList: [EventItem] {
        items.filter { event in
            return event.planTime == nil && !event.isFinish
        }.sorted { first, second in
            if first.importance.value != second.importance.value {
                return first.importance.value > second.importance.value
            } else if let firstTag = modelData.tagList.first(where: { $0.id == first.tag }), let secondTag = modelData.tagList.first(where: { $0.id == second.tag }), firstTag.priority != secondTag.priority {
                return firstTag.priority > secondTag.priority
            } else {
                return first.createTime?.timeIntervalSince1970 ?? 0 > second.createTime?.timeIntervalSince1970 ?? 0
            }
        }
    }
    
    var expiredItemList: [EventItem] {
        items.filter { event in
            guard let planTime = event.planTime else {
                return false
            }
            return !event.isFinish && !planTime.isInToday && planTime < .now
        }.sorted { first, second in
            let firstDays = first.planTime?.daysBetweenDates(date: .now) ?? 0
            let secondDays = second.planTime?.daysBetweenDates(date: .now) ?? 0
            if firstDays != secondDays {
                return firstDays < secondDays
            }
            else if first.importance.value != second.importance.value {
                return first.importance.value > second.importance.value
            } else if let firstTag = modelData.tagList.first(where: { $0.id == first.tag }), let secondTag = modelData.tagList.first(where: { $0.id == second.tag }), firstTag.priority != secondTag.priority {
                return firstTag.priority > secondTag.priority
            } else {
                return first.createTime?.timeIntervalSince1970 ?? 0 > second.createTime?.timeIntervalSince1970 ?? 0
            }
        }
    }
    
    var itemList: [EventItem] {
        switch selection {
        case .recent:
            return recentItems
        default:
            return items
        }
    }
    
    var body: some View {
        VStack {
            if selection == .unplan {
                List(selection: $selectItemID) {
                    Section(header: Text("待规划")) {
                        ForEach(unplanItemList) { item in
                            itemRowView(item: item, showDeadline: false)
                        }
                    }
                    
                    Section(header: Text("已过期")) {
                        ForEach(expiredItemList) { item in
                            itemRowView(item: item, showDeadline: true)
                        }
                    }
                }
            } else if selection == .calendar {
                if calendarMode == .week {
                    weekView2()
                } else {
                    monthView()
                }
                
            } else if selection == .project {
                projectView()
            } else if selection == .today {
                todayView()
            }
            else {
                List(itemList, id: \.self.id, selection: $selectItemID) { item in
                    if selection == .recent {
                        itemRowView(item: item, showDeadline: true)
                    }
                    else {
                        itemRowView(item: item, showDeadline: false)
                    }
                }
            }
        }
        .toolbar {
            
            if selection == .calendar {
                Button {
                    currentDate = calendarMode == .week ?  currentDate.previousWeekDate : currentDate.previousMonth
                } label: {
                    Label("left", systemImage: "arrowshape.left.fill")
                }
                
                if calendarMode == .week {
                    Text("\(weekDateStr)")
                } else {
                    Text(currentDate.monthAbbreviation)
                }
                
                Button {
                    currentDate = calendarMode == .week ? currentDate.nextWeekDate : currentDate.nextMonth
                } label: {
                    Label("rigth", systemImage: "arrowshape.right.fill")
                }
                
                Picker("视图切换", selection: $calendarMode) {
                    ForEach(CalendarMode.allCases, id: \.self) { mode in
                        Text(mode.title)
                    }
                }

            }
            
            Picker("模式切换", selection: $selectionMode) {
                ForEach(TodoMode.allCases, id: \.self) { mode in
                    Text(mode.title)
                }
            }
            
            Button {
                self.refreshItems()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            
            Button {
                self.addNewItem()
            } label: {
                Label("Add New Item", systemImage: "plus")
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(title: Text("是否删除该事项"), message: Text(Self.deleteItem?.title ?? ""), primaryButton: .destructive(Text("确认"), action: {
                deleteItem()
            }), secondaryButton: .cancel(Text("取消")))
        }
        .onAppear {
            print("todo itemlist appear")
            if selection == .today {
                print("today items: \(items.count)")
            } else if selection == .calendar, let currentDate = weekDates.first(where: { $0.isToday }) {
                print("scroll date: \(currentDate)")
                scrolledID = currentDate
            }
        }
    }
    
    func unplanItems(with tag: ImportanceTag) -> [EventItem] {
        return unplanItemList.filter { event in
            return event.importance == tag
        }
    }
    
    func itemRowView(item: any BasicTaskProtocol, date: Date = .now, showImportance: Bool = true, showTag: Bool = true, showDeadline: Bool = true, showMark: Bool = false, isVertical: Bool = false, showItemCount: Bool = false) -> some View {
        ToDoItemRowView(item: item, date: date, selection: selection, showImportance: showImportance, showTag: showTag, showDeadline: showDeadline, showMark: showMark, isVerticalLayout: isVertical, showItemCount: showItemCount).environmentObject(modelData)
        .contextMenu {
            if let item = item as? EventItem {
                if item.actionType == .task {
                    if item.isPlay {
                        if timerModel.isTiming {
                            Button {
                                timerModel.pauseTimer()
                                handlePauseEvent(item: item)
                            } label: {
                                Text("pause").foregroundStyle(.red)
                            }
                        } else {
                            Button {
                                timerModel.restartTimer()
                                handleRestartEvent(item: item)
                            } label: {
                                Text("restart").foregroundStyle(.blue)
                            }
                        }
                        
                        Button {
                            timerModel.stopTimer()
                            handleStopEvent(item: item)
                        } label: {
                            Text("stop").foregroundStyle(.red)
                        }
                        
                    } else {
                        Button {
                            if timerModel.startTimer(item: item) {
                                item.isPlay = true
                                item.playTime = .now
                                modelData.updateItem(item)
                            }
                        } label: {
                            Text("start").foregroundStyle(.green)
                        }
                    }
                }
                
                if selection == .project {
                    Button {
                        addProjectSubItem(root: item)
                    } label: {
                        Text("新建子任务").foregroundStyle(.cyan)
                    }

                }
                
                Button {
                    checkItem(item)
                } label: {
                    Text((item.isFinish ? "unFinish" : "finish")).foregroundStyle(.blue)
                }
                
                Button(action: {
                    copyTaskItem(item: item)
                }, label: {
                    Text("复制").foregroundStyle(.green)
                })
                
                Button {
                    Self.deleteItem = item
                    showDeleteAlert.toggle()
                } label: {
                    Text("delete").foregroundStyle(.red)
                }
            }
        }
    }
    
    func handleRestartEvent(item: EventItem) {
        item.playTime = .now
        modelData.updateItem(item)
    }
    
    func handlePauseEvent(item: EventItem) {
        guard let playTime = item.playTime else {
             return
        }
        let interval = Int(Date.now.timeIntervalSince1970 - playTime.timeIntervalSince1970)
        if interval < 60 {
            return
        }
        let dateInterval = LQDateInterval(start: playTime, end: .now)
        item.intervals.append(dateInterval)
        modelData.updateItem(item)
    }
    
    func handleStopEvent(item: EventItem) {
        guard let playTime = item.playTime else {
            return
        }
        let interval = Int(Date.now.timeIntervalSince1970 - playTime.timeIntervalSince1970)
        if let timingItem = timerModel.timingItem, timingItem.id == item.id, interval > 60 {
            let dateInterval = LQDateInterval(start: playTime, end: .now)
            item.intervals.append(dateInterval)
        }
        item.isPlay = false
        modelData.updateItem(item)
    }
    
    func checkItem(_ item: EventItem) {
        item.isFinish = !item.isFinish
        modelData.updateItem(item)
    }
    
    func refreshItems() {
        modelData.loadFromServer()
    }
    
    func addNewItem() {
        let item = EventItem()
        item.title = "新建任务"
        if selection == .today {
            item.planTime = .now
        } else if selection == .project {
            item.actionType = .project
            item.title = "新建项目"
        }
        if let workTag = modelData.tagList.first(where: { $0.title == "工作"}) {
            if item.actionType == .project || selectionMode == .work {
                item.tag = workTag.id
            }
        }
        modelData.updateItem(item) {
            self.addItemEvent(item)
        }
    }
    
    func deleteItem() {
        guard let item = Self.deleteItem else { return }
        print("delete item")
        modelData.deleteItem(item)
        Self.deleteItem = nil
    }
}
