//
//  iOSTaskTimelineView.swift
//  ToDo
//
//  Created by LQ on 2025/7/27.
//
#if os(iOS)
import SwiftUI

@available(iOS 17.0, *)
struct iOSTaskTimelineView: View {
    
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false
    
    @State private var createTask: Bool = false
    @State private var showingEditTaskView = false
    @State private var showingTimeIntervalView = false
    private static var selectedTimeItem: TimelineItem?
    private static var selectedTimeInterval: Date?
    @EnvironmentObject var modelData: ModelData

    @Namespace private var animation
    
    var timelineItems: [TimelineItem] {
        if let items = modelData.cacheTimelineItems[currentDate] {
            return items
        }
        let items = self.timelineItems(with: currentDate)
        modelData.cacheTimelineItems[currentDate] = items
        return items
    }
    
    func timelineItems(with date: Date) -> [TimelineItem] {
        if let items = modelData.cacheTimelineItems[currentDate] {
            return items
        }
        var items = [TimelineItem]()
        modelData.itemList.forEach { event in
            modelData.taskTimeItems.filter { item in
                item.eventId == event.id && (item.startTime.isInSameDay(as: date) || item.endTime.isInSameDay(as: date)) && item.interval > 60 && item.interval < 60 * 60 * 12
            }.forEach { item in
                let timeItem = TimelineItem(event: event, interval: LQDateInterval(start: item.startTime, end: item.endTime), timeItem: item)
                items.append(timeItem)
            }
        }
        items = items.sorted { $0.interval.start.timeIntervalSince1970 < $1.interval.start.timeIntervalSince1970 }
        modelData.cacheTimelineItems[currentDate] = items
        return items
    }
    
    func totalTimeIntervals(date: Date) -> Int {
        let startTime = date.startTimeOfDay
        let endTime = date.lastTimeOfDay
        var totalIntervals = 0
        timelineItems(with: date).filter { item in
            return item.interval.end >= startTime && item.interval.end <= endTime
        }.forEach { item in
            totalIntervals += item.interval.interval
        }
        return totalIntervals
    }
    
