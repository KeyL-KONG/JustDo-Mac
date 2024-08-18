//
//  TodoItemListView+Week.swift
//  ToDo
//
//  Created by LQ on 2024/8/11.
//

import SwiftUI

extension TodoItemListView {
    
    var weekDates: [Date] {
        currentDate.fetchWeekDates()
    }
    
    var weekDateStr: String {
        currentDate.simpleWeek
    }
    
    func weekView() -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(weekDates, id: \.self) { date in
                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                Spacer()
                                Text(date.simpleDayAndWeekStr).bold()
                                    .background {
                                        if date.isToday {
                                            Circle()
                                                .fill(.cyan)
                                                .frame(width: 5, height: 5)
                                                .vSpacing(.bottom)
                                                .offset(y: 12)
                                        }
                                    }
                                Spacer()
                            }.padding()
                            
                            List(selection: $selectItemID) {
                                let unfinishItemList = itemList.filter { event in
                                    guard let planTime = event.planTime else { return false }
                                    return planTime.isInSameDay(as: date) && !event.isFinish
                                }
                                if unfinishItemList.count > 0 {
                                    Section(header:Text("待办事项")) {
                                        ForEach(unfinishItemList) { item in
                                            itemRowView(item: item, showDeadline: false, showMark: true, isVertical: true)
                                        }
                                    }
                                }
                                
                                let finishItemList = itemList.filter { event in
                                    guard let planTime = event.planTime else { return false }
                                    return planTime.isInSameDay(as: date) && event.isFinish
                                }
                                if finishItemList.count > 0 {
                                    Section(header:Text("已完成")) {
                                        ForEach(finishItemList) { item in
                                            itemRowView(item: item, showDeadline: false, showMark: true, isVertical: true)
                                        }
                                    }
                                }
                                
                                if unfinishItemList.isEmpty, finishItemList.isEmpty {
                                    Text("暂无事项")
                                }
                            }
                        }
                        .id(date)
                        .frame(minWidth: 200)
                    }
                }
            }.onAppear {
                if let currentDate = weekDates.first(where: { $0.isInToday
                }) {
                    proxy.scrollTo(currentDate)
                }
            }
        }
    }
}
