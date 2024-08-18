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
        }
    }
    
}