    func needFillDate(_ date: Date) -> Bool {
        let totalIntervals = totalTimeIntervals(date: date)
        let minIntervals = date.isWeekend ? 8 * 60 * 60 : 12 * 60 * 60
        return totalIntervals < minIntervals
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView()
            
            ScrollView(.vertical) {
                VStack(content: {
                    TimelineView()
                })
                .hSpacing(.center)
                .vSpacing(.center)
            }
            .scrollIndicators(.hidden)
            
        }
        .vSpacing(.top)
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                iOSTaskTimelineView.selectedTimeItem = nil
                showingEditTaskView.toggle()
            }, label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
            })
            .padding(15)
        })
        .onAppear(perform: {
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
        })
        .sheet(isPresented: $showingEditTaskView) {
            EditTaskView(showSheetView: $showingEditTaskView, setPlanTime: true, setReward: false)
               .environmentObject(modelData)
        }
        .sheet(isPresented: $showingTimeIntervalView) {
            if let selectedTimeItem = iOSTaskTimelineView.selectedTimeItem {
                iOSEditTimeIntervalView(showSheetView: $showingTimeIntervalView, startTime: selectedTimeItem.interval.start, endTime: selectedTimeItem.interval.end, selectedTimeItem: selectedTimeItem).environmentObject(modelData)
                    .presentationDetents([.medium])
            } else {
                let startTime = Self.selectedTimeInterval ?? .now
                if let timeItem = fixTimeItems(date: startTime), (timeItem.interval.start.minutesBetweenDates(date: startTime) < 120 || timeItem.interval.end.minutesBetweenDates(date: startTime) < 120) {
                    iOSEditTimeIntervalView(showSheetView: $showingTimeIntervalView, startTime: timeItem.interval.start, endTime: timeItem.interval.end, lastTimeItem: timeItem)
                        .presentationDetents([.medium])
                } else {
                    let endTime = startTime.dateByAddingMinutes(60)
                    let lastItem = lastTimeItem(date: currentDate)
                    iOSEditTimeIntervalView(showSheetView: $showingTimeIntervalView, startTime: startTime, endTime: endTime, lastTimeItem: lastItem)
                        .presentationDetents([.medium])
                }
                
            }
        }
    }
    
    func fixTimeItems(date: Date) -> TimelineItem? {
        var items = [TimelineItem]()
        
        modelData.rewardList.forEach { reward in
            reward.fixTimes.forEach { interval in
                
                func appendItem() {
                    if interval.start.day != interval.end.day {
                        if date.hour >= 23 {
                            let item = TimelineItem(event: reward, interval: LQDateInterval(start: interval.start.toSameDay(date: date), end: interval.end.toSameDay(date: date.tomorrowDay)))
                            items.append(item)
                        } else {
                            let item = TimelineItem(event: reward, interval: LQDateInterval(start: interval.start.toSameDay(date: date.yesterday), end: interval.end.toSameDay(date: date)))
                            items.append(item)
                        }
                    } else {
                        let item = TimelineItem(event: reward, interval: LQDateInterval(start: interval.start.toSameDay(date: date), end: interval.end.toSameDay(date: date)))
                        items.append(item)
                    }
                }
                
                switch reward.fixTimeType {
                case .onlyWeek:
                    if !date.isWeekend {
                        appendItem()
                    }
                case .onlyWeekend:
                    if date.isWeekend {
                        appendItem()
                    }
                case .everyday:
                    appendItem()
                }
            }
        }
        return items.sorted { min(abs($0.interval.start.timeIntervalSince1970 - date.timeIntervalSince1970), abs($0.interval.end.timeIntervalSince1970 - date.timeIntervalSince1970)) < min(abs($1.interval.start.timeIntervalSince1970 - date.timeIntervalSince1970), abs($1.interval.end.timeIntervalSince1970 - date.timeIntervalSince1970))
        }.first
    }
    
    func lastTimeItem(date: Date) -> TimelineItem? {
        let lastDate = date.previousWeekDate
        let startTime = Self.selectedTimeInterval ?? .now
        let lastItem = timelineItems(with: lastDate).sorted(by: { first, second in
            return first.interval.start.minutesBetweenDates(date: startTime) < second.interval.start.minutesBetweenDates(date: startTime)
        }).filter { item in
            let intervals = item.interval.start.timeIntervalsBetweenDates(date: startTime)
            return intervals < 60 * 60
        }.first
        return lastItem
    }
    
    @available(iOS 17.0, *)
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading) {
            /// Week Slider
            TabView(selection: $currentWeekIndex,
                    content:  {
                ForEach(weekSlider.indices, id: \.self) { index in
                    let week = weekSlider[index]
                    WeekView(week)
                        .padding(.horizontal, 15)
                        .tag(index)
                }
            })
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
        }
        .hSpacing(.leading)
        //.padding(15)
        .background(.white)
        .onChange(of: currentWeekIndex, initial: false) { oldValue, newValue in
            if newValue == 0 || newValue == (weekSlider.count - 1) {
                createWeek = true
            }
        }
    }
    
    /// Week View
    @available(iOS 17.0, *)
    @ViewBuilder
    func WeekView(_ weeks: [Date.WeekDay]) -> some View {
        HStack(spacing: 0, content: {
            ForEach(weeks) { day in
                VStack(spacing: 8, content: {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .textScale(.secondary)
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                        .background {
                            if needFillDate(day.date), day.date < Date.now, !day.date.isToday {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y: 5)
                            }
                        }
                    
                    Text(day.date.format("dd"))
                        .font(.callout)
                        .textScale(.secondary)
                        .fontWeight(.bold)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .gray)
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day.date, currentDate) {
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
                        currentDate = day.date
                    }
                }
            }
        })
        .background {
            GeometryReader(content: { geometry in
                let minX = geometry.frame(in: .global).minX
                Color.clear
                    .preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self, perform: { value in
                        if value.rounded() == 15 && createWeek {
                            print("Generate")
                            paginateWeek()
                            createWeek = false
                        }
                    })
            })
        }
    }
    
    @ViewBuilder
    func TimelineView() -> some View {
        ScrollViewReader(content: { proxy in
            let hours = Calendar.current.hours(with: currentDate)
            let midHour = hours[hours.count / 2]
            VStack(spacing: 0) {
                ForEach(hours, id: \.self) { hour in
                    TimelineViewRow(hour).id(hour)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Self.selectedTimeInterval = hour
                            iOSTaskTimelineView.selectedTimeItem = nil
                            showingTimeIntervalView = true
                    }
                }
            }
            .onAppear(perform: {
                proxy.scrollTo(midHour)
            })
            .overlay {
                
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        ForEach(timelineItems.indices, id: \.self) { index in
                            let item = timelineItems[index]
                            let tag = modelData.tagList.filter({ $0.id == item.event.tag}).first ?? .work
                            if index == 0 {
                                let marginHeight = Date.timelineHeight(start: currentDate.startTimeOfDay, end: item.interval.start)
                                if marginHeight > 0 {
                                    Spacer().frame(height: marginHeight)
                                }
                            } else {
                                let lastItem = timelineItems[index-1]
                                let marginHeight = Date.timelineHeight(start: lastItem.interval.end, end: item.interval.start)
                                if marginHeight > 0 {
                                    Spacer().frame(height: marginHeight)
                                }
                            }
                            
                            let start = Date.min(date1: item.interval.start, date2: currentDate.lastTimeOfDay)
                            let end = Date.min(date1: item.interval.end, date2: currentDate.lastTimeOfDay)
                            let height =  Date.timelineHeight(start: start, end: end)
                            
                            TaskRow(item.event, item: item, interval: LQDateInterval(start: start, end: end), height: height)
                            .frame(height: height)
                            .background {
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(tag.titleColor)
                                        .frame(width: 4, height: height)
                                    
                                    Rectangle()
                                        .fill(tag.titleColor.opacity(0.25))
                                        .frame(height: height)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    iOSTaskTimelineView.selectedTimeItem = item
                                    showingEditTaskView.toggle()
                                }
                            }
                            .swipeActions {
                                Button(action: {
                                    print("delete item")
                                }) {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }.padding(.leading, 55)
                }
                
            }
        })
    
    }
    
    @ViewBuilder
    func TimelineViewRow(_ hour: Date) -> some View {
        VStack {
            HStack(alignment: .top, content: {
                Text(hour.format("HH:mm"))
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 40, alignment: .leading)
                
                Rectangle()
                    .stroke(.gray.opacity(0.5), style: StrokeStyle(lineWidth: 0.5, lineCap: .butt, lineJoin: .bevel, dash: [5], dashPhase: 5))
                    .frame(height: 0.5)
                    //.offset(y: 10)
                
            })
            .hSpacing(.leading)
            
            Spacer()
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    func TaskRow(_ task: any BasicTaskProtocol, item: TimelineItem? = nil, interval: LQDateInterval? = nil, height: CGFloat = 40) -> some View {
        let tag = modelData.tagList.filter({ $0.id == task.tag }).first ?? .work
        return VStack(alignment: .leading, content: {
            HStack {
                Text(task.title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(tag.titleColor)
                
                if let interval = interval {
                    let start = interval.start.format("HH:mm")
                    let end = interval.end.format("HH:mm")
                    let timeStr = interval.interval.simpleTimeStr
                    Text("\(start) ~ \(end) (\(timeStr))")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(tag.titleColor.opacity(0.8))
                }
            }
            
            if !task.mark.isEmpty {
                Text(task.mark)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(tag.titleColor.opacity(0.8))
            }
            
        })
        .hSpacing(.leading)
        .padding(.leading, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            iOSTaskTimelineView.selectedTimeItem = item
            showingTimeIntervalView.toggle()
        }
    }

    
    func paginateWeek() {
        if weekSlider.indices.contains(currentWeekIndex) {
            if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                weekSlider.insert(firstDate.createPreviousWeek(), at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }
            if let lastDate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
                weekSlider.append(lastDate.createNextWeek())
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
            }
        }
        print(weekSlider.count)
    }
    
}


struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
    
}

#endif
