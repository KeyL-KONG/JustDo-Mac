//
//  TodoItemListView+Month.swift
//  ToDo
//
//  Created by LQ on 2024/8/13.
//

import SwiftUI
#if os(macOS)
extension TodoItemListView {
    
    func monthView() -> some View {
        ScrollView {
            if toggleToRefresh {
                Text("")
            }
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                ForEach(0..<6) { row in
                    GridRow {
                        if row == 0 {
                            ForEach(0..<7) { col in
                                Text(weekDays[col]).bold()
                            }
                        } else {
                            ForEach(1..<8) { col in
                                let index = (row - 1) * 7 + col
                                if index >= startOfMonthWeekDay {
                                    let date = dateWithIndex(index)
                                    let dayItems = items.filter { event in
                                        return event.intervals(with: .day, selectDate: date).count > 0 || event.timeTasks(with: .day, tasks: modelData.taskTimeItems, selectDate: date).count > 0 || (event.planTime?.isInSameDay(as: date) ?? false)
                                    }
                                    let bgColor = dayItems.isEmpty ? Color.clear : Color.init(hex: "e9f7ef")
                                    VStack {
                                        Text(date.simpleMonthAndDay)
                                            .padding(.vertical, 5)
                                            .background {
                                                if date.isToday {
                                                    Circle()
                                                        .fill(Color.init(hex: "16a085"))
                                                        .frame(width: 8, height: 8)
                                                        .vSpacing(.trailing)
                                                        .offset(x: 25)
                                                }
                                            }
                                        
                                        ForEach(dayItems) { item in
                                            let itemColor = selectItemID == item.id ? Color.init(hex: "a9dfbf") : .clear
                                            monthItemView(item: item, date: date)
                                                .contentShape(Rectangle())
                                                .cornerRadius(5)
                                                .background(itemColor)
                                                .onTapGesture {
                                                    selectItemID = item.id
                                                }
                                        }
                                        Spacer()
                                    }.background(bgColor)
                                        .cornerRadius(10)
                                } else {
                                    VStack {
                                        Text("")
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
            .frame(minWidth: 1000)
            .padding()
        }
    }
    
    var startOfMonthWeekDay: Int {
        let weekDay = currentDate.firstDayOfMonth.weekday - 1
        return weekDay
    }
    
    var weekDays: [String] {
        return ["一","二","三","四","五","六","日"]
    }
    
    func dateWithIndex(_ index: Int) -> Date {
        let startDate = currentDate.firstDayOfMonth
        let offset = index - startOfMonthWeekDay
        return Calendar.current.date(byAdding: .day, value: offset, to: startDate)!
    }
    
    func monthItemView(item: EventItem, date: Date) -> some View {
        itemRowView(item: item, date: date, showImportance: true, showTag: true,  showDeadline: false, isVertical: true, showIsFinish: true)
            .frame(maxWidth: 200)
    }
    
}

#endif
