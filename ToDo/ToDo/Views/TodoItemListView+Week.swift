//
//  TodoItemListView+Week.swift
//  ToDo
//
//  Created by LQ on 2024/8/11.
//

import SwiftUI

extension TodoItemListView {
    
    var weekDates: [Date] {
        currentDate.weekDays
    }
    
    var weekDateStr: String {
        currentDate.simpleWeek
    }
    
    var summaryItems: [SummaryItem] {
        modelData.summaryItemList
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
                }.frame(minWidth: 800)
            }.onAppear {
                if let currentDate = weekDates.first(where: { $0.isInToday
                }) {
                    proxy.scrollTo(currentDate)
                }
            }
        }
    }
    
    func weekView2() -> some View {
        ScrollView {
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    ForEach(0..<7) { index in
                        let date = weekDates[index]
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
                    }
                }
                
                GridRow {
                    ForEach(0..<7) { index in
                        let date = weekDates[index]
                        let dayItems = items.filter { event in
                            return event.intervals(with: .day, selectDate: date).count > 0 || event.timeTasks(with: .day, tasks: modelData.taskTimeItems, selectDate: date).count > 0 || (event.planTime?.isInSameDay(as: date) ?? false)
                        }
                        VStack(alignment: .leading) {
                            let unfinishItems = dayItems.filter { item in
                                guard let planTime = item.planTime else { return false }
                                return planTime.isInSameDay(as: date) && !item.isFinish
                            }
                            let finishItems = dayItems.filter { !unfinishItems.contains($0) }
                            
                            let rewardItems = modelData.rewardList.filter { reward in
                                return reward.intervals.contains { $0.start.isInSameDay(as: date)
                                }
                            }
                            
//                            let totalTime: Int = (finishItems + unfinishItems).compactMap { event in
//                                event.timeTasks(with: .day, tasks: modelData.taskTimeItems, selectDate: date)
//                            }.compactMap { Int($0.interval) }.reduce(0, +)
                            let totalTime = dayItems.compactMap { event in
                                event.timeTasks(with: .day, tasks: modelData.taskTimeItems, selectDate: date)
                            }.compactMap { items in
                                items.compactMap { $0.interval }.reduce(0, +)
                            }.reduce(0, +)
                            
                            if unfinishItems.count > 0 {
                                VStack {
                                    HStack {
                                        Text("未完成").bold()
                                        Spacer()
                                    }.padding(.horizontal, 5).padding(.top, 5)
                                    ForEach(unfinishItems, id: \.self) { item in
                                        weekItemView(item: item, date: date, selectColor: Color(hex: "fad7a0"))
                                    }
                                }
                                .background(Color.init(hex: "fdebd0"))
                                .cornerRadius(10)
                            }
                            
                            
                            if finishItems.count > 0 {
                                VStack {
                                    HStack {
                                        Text("已完成").bold()
                                        Spacer()
                                    }.padding(.horizontal, 5).padding(.top, 5)
                                    ForEach(finishItems, id: \.self) { item in
                                        weekItemView(item: item, date: date, selectColor: Color.init(hex: "a9dfbf"))
                                    }
                                    
                                }
                                .padding(.top, (unfinishItems.isEmpty ? 0 : 10))
                                .background(Color.init(hex: "d4efdf"))
                                .cornerRadius(10)
                                
                            }
                            
                            
                            if rewardItems.count > 0 {
                                VStack {
                                    HStack {
                                        Text("积分事项").bold()
                                        Spacer()
                                    }.padding(.horizontal, 5).padding(.top, 5)
                                    ForEach(rewardItems, id: \.self) { item in
                                        weekItemView(item: item, date: date, selectColor: .clear)
                                    }
                                    Spacer()
                                }
                                .padding(.top, 10)
                                .background(Color.init(hex: "d4e6f1"))
                                .cornerRadius(10)
                            }
                            
                            let summaryItems = modelData.summaryItemList.filter { item in
                                guard let createTime = item.createTime else {
                                    return false
                                }
                                return createTime.isInSameDay(as: date)
                            }
                            
                            if summaryItems.count > 0 {
                                VStack {
                                    HStack {
                                        Text("想法").bold()
                                        Spacer()
                                    }.padding(.horizontal, 5).padding(.top, 5)
                                    ForEach(summaryItems, id: \.self) { item in
                                        summaryItemView(item: item, selectColor: Color.init(hex: "aed6f1"))
                                    }
                                    
                                }
                                .padding(.top, ((unfinishItems.isEmpty && finishItems.isEmpty) ? 0 : 10))
                                .background(Color.init(hex: "ebf5fb"))
                                .cornerRadius(10)
                            }
                            
                            if totalTime > 0 {
                                Spacer()
                                
                                VStack {
                                    HStack {
                                        Text("已投入：\(totalTime.simpleTimeStr)").bold()
                                        Spacer()
                                    }
                                }
                                .padding(10)
                                .background(Color.init(hex: "e8daef"))
                                .cornerRadius(10)
                            } else {
                                Spacer()
                            }
                        }
                        
                    }
                }
            }
            .frame(minWidth: 1000)
            .padding()
        }
    }
    
    func weekItemView(item: any BasicTaskProtocol, date: Date = .now, selectColor: Color) -> some View {
        let itemColor = selectItemID == item.id ? selectColor : .clear
        return itemRowView(item: item, date: date, showTag: true, showDeadline: false, showMark: true, isVertical: true)
            .contentShape(Rectangle())
            .cornerRadius(5)
            .background(itemColor)
            .padding(5)
            .onTapGesture {
                selectItemID = item.id
            }
    }
    
    func summaryItemView(item: SummaryItem, selectColor: Color) -> some View {
        let itemColor = selectItemID == item.id ? selectColor : .clear
        return HStack {
            let text = item.content.count <= 25 ? item.content : "\(item.content.prefix(25)))..."
            Text(text)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            LinearGradient(
                                colors: [Color.init(hex: "ebdef0"), Color.init(hex: "e8daef")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 4
                        )
                )

        }
        .contentShape(Rectangle())
        .cornerRadius(5)
        .background(itemColor)
        .padding(5)
        .onTapGesture {
            selectItemID = item.id
        }
        
    }
    
}
