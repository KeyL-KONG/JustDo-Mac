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
    
    var todayItems: [EventItem] {
        items.filter { event in
            guard !event.isCollect else { return false }
            return (event.planTime?.isInSameDay(as: selectDate) ?? false) || modelData.taskTimeItems.contains(where: { $0.eventId == event.id && $0.startTime.isInSameDay(as: selectDate) }) || (event.isFinish && (event.finishTime?.isInSameDay(as: selectDate)) == true)
        }.sorted { event1, event2 in
            if event1.isFinish != event2.isFinish {
                return event1.isFinish ? false : true
            } else if event1.importance != event2.importance {
                return event1.importance.value > event2.importance.value
            } else {
                return event1.tagPriority(tags: modelData.tagList) > event2.tagPriority(tags: modelData.tagList)
            }
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
            return createDate.isInSameDay(as: selectDate)
        }
    }
    
    func todayView() -> some View {
        VStack {
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
                    Text("今日想法")
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
