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
    var itemList: [EventItem]
    @Binding var selectItemID: String
    @Binding var selectionMode: TodoMode
    var addItemEvent: (EventItem) -> ()
    
    @State var calendarMode: CalendarMode = .week
    @State var eventDisplayMode: EventDisplayMode = .timeline
    
    @State private var inspectIsShown: Bool = false
    //@Binding var selectItem: EventItem?
    @State private var showStopAlert: Bool = false
    private static var stopItem: EventItem? = nil
    @State private var eventContent: String = ""
    @State private var showDeleteAlert: Bool = false
    private static var deleteItem: EventItem? = nil
    @State var toggleToRefresh: Bool = false
    
    @State var currentDate: Date = .now {
        didSet {
            toggleToRefresh.toggle()
            print("current date: \(currentDate)")
        }
    }
    
    @State var scrolledID: Date?
    
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel

    @State var expandedItems: Set<String> = []
    
    @State var principleDisplayMode: PrincipleDisplayMode = .week

    // 添加状态变量
    @State var isCollectExpanded = true
    @State var isQuickExpanded = true
    @State var isTodayExpanded = true
    @State var isDeadlineExpanded = true
    @State var isExpiredExpanded = true
    @State var isUnplanExpanded = true
    @State var isSummaryExpanded = true
    @State var isPrincipleExpanded = true
    
    // 过滤条件
    @State var actionType: EventActionType = .all
    @State var actionList: [EventActionType] = [.task, .project, .all]
    @State var selectedTag: String = "所有标签"
    
    @State var todayItems: [EventItem] = []
    @State var toggleToRefreshTodayView: Bool = false
    
    @State var unFinishWeekItems: [Date: [EventItem]] = [:]
    @State var finishWeekItems: [Date: [EventItem]] = [:]
    @State var weekTotalTime: [Date: Int] = [:]
    
    @State var weekTimelineItems: [Date: [TimelineItem]] = [:]
    
    var items: [EventItem] {
        return itemList.filter { event in
            guard selection == .unplan || selection == .all else {
                return true
            }
            if actionType != .all, event.actionType != actionType {
                return false
            }
            if selectedTag != "所有标签", let tag = modelData.tagList.first(where: { $0.id == event.tag }), selectedTag != tag.title {
                return false
            }
            return true
        }
    }
    
    // 日期
    @State var currentWeekIndex: Int = 1
    @State var weekSlider: [[Date.WeekDay]] = []
    let maxWeekIndex: Int = 2
    @State var selectDate: Date = .now {
        didSet {
            print("select date: \(selectDate)")
//            updateTitleText()
//            updateSelectIndexes()
//            resetSelectTask()
        }
    }
    
    let recentThreshold: Int = 7
    var recentItems: [EventItem] {
        let todayItems = self.todayItems
        return items.filter { event in
            guard let planTime = event.planTime else {
                return false
            }
            return !event.isFinish && planTime >= .now && !planTime.isInToday && planTime.daysBetweenDates(date: .now) <= 7 && !todayItems.contains(event)
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
    
    var principleList: [PrincipleModel] {
        modelData.principleItems.sorted { first, second in
            if let firstTag = modelData.tagList.first(where: { $0.id == first.tag }), let secondTag = modelData.tagList.first(where: { $0.id == second.tag }), firstTag.priority != secondTag.priority {
                return firstTag.priority > secondTag.priority
            } else {
                return first.createTime?.timeIntervalSince1970 ?? 0 > second.createTime?.timeIntervalSince1970 ?? 0
            }
        }
    }
    
    var body: some View {
        VStack {
            if selection == .unplan {
                List(selection: $selectItemID) {
                    
                    let tags = modelData.tagList
                    ForEach(tags, id:\.id) { tag in
                        let items = items.filter { !$0.isArchive && $0.planTime == nil && $0.tag == tag.id && !$0.isFinish }
                        if items.count > 0 {
                            Section(header: Text(tag.title)) {
                                ForEach(items) { item in
                                    itemRowView(item: item, showDeadline: false)
                                        .id(UUID())
                                }
                            }
                        }
                    }
                }
            }
            else if selection == .calendar {
                if calendarMode == .week {
                    weekView2()
                } else {
                    monthView()
                }
                
            } else if selection == .project {
                projectView()
            } else if selection == .today {
                todayView()
            } else if selection == .principle {
                principleView()
            }
            else {
                List(items, id: \.self.id, selection: $selectItemID) { item in
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
            
            if selection == .calendar || selection == .principle {
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
            }
            
            if selection == .calendar {
                
                Picker("周期切换", selection: $calendarMode) {
                    ForEach(CalendarMode.allCases, id: \.self) { mode in
                        Text(mode.title)
                    }
                }
                
                Picker("视图切换", selection: $eventDisplayMode) {
                    ForEach(EventDisplayMode.allCases, id: \.self) { mode in
                        Text(mode.title)
                    }
                }

            }
            
            if selection == .principle {
                Picker("模式切换", selection: $principleDisplayMode) {
                    ForEach(PrincipleDisplayMode.allCases, id: \.self) { mode in
                        Text(mode.title)
                    }
                }
            }
            
            if selection == .unplan || selection == .all {
                Picker("选择类型", selection: $actionType) {
                    ForEach(actionList, id: \.self) { type in
                        Text(type.title).tag(type)
                    }
                }
                
                Picker("选择标签", selection: $selectedTag) {
                    let titles = ["所有标签"] + modelData.tagList.sorted(by: { first, second in
                        let eventList = modelData.itemList
                        return eventList.filter { $0.tag == first.id }.count > eventList.filter { $0.tag == second.id}.count
                    }).map({$0.title})
                    ForEach(titles, id: \.self) { title in
//                        if let tag = modelData.tagList.first(where: { $0.title == title}) {
//                            Text(tag.title).tag(tag)
//                        }
                        Text(title).tag(title)
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
                if selection == .principle {
                    self.addNewPrincipleItem()
                } else {
                    self.addNewItem()
                }
            } label: {
                Label("Add New Item", systemImage: "plus")
            }
        }
        .onChange(of: calendarMode, { oldValue, newValue in
            currentDate = .now
            updateWeekData()
        })
        .onChange(of: selection, { oldValue, newValue in
            if newValue == .today {
                updateTodayItems()
            } else if newValue == .calendar {
                updateWeekData()
            }
        })
        .onChange(of: selectionMode, { oldValue, newValue in
            if selection == .today {
                updateTodayItems()
            } else if selection == .calendar {
                updateWeekData()
            }
        })
        .onChange(of: selectDate, { oldValue, newValue in
            if selection == .today {
                updateTodayItems()
            } else if selection == .calendar {
                updateWeekData()
            }
        })
        .onChange(of: currentDate, { oldValue, newValue in
            if selection == .today {
                updateTodayItems()
            } else if selection == .calendar {
                updateWeekData()
            }
        })
        .onChange(of: modelData.itemList, { oldValue, newValue in
            if selection == .today {
                updateTodayItems()
            } else if selection == .calendar {
                updateWeekData()
            }
        })
        .onChange(of: eventDisplayMode, { oldValue, newValue in
            updateWeekData()
        })
        .alert(isPresented: $showDeleteAlert) {
            Alert(title: Text("是否删除该事项"), message: Text(Self.deleteItem?.title ?? ""), primaryButton: .destructive(Text("确认"), action: {
                deleteItem()
            }), secondaryButton: .cancel(Text("取消")))
        }
        .alert("编辑事件内容", isPresented: $showStopAlert) {
            TextField("请输入内容...", text: $eventContent)
            Button("取消", role: .cancel) {
                
            }
            Button("确定") {
                if let stopItem = Self.stopItem {
                    handleStopEvent(item: stopItem)
                    self.eventContent = ""
                }
            }
        } message: {
            Text("")
        }
        .onAppear {
            print("todo itemlist appear")
            if selection == .today {
                updateTodayItems()
                isPrincipleExpanded = selectionMode != .work
            } else if selection == .calendar, let currentDate = weekDates.first(where: { $0.isToday }) {
                print("scroll date: \(currentDate)")
                scrolledID = currentDate
                updateWeekData()
            }
        }
    }
    
    func unplanItems(with tag: ImportanceTag) -> [EventItem] {
        return unplanItemList.filter { event in
            return event.importance == tag
        }
    }
    
    func itemRowView(item: any BasicTaskProtocol, date: Date = .now, showImportance: Bool = true, showTag: Bool = true, showDeadline: Bool = true, showMark: Bool = false, isVertical: Bool = false, showItemCount: Bool = false, showIsFinish: Bool = false) -> some View {
        ToDoItemRowView(item: item, date: date, selection: selection, showImportance: showImportance, showTag: showTag, showDeadline: showDeadline, showMark: showMark, isVerticalLayout: isVertical, showItemCount: showItemCount, showIsFinish: showIsFinish).environmentObject(modelData)
        .contextMenu {
            if let item = item as? EventItem {
                if item.actionType == .task || item.actionType == .project {
                    if item.isPlay {
                        Button {
                            Self.stopItem = item
                            showStopAlert.toggle()
//                            timerModel.stopTimer()
//                            handleStopEvent(item: item)
                        } label: {
                            Text("stop").foregroundStyle(.red)
                        }
                        
                        Button {
                            timerModel.stopTimer()
                            handleCancelEvent(item: item)
                        } label: {
                            Text("cancel").foregroundStyle(.red)
                        }
                        
                    }
                    else {
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
                
                Button {
                    addProjectSubItem(root: item)
                } label: {
                    Text("新建子任务").foregroundStyle(.cyan)
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
        let taskItem = TaskTimeItem(startTime: playTime, endTime: .now, content: eventContent)
        taskItem.eventId = item.id
        modelData.updateTimeItem(taskItem)

        item.isPlay = false
        modelData.updateItem(item)
    }
    
    func handleCancelEvent(item: EventItem) {
        item.isPlay = false
        modelData.updateItem(item)
    }
    
    func checkItem(_ item: EventItem) {
        item.isFinish = !item.isFinish
        item.finishTime = .now
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
