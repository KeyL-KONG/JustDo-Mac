//
//  PlanView.swift
//  ToDo
//
//  Created by LQ on 2025/5/12.
//

import SwiftUI

struct PlanView: View {
    
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel
    
    @State var mostImportranceItems: [EventItem] = []
    @State var planTimeItems: [PlanTimeItem] = []
    @Binding var selectItemID: String
    @State var timeTab: TimeTab = .week
    
    @State var tagTotalTimes: [String: Int] = [:]
    @State var sortedTagList: [ItemTag] = []
    @State var tagExpandState: [String: Bool] = [:]
    @State var tagItemList: [String: [EventItem]] = [:]
    @State var eventTotalTime = [String: Int]()
    
    @State var summaryItems: [SummaryItem] = []
    
    @State var noteItems: [NoteModel] = []
    
    @State var readItems: [ReadModel] = []
    
    @State var eventList: [PlanEventItem] = []
    
    @Binding var currentDate: Date
    
    @Binding var selectionMode: TodoMode
    
    @State var isEventListExpand: Bool = false
    @State var isReadListExpand: Bool = false
    @State var isSummaryExpand: Bool = true
    @State var isSummaryEdit: Bool = false
    @State var summaryContent: String = ""
    @State var summaryTimeExpand: Bool = false
    
    private static var stopItem: EventItem? = nil
    @State private var showStopAlert: Bool = false
    @State private var eventContent: String = ""
    
    var currentSummaryItem: SummaryItem? {
        modelData.summaryItemList.first { item in
            guard let summaryTime = item.summaryDate else { return false }
            return summaryTime.isSameTime(timeTab: timeTab, date: currentDate) && item.timeTab == timeTab
        }
    }
    
    var summaryTagTotalTime: Int {
        tagTotalTimes.values.reduce(0, +)
    }
    
    var body: some View {
        ScrollView(showsIndicators: true) { // 添加垂直滚动容器
            VStack(spacing: 0) {
                if mostImportranceItems.count > 0 {
                    mostImportanceHeaderView()
                    mostImportanceView()
                }
                
                let notShowPlan = timeTab == .day && planTimeItems.isEmpty
                if !notShowPlan {
                    planHeaderView()
                    planItemsView()
                }
                
                if eventList.count > 0 {
                    eventListHeaderView()
                    eventListView()
                }
                
                if selectionMode != .work {
                    summaryTimeHeaderView()
                    summaryTagTimeItems()
                }
                
                if summaryItems.count > 0 {
                    summaryItemHeaderView()
                    summaryItemsView()
                }
                
                if noteItems.count > 0 {
                    noteItemHeaderView()
                    noteItemsView()
                }
                
                if readItems.count > 0, selectionMode == .synthesis {
                    readItemHeaderView()
                    readItemListView()
                }
                
                if selectionMode == .synthesis {
                    summaryHeaderView()
                    if self.isSummaryExpand, selectionMode != .work {
                        summaryDetailView()
                    }
                }
                
                
                Spacer()
            }
        }
        .onChange(of: selectionMode, { oldValue, newValue in
            updateData()
            updateSelectDefaultItem()
        })
        .onChange(of: currentDate) { old, new in
            updateData()
            updateSummaryContent()
            updateSelectDefaultItem()
        }
        .onChange(of: modelData.readList) { _, _ in
            updateReadItems()
        }
        .onChange(of: modelData.taskTimeItems, { oldValue, newValue in
            updateTagSummaryTime()
        })
        .onChange(of: modelData.updateSummaryItemIndex) { _, _ in
            updateSummaryItems()
            updateSummaryContent()
        }
        .onAppear {
            currentDate = modelData.planCacheTime ?? .now
            updateSummaryContent()
            if self.mostImportranceItems.count > 0 {
                self.selectItemID = self.mostImportranceItems.first?.id ?? self.selectItemID
            }
        }
        .onDisappear {
            modelData.planCacheTime = currentDate
        }
        .onChange(of: modelData.updateItemIndex, { _, _ in
            updateMostImportanceItems()
            updateEventList()
        })
        .onReceive(modelData.$planTimeItems, perform: { _ in
            updatePlanItems()
        })
        .onReceive(modelData.$updateItemIndex) { _ in
            updateMostImportanceItems()
        }
        .onReceive(modelData.$updateNoteIndex) { _ in
            updateNoteItems()
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
        .toolbar {
            HStack {
                Button {
                    currentDate = currentDate.previousWeekDate
                } label: {
                    Label("left", systemImage: "arrowshape.left.fill")
                }
                
                Text(currentDate.simpleWeek)
                
                Button {
                    currentDate = currentDate.nextWeekDate
                } label: {
                    Label("rigth", systemImage: "arrowshape.right.fill")
                }
                
                Spacer()
            }
        }
    }
    
    func updateSelectDefaultItem() {
        if self.planTimeItems.contains(where: {  $0.id != selectItemID
        }) {
            selectItemID = self.planTimeItems.first?.id ?? self.selectItemID
        }
    }
    
    func updateData() {
        print("update data")
        let totalStart = Date()
        
        let start1 = Date()
        updateMostImportanceItems()
        print("mostImportanceItems: \((Date().timeIntervalSince1970 - start1.timeIntervalSince1970) * 1000)ms")
        
        let start3 = Date()
        updatePlanItems()
        print("planItems: \((Date().timeIntervalSince1970 - start3.timeIntervalSince1970) * 1000)ms")
        
        let start2 = Date()
        updatePlanTimeInterval()
        print("planTimeInterval: \((Date().timeIntervalSince1970 - start2.timeIntervalSince1970) * 1000)ms")
        
        let start4 = Date()
        updateTagSummaryTime()
        print("tagSummaryTime: \((Date().timeIntervalSince1970 - start4.timeIntervalSince1970) * 1000)ms")
        
        let start5 = Date()
        updateSummaryItems()
        print("summaryItems: \((Date().timeIntervalSince1970 - start5.timeIntervalSince1970) * 1000)ms")
        
        updateEventList()
        
        updateNoteItems()
        
        let start6 = Date()
        updateReadItems()
        print("readItems: \((Date().timeIntervalSince1970 - start6.timeIntervalSince1970) * 1000)ms")
        
        print("total duration: \((Date().timeIntervalSince1970 - totalStart.timeIntervalSince1970) * 1000)ms")
    }
}

// MARK: summary view
extension PlanView {
    
