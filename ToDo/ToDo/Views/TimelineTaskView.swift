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
    
    @Binding var selectItemID: String
    @State var currentDate: Date
    @State var showTask: Bool = true
    
    private static var selectedTimeItem: TimelineItem?
    private static var selectedTimeInterval: Date?
    @EnvironmentObject var modelData: ModelData

    @Namespace private var animation
    
    @State var timelineItems: [TimelineItem] = [] {
        didSet {
            print("update timeline items date: \(currentDate.simpleDayMonthAndYear)")
        }
    }
    
    @State var refresh: Bool = false {
        didSet {
            print("current timeline items count: \(timelineItems.count)")
        }
    }
    
    @State var timelinePlanItems: [TimelineItem] = []
    
    @State var showEditTimeItemAlert: Bool = false
    
    @State var selectedTag: String = ""
    @State var itemType: EventActionType = .project
    var itemTypeList: [EventActionType] = [.task, .project]
    
    @State var totalTime: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
           
            ScrollView(.vertical) {
                VStack(spacing: 5, content: {
                    TimelineView()
                    if totalTime > 0 {
                        finishTotalView()
                    }
                    Spacer()
                })
            }
            .scrollIndicators(.hidden)
            
        }
        .vSpacing(.top)
        .alert("添加时间记录", isPresented: $showEditTimeItemAlert) {
            
                Picker("选择标签", selection: $selectedTag) {
                    ForEach(modelData.tagList.map({$0.title}), id: \.self) { title in
                        if let tag = modelData.tagList.first(where: { $0.title == title }) {
                            Text(tag.title).tag(tag)
                        }
                    }
                }
                
                Picker("选择类型", selection: $itemType) {
                    ForEach(itemTypeList, id: \.self) { type in
                        Text(type.title).tag(type)
                    }
                }
            
        } message: {
            Text("")
        }
        .onAppear {
            self.totalTime = timelineItems.compactMap { $0.interval.interval }.reduce(0, +)
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
                            print("select hour: \(hour)")
                            Self.selectedTimeInterval = hour
                            TimelineTaskView.selectedTimeItem = nil
#if os(macOS)
                            ToDoListView.newTimelineInterval = interverlTime()
                            modelData.weekSelectedTimelineItem = nil
                            self.selectItemID = ToDoListView.newTimelineItemId + UUID().uuidString
#endif
                    }
                }
            }
            .onAppear(perform: {
                proxy.scrollTo(midHour)
//                if showTask {
//                    self.addItemChangeObserver()
//                }
            })
            .overlay {
                if showTask {
                    TimelineBgView()
                }
            }
        })
    
    }
    
    func addItemChangeObserver() {
        NotificationCenter.default.addObserver(forName: NotificationName.addTimeInterval, object: nil, queue: .main) { notification in
            if let date = notification.userInfo?["date"] as? Date, let item = notification.userInfo?["item"] as? TimelineItem {
                if !date.isInSameDay(as: currentDate) {
                    return
                }
                var items = timelineItems
                if let index = items.firstIndex(where: { $0.interval.start > item.interval.start
                }) {
                    
                    items.insert(item, at: max(0, index-1))
                    print("add time item \(timelineItems.count) -> \(items.count)")
                    self.timelineItems = items
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NotificationName.deleteTimeInterval, object: nil, queue: .main) { notification in
            if let item = notification.userInfo?["item"] as? TaskTimeItem {
                let date = item.startTime
                if !date.isInSameDay(as: currentDate) {
                    return
                }
                var items = timelineItems
                if let index = items.firstIndex(where: {  $0.timeItem?.id == item.id
                }) {
                    items.remove(at: index)
                    print("delete time item \(timelineItems.count) -> \(items.count)")
                    self.timelineItems = items
                }
            }
         }
    }
    
    func finishTotalView() -> some View {
        HStack {
            Text("已投入：\(totalTime.simpleTimeStr)").bold().font(.system(size: 12))
            Spacer()
        }
        .padding(5)
        .background(Color.init(hex: "e8daef"))
        .cornerRadius(5)
        .offset(y: 10)
    }
    
    @ViewBuilder
    func TimelineBgView() -> some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
//                TimelinePlanView().frame(width: geometry.size.width / 2)
                TimelineExecuteView().frame(width: geometry.size.width)
            }
        }
    }
    
    @ViewBuilder
    func TimelinePlanView() -> some View {
       
        VStack(alignment: .leading, spacing: 0) {
            ForEach(timelinePlanItems.indices, id: \.self) { index in
                let item = timelinePlanItems[index]
                let tag = modelData.tagList.filter({ $0.id == item.event.tag}).first ?? .work
                if index == 0 {
                    let marginHeight = Date.timelineHeight(start: currentDate.startTimeOfDay, end: item.interval.start, isPlan: true)
                    if marginHeight > 1 {
                        Spacer().frame(height: marginHeight)
                    }
                } else {
                    let lastItem = timelinePlanItems[index-1]
                    let marginHeight = Date.timelineHeight(start: lastItem.interval.end, end: item.interval.start, isPlan: true)
                    if marginHeight > 0 {
                        Spacer().frame(height: marginHeight)
                    }
                }
                
                let start = Date.min(date1: item.interval.start, date2: currentDate.lastTimeOfDay)
                let end = Date.min(date1: item.interval.end, date2: currentDate.lastTimeOfDay)
                let height =  Date.timelineHeight(start: start, end: end, isPlan: true)
                
                TaskRow(item.event, item: item, interval: LQDateInterval(start: start, end: end), height: height)
                    .frame(height: height)
                .background {
                    ZStack(alignment: .leading) {
                    
//                        Rectangle()
//                            .fill(tag.titleColor)
//                            .frame(width: 4, height: height)
//                            .cornerRadius(5)
                        
                        Rectangle()
                            .fill(tag.titleColor.opacity(0.25))
                            .frame(height: height)
                            .cornerRadius(5)
                    }
                    //.padding(.trailing, 10)
                    .padding(.vertical, 5)
                    .cornerRadius(5)
                    .contentShape(Rectangle())
                }
            }
        }
        
        
    }
    
    
    @ViewBuilder
    func TimelineExecuteView() -> some View {
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
                    //.padding(.trailing, 10)
                    .padding(.vertical, 5)
                    .cornerRadius(5)
                    .contentShape(Rectangle())
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
                            .frame(width: 80, alignment: .leading)
                    } else {
                        Rectangle()
                            .stroke(.gray.opacity(0.5), style: StrokeStyle(lineWidth: 0.5, lineCap: .butt, lineJoin: .bevel, dash: [5], dashPhase: 5))
                            .frame(height: 0.5)
                    }
                })
                .        hSpacing(.leading)
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
        let isPlan = item?.timeItem?.isPlan ?? false
        return VStack(alignment: .leading, spacing:2, content: {
            
                if height <= 20 {
                    Text("")
                } else {
                    Text(task.title.prefix(15))
                        .font(.system(size: 10, weight: .regular))
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
            
        })
        .hSpacing(.leading)
        .padding(.leading, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            modelData.weekSelectedTimelineItem = item?.timeItem
            selectItemID = task.id
        }
    }
    
}

extension TimelineTaskView {
    
    func interverlTime() -> LQDateInterval {
        var startTime: Date = Self.selectedTimeInterval ?? .now
        if let lastItem = timelineItems.sorted(by: { $0.interval.end.timeIntervalSince1970 >= $1.interval.end.timeIntervalSince1970
        }).filter({ $0.interval.start <= startTime }).first {
            startTime = lastItem.interval.end
        }
        var endTime = startTime.dateByAddingMinutes(60)
        if let firstItem = timelineItems.sorted(by: { $0.interval.end.timeIntervalSince1970 >= $1.interval.end.timeIntervalSince1970
        }).filter({ $0.interval.end > startTime }).last {
            endTime = firstItem.interval.start
        }
        return LQDateInterval(start: startTime, end: endTime)
    }
    
}

//#Preview {
//    TimelineTaskView()
//}
