//
//  TodoItemListView+Today.swift
//  ToDo
//
//  Created by LQ on 2024/8/18.
//

import SwiftUI

extension TodoItemListView {
    
    var collectItems: [EventItem] {
        items.filter { event in
            event.isCollect
        }
    }
    
    var unplanItems: [EventItem] {
        items.filter { event in
            guard let createTime = event.createTime else {
                return false
            }
            return event.planTime == nil && createTime.isInSameDay(as: selectDate) && !event.isCollect
        }
    }
    
    var quickItems: [EventItem] {
        items.filter { event in
            event.quickEvent && !todayItems.contains(where: { $0.id == event.id
            })
        }
    }
    
    var expiredItems: [EventItem] {
        let todayItems = self.todayItems
        return items.filter { event in
            guard let planTime = event.planTime else {
                return false
            }
            return !event.isFinish && planTime < .now && !planTime.isInToday && Date.now.daysBetweenDates(date: planTime) <= 14 && !todayItems.contains(event) && event.actionType == .task
        }.sorted { first, second in
            guard let firstPlanTime = first.planTime, let secondPlanTime = second.planTime else { return false }
            let firstDays = Date.now.daysBetweenDates(date: firstPlanTime)
            let secondDays = Date.now.daysBetweenDates(date: secondPlanTime)
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
    
    var summaryItemList: [SummaryItem] {
        modelData.summaryItemList.filter { item in
            guard let createDate = item.createTime else { return false }
            return createDate.isInSameDay(as: selectDate) && item.summaryDate == nil
        }
    }
    
    func todayView() -> some View {
        VStack {
            if toggleToRefreshTodayView {
                Text("")
            }
            DayHeaderView()
            todayListView()
        }
        .onAppear {
            if weekSlider.isEmpty {
                let currentWeek = Date().fetchWeek()
                if let firstDate = currentWeek.first?.date {
                    weekSlider.append(firstDate.createPreviousWeek())
                }
                weekSlider.append(currentWeek)
                if let lastDate = currentWeek.last?.date {
                    weekSlider.append(lastDate.createNextWeek())
                }
            }
        }
    }
    
    func todayListView() -> some View {
        List(selection: $selectItemID) {
            
            Section(header:
                HStack {
                    Text("今日事项")
                    Spacer()
                    Button(action: { isTodayExpanded.toggle() }) {
                        Image(systemName: isTodayExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            ) {
                if isTodayExpanded {
                    ForEach(todayItems, id: \.self.id) { item in
                        itemRowView(item: item, date: selectDate, showDeadline: false)
                    }
                }
            }
            
            Section(header:
                HStack {
                    Text("收藏事项")
                    Spacer()
                Button(action: { isCollectExpanded.toggle() }) {
                    Image(systemName: isCollectExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            ) {
                if isCollectExpanded {
                    ForEach(collectItems, id: \.self.id) { item in
                        itemRowView(item: item, date: selectDate, showDeadline: false)
                    }
                }
            }
            
            Section(header:
                HStack {
                    Text("快捷事项")
                    Spacer()
                Button(action: { isQuickExpanded.toggle() }) {
                    Image(systemName: isQuickExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            ) {
                if isQuickExpanded {
                    ForEach(quickItems, id: \.self.id) { item in
                        itemRowView(item: item, date: selectDate, showDeadline: false)
                    }
                }
            }
            
            
            
            Section(header:
                HStack {
                Text("即将截止 (\(recentItems.count))")
                    Spacer()
                    Button(action: { isDeadlineExpanded.toggle() }) {
                        Image(systemName: isDeadlineExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            ) {
                if isDeadlineExpanded {
                    ForEach(recentItems, id: \.self.id) { item in
                        itemRowView(item: item, date: selectDate, showDeadline: true)
                    }
                }
            }
            
            Section(header:
                HStack {
                Text("已过期 (\(expiredItems.count))")
                    Spacer()
                    Button(action: { isExpiredExpanded.toggle() }) {
                        Image(systemName: isExpiredExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            ) {
                if isExpiredExpanded {
                    ForEach(expiredItems, id: \.self.id) { item in
                        itemRowView(item: item, date: selectDate, showDeadline: true)
                    }
                }
            }
            
            Section(header:
                HStack {
                Text("待规划 (\(unplanItems.count))")
                    Spacer()
                Button(action: { isUnplanExpanded.toggle() }) {
                        Image(systemName: isUnplanExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            ) {
                if isUnplanExpanded {
                    ForEach(unplanItems, id: \.self.id) { item in
                        itemRowView(item: item, date: selectDate, showDeadline: false)
                    }
                }
            }
            
            Section(header:
                HStack {
                    Text("Thinking")
                    Spacer()
                    Button(action: { isSummaryExpanded.toggle() }) {
                        Image(systemName: isSummaryExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            ) {
                if isSummaryExpanded {
                    ForEach(summaryItemList, id: \.self.id) { item in
                        summaryItemView(item: item)
                            .contextMenu {
                                Button {
                                    modelData.deleteSummaryItem(item)
                                } label: {
                                    Text("delete").foregroundStyle(.red)
                                }
                            }
                    }
                }
            }
            
            Section {
                if isPrincipleExpanded {
                    ForEach(principleList, id: \.self.id) { item in
                        principleItemView(item: item)
                            .contextMenu {
                                Button {
                                    updateTaskItem(item: item, state: .good, date: selectDate)
                                } label: {
                                    Text("完成").foregroundStyle(.green)
                                    
                                }
                                
                                Button {
                                    updateTaskItem(item: item, state: .bad, date: selectDate)
                                } label: {
                                    Text("未完成").foregroundStyle(.red)
                                }
                                
                                Button {
                                    updateTaskItem(item: item, state: .none, date: selectDate)
                                } label: {
                                    Text("重置").foregroundStyle(.gray)
                                }
                            }
                    }
                }
            } header: {
                HStack {
                    Text("Principle (\(finishPrincipleTimeItems.count)/\(principleList.count))")
                    Spacer()
                    Button(action: { isPrincipleExpanded.toggle() }) {
                        Image(systemName: isPrincipleExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            }
            
            Section {
                if isAllExpanded {
                    todaySummaryView()
                }
            } header: {
                HStack {
                    Text("Summary")
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
                            Text("同步")
                        }

                    }
                    
                    Button {
                        if currentSummaryItem == nil {
                            updateSummaryItem()
                            isAllExpanded = true
                        } else {
                            if self.isSummaryEdit {
                                updateSummaryItem()
                            }
                            self.isSummaryEdit = !self.isSummaryEdit
                        }
                    } label: {
                        let title = currentSummaryItem == nil ? "添加" : (isSummaryEdit ? "预览" : "编辑")
                        Text(title)
                    }

                    Button(action: { isAllExpanded.toggle() }) {
                        Image(systemName: isAllExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            }
        }
    }
    
    var finishPrincipleTimeItems: [TaskTimeItem] {
        principleList.compactMap { model in
            modelData.taskTimeItems.first { $0.eventId == model.id  && $0.state != .none && $0.startTime.isInSameDay(as: selectDate) && !$0.isPlan }
        }
    }
    
    func principleItemView(item: PrincipleModel) -> some View {
        HStack {
            Text(item.content)
            if let tag = modelData.tagList.first(where: { $0.id == item.tag }) {
                tagView(title: tag.title, color: tag.titleColor)
            }
            Spacer()
            if let taskItem = principleTaskItem(item: item, date: selectDate) {
                if taskItem.state == .good {
                    Text("✅").font(.system(size: 12))
                } else if taskItem.state == .bad {
                    Text("❌").font(.system(size: 11))
                } else {
                    Image(systemName: "square").font(.system(size: 14)).bold()
                }
            } else {
                Image(systemName: "square").font(.system(size: 14)).bold()
            }
        }
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 8))
            .padding(EdgeInsets.init(top: 2, leading: 2, bottom: 2, trailing: 2))
            .background(color)
            .clipShape(Capsule())
    }
    
    
    func updateTaskItem(item: PrincipleModel, state: TaskItemResultState, date: Date) {
        let taskItem = principleTaskItem(item: item, date: date) ?? TaskTimeItem()
        taskItem.startTime = date
        taskItem.endTime = date
        taskItem.state = state
        taskItem.eventId = item.id
        modelData.updateTimeItem(taskItem)
    }
    
    func principleTaskItem(item: PrincipleModel, date: Date) -> TaskTimeItem? {
        return modelData.taskTimeItems.first { $0.eventId == item.id && $0.endTime.isInSameDay(as: date) && !$0.isPlan
        }
    }
    
    
    func summaryItemView(item: SummaryItem) -> some View {
        HStack {
            Text(item.content)
        }
    }
    
}


extension TodoItemListView {
    
    @ViewBuilder
    func DayHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(content: {
                
                let disableLeftButton = currentWeekIndex <= 0
                Button {
                    currentWeekIndex -= 1
                } label: {
                    Image(systemName: "chevron.left").foregroundColor(disableLeftButton ? .gray : .blue).font(.system(size: 20)).bold()
                }.disabled(disableLeftButton)
                    .buttonStyle(BorderlessButtonStyle())
                
                let week = weekSlider.count > currentWeekIndex ? weekSlider[currentWeekIndex] : []
                WeekView(week)
                    .padding(.horizontal, 15)
                
                let disableRightButton = currentWeekIndex >= maxWeekIndex
                Button {
                    currentWeekIndex += 1
                } label: {
                    Image(systemName: "chevron.right").foregroundColor((disableRightButton ? .gray : .blue)).font(.system(size: 20)).bold()
                }.disabled(disableRightButton)
                    .buttonStyle(BorderlessButtonStyle())
            
            })
            .frame(height: 90)
        }
        .hSpacing(.leading)
        .padding(5)
        .background(.white)
    }
    
    @ViewBuilder
    func WeekView(_ weeks: [Date.WeekDay]) -> some View {
        HStack(spacing: 10, content: {
            ForEach(weeks) { day in
                VStack(spacing: 8, content: {
                    Text(day.date.format("E"))
#if os(iOS)
                        .font(.callout)
                        .textScale(.secondary)
                    #endif
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                    
                    Text(day.date.format("dd"))
#if os(iOS)
                        .font(.callout)
                        .textScale(.secondary)
                    #endif
                        .fontWeight(.bold)
                        .foregroundStyle(isSameDate(day.date, selectDate) ? .white : .gray)
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day.date, selectDate) {
                                Circle().fill(.blue)
                                    //.matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                            }
                            
                            if day.date.isToday {
                                Circle()
                                    .fill(.cyan)
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y: 12)
                            }
                        })
                        .background(.white.shadow(.drop(radius: 1)), in: .circle)
                })
                .hSpacing(.center)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation {
                        selectDate = day.date
                    }
                }
            }
        })
    }
    
}

extension TodoItemListView {
    
    func updateTodayItems() {
        self.todayItems = fetchTodayItems()
    }
    
    func fetchTodayItems() -> [EventItem] {
        print("today items")
        let taskTimeItems = modelData.taskTimeItems.filter { !$0.isPlan }
        return items.filter { event in
            guard !event.isCollect else { return false }
            return (event.planTime?.isInSameDay(as: selectDate) ?? false) || taskTimeItems.contains(where: { $0.eventId == event.id && $0.startTime.isInSameDay(as: selectDate) }) || (event.isFinish && (event.finishTime?.isInSameDay(as: selectDate)) == true)
        }.sorted { event1, event2 in
            if event1.setPlanTime != event2.setPlanTime {
                return event1.setPlanTime ? true : false
            }
            else if event1.isFinish != event2.isFinish {
                return event1.isFinish ? false : true
            } else if event1.importance != event2.importance {
                return event1.importance.value > event2.importance.value
            } else {
                return event1.tagPriority(tags: modelData.tagList) > event2.tagPriority(tags: modelData.tagList)
            }
        }
    }
    
}

// MARK: summary view
extension TodoItemListView {
    
    func todaySummaryView() -> some View {
        VStack {
            if isSummaryEdit {
                TextEditor(text: $summaryContent)
                    .font(.system(size: 14))
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .cornerRadius(8)
            } else {
                MarkdownWebView(summaryContent, itemId: (currentSummaryItem?.id ?? ""))
                    .padding(5)
            }
            Spacer()
        }
        .frame(minHeight: 100)
        .background(isSummaryEdit ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
        .cornerRadius(8)
    }
    
    func updateSummaryContent() {
        self.summaryContent = self.currentSummaryItem?.content ?? ""
    }
    
    func updateSummaryItem() {
        let item = currentSummaryItem ?? SummaryItem()
        item.summaryDate = selectDate
        item.time = TimeTab.day.rawValue
        item.content = summaryContent
        modelData.updateSummaryItem(item)
    }
    
    struct SummaryEventItem {
        let event: EventItem
        let interval: Int
    }
    
    func fetchSummaryContent(completion: @escaping (String)->Void) {
        
        let taskItems = modelData.taskTimeItems
        let items = self.todayItems
        let summaryItems = self.summaryItemList
        let readList = modelData.readList
        let selectDate = self.selectDate
        DispatchQueue.global().async {
            var content = ""
            content = "\n## 事项\n"
            items.compactMap { event in
                let interval = event.timeTasks(with: .day, tasks: taskItems, selectDate: selectDate).compactMap { $0.interval }.reduce(0, +)
                return SummaryEventItem.init(event: event, interval: interval)
            }.sorted { first, second in
                let firstUnFinish = !first.event.isFinish && first.event.planTime != nil
                let secondUnFinish = !second.event.isFinish && second.event.planTime != nil
                if firstUnFinish != secondUnFinish {
                    return firstUnFinish ? true : false
                }
                return first.interval > second.interval
            }.forEach { item in
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
            
            let currentReadItems = readList.filter { read in
                guard let createTime = read.createTime else { return false }
                return createTime.isInSameDay(as: selectDate)
            }
            if currentReadItems.count > 0 {
                content += "\n## 阅读\n"
                currentReadItems.forEach { read in
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