    func summaryHeaderView() -> some View {
        HStack(spacing: 10) {
            Text("本\(timeTab.timeTitle)总结").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "117a65"))
            
            Spacer()
            
            if currentSummaryItem != nil {
                Button {
                    fetchSummaryContent { content in
                        if self.summaryContent.contains("\n## 事项\n") {
                            self.summaryContent =  self.summaryContent.truncateAfter(substring: "\n## 事项\n")
                        }
                        self.summaryContent += content
                        self.updateSummaryItem()
                    }
                } label: {
                    Text("同步").foregroundStyle(Color.init(hex: "117a65"))
                }.buttonStyle(.plain)

            }
            
            Button {
                if currentSummaryItem == nil {
                    updateSummaryItem()
                } else {
                    if self.isSummaryEdit {
                        updateSummaryItem()
                    }
                    self.isSummaryEdit = !self.isSummaryEdit
                }
            } label: {
                let title = currentSummaryItem == nil ? "添加" : (isSummaryEdit ? "预览" : "编辑")
                Text(title).foregroundStyle(Color.init(hex: "117a65"))
            }
            .buttonStyle(.plain)
            
            Button {
                self.isSummaryExpand = !self.isSummaryExpand
            } label: {
                Image(systemName: isSummaryExpand ? "chevron.down" : "chevron.right").foregroundStyle(Color.init(hex: "117a65"))
            }
            .buttonStyle(.plain)
            
        }.padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, (isSummaryExpand ? 0 : 50))
    }
    
    func summaryDetailView() -> some View {
        VStack {
            if isSummaryEdit {
                TextEditor(text: $summaryContent)
                    .font(.system(size: 14))
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .cornerRadius(8)
            } else {
                let content = summaryContent.isEmpty ? "添加一条的总结..." : summaryContent
                MarkdownWebView(content, itemId: (currentSummaryItem?.id ?? ""))
                    .padding(5)
            }
            Spacer()
        }
        .frame(minHeight: 100)
        .background(isSummaryEdit ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
        .cornerRadius(8)
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
    }
    
    func updateSummaryContent() {
        self.summaryContent = self.currentSummaryItem?.content ?? ""
    }
    
    func updateSummaryItem() {
        let item = currentSummaryItem ?? SummaryItem()
        item.summaryDate = currentDate
        item.time = timeTab.rawValue
        item.content = summaryContent
        modelData.updateSummaryItem(item)
    }
    
    struct SummaryEventItem {
        let event: EventItem
        let interval: Int
    }
    
    func fetchSummaryContent(completion: @escaping (String)->Void) {
        let items = self.eventList
        let summaryItems = self.summaryItems
        let readList = self.readItems
        let selectDate = self.currentDate
        let tagList = self.sortedTagList
        let tagItemList = self.tagItemList
        let eventTotalTime = self.eventTotalTime
        let summaryTagContens = self.currentSummaryItem?.summaryTags ?? [:]
        let noteTagList = modelData.noteTagList
        let taskItems = modelData.taskTimeItems
        DispatchQueue.global().async {
            var content = ""
            content = "\n## 事项\n"
            sortedTagList.forEach { tag in
                if let items = tagItemList[tag.id], items.count > 0 {
                    content += "\n### \(tag.title)\n"
                    
                    items.forEach { item in
                        let finishText = !item.isFinish && item.planTime != nil ? "[ ]" : "[x]"
                        content += "- \(finishText) \(item.title)"
                        if let time = eventTotalTime[item.id] {
                            content += " (\(time.simpleTimeStr)) "
                        }
                        
                        content += "\n"
                    }
                    
                    if let summaryContent = summaryTagContens[tag.id], summaryContent.count > 0 {
                        content += "```\n\(summaryContent)\n```\n"
                    }
                }
            }
            
        
            if summaryItems.count > 0 {
                content += "\n## 思考\n"
                summaryItems.forEach { item in
                    content += "```\n\(item.content)\n```\n"
                }
            }
        
            if readList.count > 0 {
                content += "\n## 阅读\n"
                readList.forEach { read in
                    let title = read.title.count > 0 ? read.title : "无标题"
                    content += "\n- [\(title)](readlist://\(read.id))\n"
                }
            }
            
            DispatchQueue.main.async {
                completion(content)
            }
        }
        
    }
    
}

