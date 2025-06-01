//
//  PlanView.swift
//  ToDo
//
//  Created by LQ on 2025/5/12.
//

import SwiftUI

struct PlanView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State var mostImportranceItems: [EventItem] = []
    @State var planTimeItems: [PlanTimeItem] = []
    @Binding var selectItemID: String
    
    @State var tagTotalTimes: [String: Int] = [:]
    @State var sortedTagList: [ItemTag] = []
    @State var totalTimeMins: Int = 0
    @State var tagExpandState: [String: Bool] = [:]
    @State var tagItemList: [String: [EventItem]] = [:]
    @State var eventTotalTime = [String: Int]()
    
    @State var summaryItems: [SummaryItem] = []
    
    @State var readItems: [ReadModel] = []
    
    @State var eventList: [PlanEventItem] = []
    
    @State var currentDate: Date = .now
    
    @State var isEventListExpand: Bool = false
    @State var isReadListExpand: Bool = false
    @State var isSummaryExpand: Bool = false
    @State var isSummaryEdit: Bool = false
    @State var summaryContent: String = ""
    
    var currentSummaryItem: SummaryItem? {
        modelData.summaryItemList.first { item in
            guard let summaryTime = item.summaryDate else { return false }
            return summaryTime.isInSameWeek(as: currentDate) && item.timeTab == .week
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: true) { // 添加垂直滚动容器
            VStack(spacing: 0) {
                if mostImportranceItems.count > 0 {
                    mostImportanceHeaderView()
                    mostImportanceView()
                }
                
                planHeaderView()
                planItemsView()
                
                summaryTimeHeaderView()
                summaryTagTimeItems()
                
                eventListHeaderView()
                eventListView()
                
                summaryItemHeaderView()
                summaryItemsView()
                
                readItemHeaderView()
                readItemListView()
                
                summaryHeaderView()
                if self.isSummaryExpand {
                    summaryDetailView()
                }
                
                Spacer()
            }
        }
        .onChange(of: currentDate) { old, new in
            updateData()
            updateSummaryContent()
        }
        .onChange(of: modelData.readList) { _, _ in
            updateReadItems()
        }
        .onChange(of: modelData.summaryItemList) { _, _ in
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
        .onReceive(modelData.$itemList) { _ in
            updateMostImportanceItems()
            updateEventList()
        }
        .onReceive(modelData.$planTimeItems, perform: { _ in
            updatePlanItems()
        })
        .onReceive(modelData.$updateItemIndex) { _ in
            updateMostImportanceItems()
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
            Text("本周总结").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "117a65"))
            
            Spacer()
            
            if currentSummaryItem != nil {
                Button {
                    fetchSummaryContent { content in
                        if self.summaryContent.contains("\n## 事项\n") {
                            self.summaryContent =  self.summaryContent.truncateAfter(substring: "\n## 事项\n")
                        }
                        self.summaryContent += content
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
        item.time = TimeTab.week.rawValue
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
        DispatchQueue.global().async {
            var content = ""
            content = "\n## 事项\n"
            items.forEach { item in
                let finishText = !item.event.isFinish && item.event.planTime != nil ? "[ ]" : "[x]"
                let timeText = item.interval > 0 ? "(\(item.interval.simpleTimeStr))" : ""
                content += "- \(finishText) \(item.event.title) \(timeText) \n"
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
            Text("本周事项").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "884ea0"))
            let count = eventList.count
            let finishCount = eventList.filter { $0.event.isFinish }.count
            let numText = " (\(finishCount)/\(count))"
            Text(numText).foregroundStyle(.gray)
            
            Spacer()
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
    
    struct PlanEventItem {
        let event: EventItem
        let interval: Int
        let personalItem: PersonalEventItem?
    }
    
    func updateEventList() {
        let timeItems = modelData.taskTimeItems
        let eventList = modelData.itemList
        let currentDate = self.currentDate
        let personalTagList = modelData.personalTagList
        
        DispatchQueue.global().async {
            
            var personalEventList = [PersonalEventItem]()
            personalTagList.forEach { tag in
                let items = self.personalEventItems(with: tag, eventList: eventList)
                personalEventList += items
            }
            
            let planEventList = eventList.filter { event in
                guard event.planTime != nil else { return false }
                return timeItems.filter { $0.eventId == event.id && $0.startTime.isInSameWeek(as: currentDate)}.count > 0
            }.compactMap { event in
                let interval = event.timeTasks(with: .week, tasks: timeItems, selectDate: currentDate).compactMap { $0.interval }.reduce(0, +)
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
            Text("本周阅读").bold().font(.system(size: 16))
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
            if let url = URL(string: "readlist://\(item.id)") {
                NSWorkspace.shared.open(url)
            }
            
        }
    }
    
    func updateReadItems() {
        print("update read items")
        readItems = modelData.readList.filter { item in
            guard let createTime = item.createTime else {
                return false
            }
            return createTime.isInSameWeek(as: currentDate)
        }
    }
    
}

// MARK: Summary Think View
extension PlanView {
    
    func summaryItemHeaderView() -> some View {
        HStack {
            Text("本周思考").bold().font(.system(size: 16))
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
    }
    
    func updateSummaryItems() {
        print("update summary items")
        summaryItems = modelData.summaryItemList.filter({ item in
            guard let createTime = item.createTime else {
                return false
            }
            return currentDate.isInSameWeek(as: createTime) && item.summaryDate == nil
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
            Spacer()
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
                if let time = tagTotalTimes[tag.id], totalTimeMins > 0 {
                    ProgressBar(percent: (CGFloat(time) / CGFloat(totalTimeMins)), progressColor: tag.titleColor, showBgView: false, maxWidth: 400)
                    Text((time * 60).simpleTimeStr).foregroundStyle(tag.titleColor).frame(width: 60)
                }
                
                Image(systemName: isExpand ? "chevron.down" : "chevron.right").foregroundStyle(tag.titleColor).frame(width: 20)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                updateExpandState(with: tag)
            }
            
            summaryTagItemListView(tag: tag)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(isExpand ? 1 : 0)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .frame(maxHeight: (isExpand ? .none : 25), alignment: .top)
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
    
    func updateExpandState(with tag: ItemTag) {
        if let expand = tagExpandState[tag.id] {
            tagExpandState[tag.id] = !expand
        } else {
            tagExpandState[tag.id] = false
        }
    }
    
    func updateTagSummaryTime() {
        print("update tag time items")
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
                    let result = event.tag == tag.id && time.startTime.isInSameWeek(as: currentDate)
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
                self.totalTimeMins = totalTimes
                self.sortedTagList = tagList.filter({ tag in
                    (tagTotalTimes[tag.id] ?? 0) > 0
                }).sorted(by: { first, second in
                    guard let firstTime = tagTotalTimes[first.id], let secondTime = tagTotalTimes[second.id] else {
                        return false
                    }
                    return firstTime > secondTime
                })

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
            item.startTime.isInSameWeek(as: currentDate)
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
    }
    
    func updateMostImportanceItems() {
        let startTime = Date()
        mostImportranceItems = Array(modelData.itemList.filter({ event in
            guard let planTime = event.planTime else {
                return false
            }
            return planTime.isInSameWeek(as: currentDate) && event.isKeyEvent
        }).sorted(by: {
            ($0.createTime?.timeIntervalSince1970 ?? 0) >= ($1.createTime?.timeIntervalSince1970 ?? 0)
        }).prefix(3))
        print("update importance items duration: \((Date().timeIntervalSince1970 - startTime.timeIntervalSince1970) * 1000)ms")
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 8))
            .padding(EdgeInsets.init(top: 2, leading: 2, bottom: 2, trailing: 2))
            .background(color)
            .clipShape(Capsule())
    }
    
}

