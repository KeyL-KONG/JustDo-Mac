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
            return planTime.isToday
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
    
    func todayView() -> some View {
        List(selection: $selectItemID) {
            Section(header: Text("今日事项")) {
                ForEach(todayItems, id: \.self.id) { item in
                     itemRowView(item: item, showDeadline: false)
                }
            }
            
            Section(header: Text("即将截止")) {
                ForEach(recentItems, id: \.self.id) { item in
                     itemRowView(item: item, showDeadline: true)
                }
            }
            
            Section(header: Text("已过期")) {
                ForEach(expiredItems, id: \.self.id) { item in
                     itemRowView(item: item, showDeadline: true)
                }
            }
        }
    }
    
}