// MARK: event view
extension PlanView {
    
    func eventListHeaderView() -> some View {
        HStack {
            Text("本\(timeTab.timeTitle)事项").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "884ea0"))
            let count = eventList.count
            let finishCount = eventList.filter { $0.event.isFinish }.count
            let numText = " (\(finishCount)/\(count))"
            Text(numText).foregroundStyle(.gray)
            
            Spacer()
            
            if timeTab == .day {
                Button {
                    let event = EventItem()
                    event.actionType = .task
                    event.planTime = .now
                    event.setPlanTime = true
                    event.title = "新建任务"
                    modelData.updateItem(event) {
                        self.selectItemID = event.id
                    }
                } label: {
                    Image(systemName: "plus").foregroundStyle(Color.init(hex: "884ea0")).bold()
                }
                .buttonStyle(.plain)
            }
            
            
            if count > 5 {
                Button {
                    self.isEventListExpand = !self.isEventListExpand
                } label: {
                    Image(systemName: isEventListExpand ? "chevron.down" : "chevron.right").foregroundStyle(Color.init(hex: "884ea0"))
                }
                .buttonStyle(.plain)
            }
            
            
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func eventListView() -> some View {
        VStack(alignment: .leading) {
            let eventList = isEventListExpand ? self.eventList : Array(self.eventList.prefix(5))
            ForEach(eventList, id: \.self.event.id) { item in
                eventItemView(item: item).id(item.event.id)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "884ea0").opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func eventItemView(item: PlanEventItem) -> some View {
        HStack(alignment: .center) {
            Toggle("", isOn: .constant(item.event.isFinish))
            
            Text(item.event.title)
            
            
            if item.interval > 0 {
                let title = " (\(item.interval.simpleTimeStr))"
                Text(title).foregroundStyle(.gray)
            }
            
            Spacer()
            
            if item.event.isPlay {
                Text("进行中").foregroundStyle(.blue)
            }
            
            if let personalItem = item.personalItem {
                let color = personalItem.num > 0 ? personalItem.tag.goodColor : personalItem.tag.badColor
                let title = "\(personalItem.tag.tag) \(personalItem.num.symbolStr)"
                tagView(title: title, color: color)
            }
            
            if item.event.isFinish, item.event.finishState != .normal {
                tagView(title: item.event.finishState.description, color: Color.init(hex: item.event.finishState.titleColor))
            }
            
            if item.event.needReview {
                if !item.event.finishReview {
                    tagView(title: "待复盘", color: Color.init(hex: "e74c3c"))
                } else {
                    tagView(title: "已复盘", color: Color.init(hex: "2ecc71"))
                }
            }
            
            if let tag = modelData.tagList.first(where: {  $0.id == item.event.tag }) {
                tagView(title: tag.title, color: tag.titleColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.selectItemID = item.event.id
        }
        .contextMenu {
            if item.event.actionType != .tag {
                if item.event.isPlay {
                    Button {
                        Self.stopItem = item.event
                        showStopAlert.toggle()
                    } label: {
                        Text("stop").foregroundStyle(.yellow)
                    }
                    
                    Button {
                        timerModel.stopTimer()
                        item.event.isPlay = false
                        modelData.updateItem(item.event)
                    } label: {
                        Text("cancel").foregroundStyle(.gray)
                    }
                } else {
                    Button {
                        if timerModel.startTimer(item: item.event) {
                            item.event.isPlay = true
                            item.event.playTime = .now
                            modelData.updateItem(item.event)
                        }
                    } label: {
                        Text("start").foregroundStyle(.green)
                    }
                }
            }
            Button {
                modelData.deleteItem(item.event)
            } label: {
                Text("删除").foregroundStyle(.red)
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            if item.event.id == selectItemID {
                ZStack {
                    Rectangle()
                        .fill(Color.init(hex: "a9cce3"))
                        .cornerRadius(8)
                }
            }
        }
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
    
    func updateEventList() {
        self.eventList = self.modelData.cacheTodayEventList[cacheKey] ?? []
        let cacheKey = self.cacheKey
        let timeItems = modelData.taskTimeItems
        let eventList = selectionMode == .synthesis ? modelData.itemList : modelData.itemList.filter ({ event in
            guard let tag = modelData.tagList.first(where: { $0.id == event.tag }) else {
                return false
            }
            return tag.title == "工作"
        })
        let currentDate = self.currentDate
        let personalTagList = modelData.personalTagList
        
        DispatchQueue.global().async {
            
            var personalEventList = [PersonalEventItem]()
            personalTagList.forEach { tag in
                let items = self.personalEventItems(with: tag, eventList: eventList)
                personalEventList += items
            }
            
            let planEventList = eventList.filter { event in
                guard event.setPlanTime else { return false }
                if timeTab == .day {
                    var timeResult = false
                    if event.actionType == .task {
                        timeResult = event.planTime?.isInSameDay(as: currentDate) ?? false
                    } else if event.actionType == .project {
                        if let startTime = event.planTime?.startOfDay, let deadlineTime = event.deadlineTime?.endOfDay {
                            timeResult = startTime >= currentDate && currentDate <= deadlineTime
                        }
                    }
                    return timeResult || timeItems.filter { $0.eventId == event.id && $0.startTime.isSameTime(timeTab: timeTab, date: currentDate)}.count > 0
                }
                
                return timeItems.filter { $0.eventId == event.id && $0.startTime.isSameTime(timeTab: timeTab, date: currentDate)}.count > 0
            }.compactMap { event in
                let interval = event.timeTasks(with: timeTab, tasks: timeItems, selectDate: currentDate).compactMap { $0.interval }.reduce(0, +)
                let personalItem = personalEventList.first(where: { $0.item.id == event.id })
                return PlanEventItem(event: event, interval: interval, personalItem: personalItem)
            }.sorted {
                if $0.event.isFinish != $1.event.isFinish {
                    return $0.event.isFinish ? false : true
                }
                return $0.interval > $1.interval
            }
            DispatchQueue.main.async {
                self.eventList = planEventList
                self.modelData.cacheTodayEventList[cacheKey] = planEventList
            }
        }
        
    }
    
    func personalEventItems(with tag: PersonalTag, eventList: [EventItem]) -> [PersonalEventItem] {
        return tag.goodEvents.compactMap { (key, value) in
            guard let event = eventList.first(where: { $0.id == key }) else {
                return nil
            }
            return PersonalEventItem.init(item: event, tag: tag, num: value)
        } + tag.badEvents.compactMap { (key, value) in
            guard let event = eventList.first(where: { $0.id == key }) else {
                return nil
            }
            return PersonalEventItem.init(item: event, tag: tag, num: value)
        }.sorted(by: {  $0.num > $1.num })
    }
    
}

// MARK: read view
extension PlanView {
    
    func readItemHeaderView() -> some View {
        HStack {
            Text("本\(timeTab.timeTitle)阅读").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "dc7633"))
            let count = readItems.count
            if count > 0 {
                let numText = " (\(count))"
                Text(numText).foregroundStyle(.gray)
            }
            
            Spacer()
            
            if count > 5 {
                Button {
                    self.isReadListExpand = !self.isReadListExpand
                } label: {
                    Image(systemName: isReadListExpand ? "chevron.down" : "chevron.right").foregroundStyle(Color.init(hex: "dc7633"))
                }
                .buttonStyle(.plain)
            }
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func readItemListView() -> some View {
        VStack(alignment: .leading) {
            let readItems = isReadListExpand ? self.readItems : Array(self.readItems.prefix(5))
            ForEach(readItems, id: \.self) { item in
                readItemView(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "dc7633").opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func readItemView(item: ReadModel) -> some View {
        return HStack {
            let title = item.title.count > 0 ? item.title : "无标题"
            Text(title)
            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .onTapGesture {
            self.selectItemID = item.id
        }
        .background {
            if item.id == selectItemID {
                ZStack {
                    Rectangle()
                        .fill(Color.init(hex: "dc7633"))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    func updateReadItems() {
        print("update read items")
        readItems = modelData.readList.filter { item in
            guard let createTime = item.createTime else {
                return false
            }
            return createTime.isSameTime(timeTab: timeTab, date: currentDate)
        }
    }
    
}

// MARK: note view
extension PlanView {
    
    func noteItemHeaderView() -> some View {
        HStack {
            Text("本\(timeTab.timeTitle)笔记").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "f5b041"))
            Spacer()
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func noteItemsView() -> some View {
        VStack(alignment: .leading) {
            ForEach(noteItems, id: \.self) { item in
                noteItemView(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "f5b041").opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func noteItemView(item: NoteModel) -> some View {
        HStack {
            Text(item.title)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.selectItemID = item.id
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            if item.id == selectItemID {
                ZStack {
                    Rectangle()
                        .fill(Color.init(hex: "f5b041"))
                        .cornerRadius(8)
                }
            }
        }
        .contextMenu {
            Button {
                modelData.deleteNote(item)
            } label: {
                Text("删除").foregroundStyle(.red)
            }
        }
    }
    
    func updateNoteItems() {
        noteItems = modelData.noteList.filter({ note in
            guard let createTime = note.createTime else {
                return false
            }
            return currentDate.isSameTime(timeTab: timeTab, date: createTime)
        }).sorted(by: { ($0.createTime?.timeIntervalSince1970 ?? 0) > ($1.createTime?.timeIntervalSince1970 ?? 0)
        })
    }
}

// MARK: Summary Think View
extension PlanView {
    
    func summaryItemHeaderView() -> some View {
        HStack {
            Text("本\(timeTab.timeTitle)思考").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "f5b041"))
            Spacer()
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func summaryItemsView() -> some View {
        VStack(alignment: .leading) {
            ForEach(summaryItems, id: \.self) { item in
                summaryItemView(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "f5b041").opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func summaryItemView(item: SummaryItem) -> some View {
        HStack {
            Text(item.content)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.selectItemID = item.id
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            if item.id == selectItemID {
                ZStack {
                    Rectangle()
                        .fill(Color.init(hex: "f5b041"))
                        .cornerRadius(8)
                }
            }
        }
        .contextMenu {
            Button {
                modelData.deleteSummaryItem(item)
            } label: {
                Text("删除").foregroundStyle(.red)
            }
        }
    }
    
    func updateSummaryItems() {
        print("update summary items")
        summaryItems = modelData.summaryItemList.filter({ item in
            guard let createTime = item.createTime else {
                return false
            }
            return currentDate.isSameTime(timeTab: timeTab, date: createTime) && item.summaryDate == nil
        }).sorted(by: { ($0.createTime?.timeIntervalSince1970 ?? 0) > ($1.createTime?.timeIntervalSince1970 ?? 0)
        })
    }
    
}

// MARK: Summary Time View
extension PlanView {
    
    func summaryTimeHeaderView() -> some View {
        HStack {
            Text("统计时间").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "48c9b0"))
            
            if summaryTagTotalTime > 0 {
                let percent = Int((Double(summaryTagTotalTime) / Double(timeTab.totalTimeMins)) * 100)
                Text("\(percent)%").foregroundStyle(Color.init(hex: "48c9b0"))
            }
            Spacer()
            
            Button {
                self.summaryTimeExpand = !self.summaryTimeExpand
                
                sortedTagList.forEach { tag in
                    self.updateExpandState(with: tag, state: summaryTimeExpand)
                }
            } label: {
                Image(systemName: summaryTimeExpand ? "chevron.down" : "chevron.right").foregroundStyle(Color.init(hex: "117a65"))
            }
            .buttonStyle(.plain)
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func summaryTagTimeItems() -> some View {
        VStack(alignment: .leading) {
            ForEach(sortedTagList, id: \.self) { item in
                summaryTagItemView(tag: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "48c9b0").opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func summaryTagItemView(tag: ItemTag) -> some View {
        let isExpand = expandState(with: tag)
        return VStack(spacing: isExpand ? 10 : 0) {
            HStack {
                Text(tag.title).foregroundStyle(tag.titleColor).bold()
                Spacer()
                if let time = tagTotalTimes[tag.id], time > 0 {
                    ProgressBar(percent: (CGFloat(time) / CGFloat(timeTab.totalTimeMins)), progressColor: tag.titleColor, showBgView: false, maxWidth: 400)
                    Text((time * 60).simpleTimeStr).foregroundStyle(tag.titleColor).frame(width: 60)
                }
                
                Image(systemName: isExpand ? "chevron.down" : "chevron.right").foregroundStyle(tag.titleColor).frame(width: 20)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                updateExpandState(with: tag)
            }
            .contextMenu {
                if let tagContent = currentSummaryItem?.summaryTags[tag.id] {
                    
                } else {
                    Button {
                        let item = self.currentSummaryItem ?? SummaryItem()
                        item.summaryTags[tag.id] = ""
                        item.summaryDate = currentDate
                        item.time = timeTab.rawValue
                        modelData.updateSummaryItem(item)
                    } label: {
                        Text("总结\(tag.title)内容").foregroundStyle(tag.titleColor)
                    }
                }
            }
            
            summaryTagItemListView(tag: tag)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(isExpand ? 1 : 0)
            
            if isExpand {
                if let item = currentSummaryItem, let tagContent = item.summaryTags[tag.id] {
                    let key = cacheKey + tag.id
                    summaryTagEditView(item: item, tagContent: tagContent, tag: tag)
                        .tag(key)
                }
            }
            
        }
        .contentShape(Rectangle())
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .frame(maxHeight: (isExpand ? .none : 25), alignment: .top)
    }
    
    func summaryTagEditView(item: SummaryItem, tagContent: String, tag: ItemTag) -> some View {
        let key = cacheKey + tag.id
        let isEdit = modelData.isEditing(id: key, def: tagContent.isEmpty)
        return HStack {
            ZStack {
                if isEdit {
                    TextEditor(text: Binding(get: {
                        item.summaryTags[tag.id] ?? ""
                    }, set: { value in
                        item.summaryTags[tag.id] = value
                    }))
                        .font(.system(size: 12))
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.hidden)
                        .frame(minHeight: 80)
                } else {
                    MarkdownWebView(item.summaryTags[tag.id] ?? "")
                        .frame(minHeight: 50)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                let title = isEdit ? "保存" : "编辑"
                Button(title) {
                    if isEdit {
                        modelData.updateSummaryItem(item)
                    }
                    modelData.markEdit(id: key, edit: !isEdit)
                }
            }
                
        }
        .padding()
        .background(tag.titleColor.opacity(0.3))
        .cornerRadius(8)
    }
    
    func summaryTagItemListView(tag: ItemTag) -> some View {
        return VStack {
            if let items = tagItemList[tag.id], items.count > 0 {
                ForEach(items, id: \.self) { item in
                    summaryItemView(item: item, tagColor: tag.titleColor)
                }
            }
        }
    }
    
    func summaryItemView(item: EventItem, tagColor: Color) -> some View {
        HStack {
            Text(item.title)
            Spacer()
            if timeTab == .day {
                let tagItems = modelData.taskTimeItems.filter { $0.eventId == item.id && $0.stateTagId.count > 0 && $0.startTime.isSameTime(timeTab: timeTab, date: currentDate)}.compactMap { item in
                    modelData.noteTagList.first(where: { $0.id == item.stateTagId })
                }
                if tagItems.count > 0 {
                    ForEach(tagItems, id: \.self.id) { tag in
                        tagView(title: tag.content, color: .blue)
                    }
                }
            }
            if let totalTime = eventTotalTime[item.id] {
                Text(totalTime.simpleTimeStr).foregroundStyle(tagColor)
            }
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background {
            ZStack {
                let bgColor = item.id == selectItemID ? tagColor.opacity(0.5) : tagColor.opacity(0.2)
                Rectangle()
                    .fill(bgColor)
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
            }
        }
        .onTapGesture {
            selectItemID = item.id
        }
    }
    
    func expandState(with tag: ItemTag) -> Bool {
        return tagExpandState[tag.id] ?? false
    }
    
    func updateExpandState(with tag: ItemTag, state: Bool? = nil) {
        if let expand = tagExpandState[tag.id] {
            tagExpandState[tag.id] = state ?? !expand
        } else {
            tagExpandState[tag.id] = state ?? false
        }
    }
    
    func updateTagSummaryTime() {
        print("update tag time items")
        let cacheKey = self.cacheKey
        self.tagTotalTimes = modelData.cacheTodayTagTotalTimes[cacheKey] ?? [:]
        self.eventTotalTime = modelData.cacheTodayEventTotalTimes[cacheKey] ?? [:]
        self.tagItemList = modelData.cacheTodayTagItemList[cacheKey] ?? [:]
        self.sortedTagList = modelData.cacheTodayTagList[cacheKey] ?? []
        
        let tagList = modelData.tagList
        let timeItems = modelData.taskTimeItems
        let itemList = modelData.itemList
        
        var totalTimes = 0
        var tagEventList = [String: [EventItem]]()
        var eventTotalTime = [String: Int]()
        var tagTotalTimes = [String: Int]()
        
        DispatchQueue.global().async {
            tagList.forEach { tag in
                var eventList: [EventItem] = []
                let filteredItems = timeItems.filter { time in
                    guard let event = itemList.first(where: { $0.id == time.eventId }) else {
                        return false
                    }
                    let result = event.tag == tag.id && time.endTime.isSameTime(timeTab: timeTab, date: currentDate)
                    if result && !eventList.contains(event) {
                        eventList.append(event)
                    }
                    if result {
                        var totalTime = eventTotalTime[event.id] ?? 0
                        totalTime += time.interval
                        eventTotalTime[event.id] = totalTime
                    }
                    return result
                }
                let totalInterval = filteredItems.compactMap { Int($0.interval / 60) }.reduce(0, +)
                tagTotalTimes[tag.id] = totalInterval
                totalTimes += totalInterval
                tagEventList[tag.id] = eventList.sorted { first, second in
                    if let firstTime = eventTotalTime[first.id], let secondTime = eventTotalTime[second.id] {
                        return firstTime > secondTime
                    }
                    return false
                }
            }
            
            DispatchQueue.main.async {
                self.tagTotalTimes = tagTotalTimes
                self.eventTotalTime = eventTotalTime
                self.tagItemList = tagEventList
                self.sortedTagList = tagList.filter({ tag in
                    (tagTotalTimes[tag.id] ?? 0) > 0
                }).sorted(by: { first, second in
                    guard let firstTime = tagTotalTimes[first.id], let secondTime = tagTotalTimes[second.id] else {
                        return false
                    }
                    return firstTime > secondTime
                })

                self.modelData.cacheTodayTagTotalTimes[cacheKey] = self.tagTotalTimes
                self.modelData.cacheTodayEventTotalTimes[cacheKey] = self.eventTotalTime
                self.modelData.cacheTodayTagItemList[cacheKey] = self.tagItemList
                self.modelData.cacheTodayTagList[cacheKey] = self.sortedTagList
            }
        }
    }
    
}

// MARK: plan view
extension PlanView {
    
    func planHeaderView() -> some View {
        HStack {
            Text("目标时间").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "2874a6"))
            Spacer()
            Text("+").bold().font(.system(size: 25)).foregroundStyle(Color.init(hex: "2874a6"))
                .onTapGesture {
                    self.selectItemID = ToDoListView.newPlanTimeItemId
                }
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func planItemsView() -> some View {
        VStack(alignment: .leading) {
            ForEach(planTimeItems, id: \.self) { item in
                planItemView(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "2874a6").opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
        
    }
    
    func planItemView(item: PlanTimeItem) -> some View {
        HStack {
            Text(item.content)
            Spacer()
            ProgressBar(percent: item.percentValue, progressColor: planItemTagColor(item: item))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.selectItemID = item.id
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            if item.id == selectItemID {
                ZStack {
                    Rectangle()
                        .fill(Color.init(hex: "a9cce3"))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    func planItemTagColor(item: PlanTimeItem) -> Color {
        guard let tag = modelData.tagList.first(where: { $0.id == item.tagId
        }) else {
            return .blue
        }
        return tag.titleColor
    }
    
    func updatePlanItems() {
        self.planTimeItems = modelData.planTimeItems.filter({ item in
            item.startTime.isSameTime(timeTab: timeTab, date: currentDate) && item.timeTab == timeTab
        })
    }
    
    func updatePlanTimeInterval() {
        print("update plan time items")
        let timeItems = modelData.taskTimeItems
        let itemList = modelData.itemList
        let planTimeItems = self.planTimeItems
        
        DispatchQueue.global().async {
            planTimeItems.forEach { item in
                let totalInterval = timeItems.filter { time in
                    guard let event = itemList.first(where: { $0.id == time.eventId }) else {
                        return false
                    }
                    return event.tag == item.tagId && time.startTime >= item.startTime && time.startTime <= item.endTime
                }.compactMap { Int($0.interval / 60) }.reduce(0, +)
                if totalInterval != item.totalInterval {
                    item.totalInterval = totalInterval
                    DispatchQueue.main.async {
                        self.modelData.updatePlanTimeItem(item, shouldAdd: false)
                    }
                }
            }
            DispatchQueue.main.async {
                self.planTimeItems = planTimeItems
                self.modelData.asyncUpdateCache(type: .planItem)
            }
        }
    }
    
}

// MARK: importance view
extension PlanView {
    
    func mostImportanceHeaderView() -> some View {
        HStack {
            Text("关键事项").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "e74c3c"))
            Spacer()
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func mostImportanceView() -> some View {
        VStack(alignment: .leading) {
            ForEach(mostImportranceItems, id: \.self) { item in
                mostImportanceItemView(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "fadbd8").opacity(0.6))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func mostImportanceItemView(item: EventItem) -> some View {
        HStack(alignment: .center) {
            Toggle("", isOn: .constant(item.isFinish))
            
            Text(item.title)
            Spacer()
                
            
            if let tag = modelData.tagList.first(where: {  $0.id == item.tag }) {
                tagView(title: tag.title, color: tag.titleColor)
            }
            Text("\(item.progressValue)%")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.selectItemID = item.id
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            if item.id == selectItemID {
                ZStack {
                    Rectangle()
                        .fill(Color.init(hex: "a9cce3"))
                        .cornerRadius(8)
                }
            }
        }
        .contextMenu {
            if item.actionType != .tag {
                if item.isPlay {
                    Button {
                        Self.stopItem = item
                        showStopAlert.toggle()
                    } label: {
                        Text("stop").foregroundStyle(.yellow)
                    }
                    
                    Button {
                        timerModel.stopTimer()
                        item.isPlay = false
                        modelData.updateItem(item)
                    } label: {
                        Text("cancel").foregroundStyle(.gray)
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
            Button {
                modelData.deleteItem(item)
            } label: {
                Text("删除").foregroundStyle(.red)
            }
        }
    }
    
    var cacheKey: String {
        return self.timeTab.rawValue + "_" + self.currentDate.simpleDayMonthAndYear
    }
    
    func updateMostImportanceItems() {
        let cacheKey = self.cacheKey
        self.mostImportranceItems = modelData.cacheTodayMostImportanceItems[cacheKey] ?? []
        
        let startTime = Date()
        let timeTab = self.timeTab
        let currentDate = self.currentDate
        let itemList = selectionMode == .synthesis ? modelData.itemList : modelData.itemList.filter({ event in
            guard let tag = modelData.tagList.first(where: { $0.id == event.tag }) else {
                return false
            }
            return tag.title == "工作"
        })
        DispatchQueue.global().async {
            let items = itemList.filter({ event in
                guard let planTime = event.planTime, let deadlineTime = event.deadlineTime else {
                    return false
                }
                if timeTab == .day {
                    return event.isKeyEvent && planTime.startOfDay <= currentDate && deadlineTime.endOfDay >= currentDate
                }
                return planTime.isSameTime(timeTab: timeTab, date: currentDate) && event.isKeyEvent
            }).sorted(by: {
                ($0.createTime?.timeIntervalSince1970 ?? 0) >= ($1.createTime?.timeIntervalSince1970 ?? 0)
            })
            
            DispatchQueue.main.async {
                self.mostImportranceItems = items
                self.modelData.cacheTodayMostImportanceItems[cacheKey] = items
            }
        }
        
        
        print("update importance items duration: \((Date().timeIntervalSince1970 - startTime.timeIntervalSince1970) * 1000)ms")
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 8))
            .padding(EdgeInsets.init(top: 2, leading: 4, bottom: 2, trailing: 4))
            .background(color)
            .clipShape(Capsule())
    }
    
}

