//
//  Home.swift
//  JustDo
//
//  Created by LQ on 2024/3/29.
//

import SwiftUI

struct TimelineItem: Identifiable {
    var id: UUID = .init()
    let event: any BasicTaskProtocol
    let interval: LQDateInterval
    var timeItem: TaskTimeItem?
}

struct TimelineTaskView: View {
    
    @State var currentDate: Date
    @State var showTask: Bool = true
    
    private static var selectedTimeItem: TimelineItem?
    private static var selectedTimeInterval: Date?
    @EnvironmentObject var modelData: ModelData

    @Namespace private var animation
    
    @State var timelineItems: [TimelineItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
           
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
//        .onChange(of: currentDate, { oldValue, newValue in
//            updateTimelineItems()
//        })
//        .onChange(of: modelData.taskTimeItems, { oldValue, newValue in
//            updateTimelineItems()
//        })
//        .onAppear(perform: {
//            updateTimelineItems()
//        })
    }
    
    func interverlTime() -> LQDateInterval {
        var startTime: Date = Self.selectedTimeInterval ?? .now
        if let lastItem = timelineItems.filter({ $0.interval.end <= startTime }).last {
            startTime = lastItem.interval.end
        }
        var endTime = startTime.dateByAddingMinutes(60)
        if let firstItem = timelineItems.filter({ $0.interval.start >= startTime }).first {
            endTime = firstItem.interval.start
        }
        return LQDateInterval(start: startTime, end: endTime)
    }
    
    func updateTimelineItems() {
        //self.timelineItems = timelineItems(with: currentDate)
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
                            TimelineTaskView.selectedTimeItem = nil
                    }
                }
            }
            .onAppear(perform: {
                proxy.scrollTo(midHour)
            })
            .overlay {
                if showTask {
                    TimelineBgView()
                }
            }
        })
    
    }
    
    @ViewBuilder
    func TimelineBgView() -> some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
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
                                .cornerRadius(5)
                            
                            Rectangle()
                                .fill(tag.titleColor.opacity(0.25))
                                .frame(height: height)
                                .cornerRadius(5)
                        }
                        .padding(.trailing, 10)
                        .padding(.vertical, 5)
                        .cornerRadius(5)
                        .contentShape(Rectangle())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func TimelineViewRow(_ hour: Date) -> some View {
        VStack {
            if showTask {
                HStack(alignment: .top, content: {
                    if !showTask {
                        Text(hour.format("HH:mm"))
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 40, alignment: .leading)
                    } else {
                        Rectangle()
                            .stroke(.gray.opacity(0.5), style: StrokeStyle(lineWidth: 0.5, lineCap: .butt, lineJoin: .bevel, dash: [5], dashPhase: 5))
                            .frame(height: 0.5)
                    }
                })
                .hSpacing(.leading)
            } else {
                HStack(alignment: .center, content: {
                    Spacer()
                    Text(hour.format("HH:mm"))
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 40, alignment: .leading)
                })
                .hSpacing(.leading)
            }
            
            
            Spacer()
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    func TaskRow(_ task: any BasicTaskProtocol, item: TimelineItem? = nil, interval: LQDateInterval? = nil, height: CGFloat = 40) -> some View {
        let tag = modelData.tagList.filter({ $0.id == task.tag }).first ?? .work
        return VStack(alignment: .leading, content: {
            HStack {
                if height <= 15 {
                    Text("")
                } else {
                    Text(task.title.prefix(15))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(tag.titleColor)
                    
                    if let interval = interval {
                        let start = interval.start.format("HH:mm")
                        let end = interval.end.format("HH:mm")
                        let timeStr = interval.interval.simpleTimeStr
                        Text("\(start) ~ \(end) (\(timeStr))")
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(tag.titleColor.opacity(0.8))
                    }
                }
                Spacer()
            }
        })
        .hSpacing(.leading)
        .padding(.leading, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            TimelineTaskView.selectedTimeItem = item
        }
    }
    
}

//#Preview {
//    TimelineTaskView()
//}
