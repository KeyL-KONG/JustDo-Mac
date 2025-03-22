//
//  TodoItemListView+Today.swift
//  ToDo
//
//  Created by LQ on 2024/8/18.
//

import SwiftUI

extension TodoItemListView {
    
    var todayItems: [EventItem] {
        items.filter { event in
            guard let planTime = event.planTime else {
                return false
            }
            return planTime.isToday || modelData.taskTimeItems.contains(where: { $0.eventId == event.id && $0.startTime.isInToday })
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
    
    var expiredItems: [EventItem] {
        items.filter { event in
            guard let planTime = event.planTime else {
                return false
            }
            return !event.isFinish && planTime < .now && !planTime.isInToday && Date.now.daysBetweenDates(date: planTime) <= 14
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
            return createDate.isInSameDay(as: .now)
        }
    }
    
    func todayView() -> some View {
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
                        itemRowView(item: item, showDeadline: false)
                    }
                }
            }
            
            Section(header:
                HStack {
                    Text("即将截止")
                    Spacer()
                    Button(action: { isDeadlineExpanded.toggle() }) {
                        Image(systemName: isDeadlineExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            ) {
                if isDeadlineExpanded {
                    ForEach(recentItems, id: \.self.id) { item in
                        itemRowView(item: item, showDeadline: true)
                    }
                }
            }
            
            Section(header:
                HStack {
                    Text("已过期")
                    Spacer()
                    Button(action: { isExpiredExpanded.toggle() }) {
                        Image(systemName: isExpiredExpanded ? "chevron.down" : "chevron.right")
                    }
                }
            ) {
                if isExpiredExpanded {
                    ForEach(expiredItems, id: \.self.id) { item in
                        itemRowView(item: item, showDeadline: true)
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
