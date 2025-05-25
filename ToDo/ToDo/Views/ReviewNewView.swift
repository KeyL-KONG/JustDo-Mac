//
//  ReviewNewView.swift
//  ToDo
//
//  Created by LQ on 2025/3/16.
//

import SwiftUI

struct ReviewNewView: View {
    
    @EnvironmentObject var modelData: ModelData
    @State var selectTaskChange: ((BaseModel?) -> ())
    @State var timeTab: TimeTab = .day
    @State var selectItemID: String = ""
    
    @State var selectDate: Date = .now {
        didSet {
            print("select date: \(selectDate)")
        }
    }
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    private let maxWeekIndex: Int = 2
    @Namespace private var animation
    
    var body: some View {
        VStack {
            DayHeaderView()
            
            List(selection: $selectItemID) {
                Section(header: HStack(content: {
                    Text("今日事项")
                })) {
                    ForEach(eventTaskItems, id: \.self.id) { item in
                        eventItemView(item: item)
                    }
                }
                
                Section(header: HStack(content: {
                    Text("今日总结")
                })) {
                    
                }
            }
        }
        .onChange(of: selectItemID, { oldValue, newValue in
            if let item = eventTaskItems.filter({ $0.id == newValue}).first {
                selectTaskChange(item.event)
            }
        })
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
}

extension ReviewNewView {
    
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
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
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

extension ReviewNewView {
    
    func eventItemView(item: EventTaskItem) -> some View {
        HStack {
            if item.type == .task {
                Label("", systemImage: (item.finish ? "checkmark.circle.fill" : "circle"))
            }
            Text(item.title)
            Spacer()
            Text(item.time.simpleTimeStr)
        }
    }
    
    var taskTimeItems: [TaskTimeItem] {
        modelData.taskTimeItems
    }
    
    var eventListItem: [EventItem] {
        modelData.itemList.filter { event in
            guard let planTime = event.planTime else {
                return false
            }
            var result = false
            for interval in event.intervals {
                if dateInTimeTab(interval.end, selectDate: selectDate, tab: timeTab) {
                    result = true
                    break
                }
            }
            
            if taskTimeItems.contains(where: { item in
                item.eventId == event.id && dateInTimeTab(item.endTime, selectDate: selectDate, tab: timeTab)
            }) {
                result = true
            }
            
            return result || (event.actionType == .task && dateInTimeTab(planTime, selectDate: selectDate, tab: timeTab))
        }
    }
    
    var eventTaskItems: [EventTaskItem] {
        var items = [EventTaskItem]()
        
        let rewardList = modelData.rewardList
        for reward in rewardList {
            let totalTime = reward.totalTime(with: timeTab, intervals: reward.intervals, selectDate: selectDate)
            guard totalTime > 0 else { continue }
            let item = EventTaskItem(id: reward.id, title: reward.title, type: .reward, finish: false, mark: reward.mark, time: totalTime, intervals: reward.intervals(with: timeTab, selectDate: selectDate), event: reward)
            items.append(item)
        }
        
        items += eventListItem.compactMap { event in
            let intervals = event.intervals(with: timeTab, selectDate: selectDate) + taskTimeItems.filter { $0.eventId == event.id && dateInTimeTab($0.endTime, selectDate: selectDate, tab: timeTab) }.compactMap { LQDateInterval(start: $0.startTime, end: $0.endTime) }
            return EventTaskItem(id: event.id, title: event.title, type: .task, finish: event.isFinish, mark: event.mark, time: intervals.compactMap{$0.interval}.reduce(0, +), intervals: intervals, event: event)
        }
        
        return items.sorted { $0.time > $1.time }
    }
    
    func dateInTimeTab(_ date: Date, selectDate: Date, tab: TimeTab) -> Bool {
        switch tab {
        case .day:
            return Date.isSameDay(date1: date, date2: selectDate)
        case .week:
            return Date.isSameWeek(date1: date, date2: selectDate)
        case .month:
            return Date.isSameMonth(date1: date, date2: selectDate)
        case .year:
            return date.isInSameYear(as: selectDate)
        case .all:
            return true
        }
    }
}

#Preview {
    ReviewNewView(selectTaskChange: {  _ in
        
    }).environmentObject(ModelData())
}
