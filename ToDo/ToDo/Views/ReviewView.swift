//
//  ReviewView.swift
//  ToDo
//
//  Created by LQ on 2024/12/31.
//

import SwiftUI

struct EventTaskItem {
    var id: String
    var title: String
    var type: TaskType
    var finish: Bool
    var mark: String
    var time: Int
    var intervals: [LQDateInterval]
    
    init(id: String, title: String, type: TaskType, finish: Bool, mark: String, time: Int, intervals: [LQDateInterval]) {
        self.id = id
        self.title = title
        self.type = type
        self.finish = finish
        self.mark = mark
        self.time = time
        self.intervals = intervals
    }
}

struct EventDetailItem: Identifiable {
    let tag: ItemTag
    let title: String
    var items: [EventTaskItem]
    var detailItems: [EventDetailItem]? = nil
    
    var id: String {
        if detailItems != nil {
            return tag.id
        } else {
            return items.first?.id ?? title
        }
    }
    
    var totalTime: Int {
        if let detailItems {
            return detailItems.compactMap { $0.items }.reduce([], +).compactMap { $0.time }.reduce(0, +)
        }
        return items.compactMap { $0.time }.reduce(0, +)
    }
    
    var intervals: [LQDateInterval] {
        if let detailItems {
            return detailItems.compactMap { $0.intervals }.reduce([], +)
        }
        return items.compactMap { $0.intervals }.reduce([], +)
    }
    
    static func percentTime(totalTime: Int, date: Date, timeTab: TimeTab) -> String? {
        if totalTime <= 0 { return nil }
        let allTime: Int?
        switch timeTab {
        case .day:
            allTime = 24 * 60 * 60
        case .week:
            allTime = 24 * 60 * 60 * 7
        case .month:
            allTime = 24 * 60 * 60 * date.totalDaysThisMonth
        case .all:
            return nil
        }
        guard let allTime else { return nil }
        return "\(Int(Float(totalTime) / Float(allTime) * 100))%"
    }
}

struct ReviewView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    var tabs: [TimeTab] = [.day, .week, .month, .all]
    
    var body: some View {
        TabView {
            ReviewListView(timeTab: .day).environmentObject(modelData)
                .tabItem {
                    Label(TimeTab.day.title, image: "")
                }
                .tag(TimeTab.day)
            
            ReviewListView(timeTab: .week).environmentObject(modelData)
                .tabItem {
                    Label(TimeTab.week.title, image: "")
                }
                .tag(TimeTab.week)
            
            ReviewListView(timeTab: .month).environmentObject(modelData)
                .tabItem {
                    Label(TimeTab.month.title, image: "")
                }
                .tag(TimeTab.month)
            
            ReviewListView(timeTab: .all).environmentObject(modelData)
                .tabItem {
                    Label(TimeTab.all.title, image: "")
                }
                .tag(TimeTab.all)
        }
    }
}


struct ReviewListView: View {
    
    @State var timeTab: TimeTab
    @EnvironmentObject var modelData: ModelData
    @State var selectDate: Date = .now
    
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @Namespace private var animation
    
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
            return result || (event.actionType == .task && dateInTimeTab(planTime, selectDate: selectDate, tab: timeTab))
        }
    }
    
    var eventDetailList: [EventDetailItem] {
        var items = [EventDetailItem]()
        let tagList = modelData.tagList
        
        func appendTaskItem(tag: ItemTag, item: EventTaskItem) {
            if let updateIndex = items.firstIndex(where: { $0.tag.id == tag.id }) {
                var detailItem = items[updateIndex]
                detailItem.items.append(item)
                detailItem.items = detailItem.items.sorted(by: { $0.time > $1.time })
                let subItem = EventDetailItem(tag: tag, title: item.title, items: [item])
                if var subItems = detailItem.detailItems {
                    subItems.append(subItem)
                    detailItem.detailItems = subItems.sorted(by: { $0.totalTime > $1.totalTime })
                } else {
                    detailItem.detailItems = [subItem]
                }
                items[updateIndex] = detailItem
            } else {
                let subItem = EventDetailItem(tag: tag, title: item.title, items: [item])
                let detailItem = EventDetailItem(tag: tag, title: tag.title, items: [item], detailItems: [subItem])
                items.append(detailItem)
            }
        }
        
        for event in eventListItem {
            guard let tag = tagList.first(where: { $0.id == event.tag
            }) else { continue }
            
            let taskEvent = EventTaskItem(id: event.id, title: event.title, type: .task, finish: event.isFinish, mark: event.mark, time: event.totalTime(with: timeTab, selectDate: selectDate), intervals: event.intervals(with: timeTab, selectDate: selectDate))
            appendTaskItem(tag: tag, item: taskEvent)
        }
        
        let rewardList = modelData.rewardList
        for reward in rewardList {
            guard let tag = tagList.first(where: { $0.id == reward.tag }) else { continue }
            let totalTime = reward.totalTime(with: timeTab, intervals: reward.intervals, selectDate: selectDate)
            guard totalTime > 0 else { continue }
            let rewardEvent = EventTaskItem(id: reward.id, title: reward.title, type: .reward, finish: false, mark: reward.mark, time: totalTime, intervals: reward.intervals(with: timeTab, selectDate: selectDate))
            appendTaskItem(tag: tag, item: rewardEvent)
        }
        
        return items.sorted { $0.totalTime > $1.totalTime }
    }
    
    var noteListItem: [NoteModel] {
        modelData.noteList.filter { note in
            guard let createTime = note.createTime else {
                return false
            }
            return dateInTimeTab(createTime, selectDate: selectDate, tab: timeTab)
        }
    }
    
    var readListItem: [ReadModel] {
        modelData.readList.filter { read in
            guard let createTime = read.createTime else {
                return false
            }
            return dateInTimeTab(createTime, selectDate: selectDate, tab: timeTab)
        }
    }
    
    var summaryModel: SummaryModel? {
        modelData.summaryModelList.first { model in
            guard model.timeTab == timeTab else {
                return false
            }
            switch timeTab {
            case .day:
                return model.summaryDate.isInSameDay(as: selectDate)
            case .week:
                return model.summaryDate.isInSameWeek(as: selectDate)
            case .month:
                return model.summaryDate.isInSameMonth(as: selectDate)
            case .all:
                return model.summaryDate.isInSameYear(as: selectDate)
            }
        }
    }
    
    var highEventListItem: [EventItem] {
        eventListItem.filter { $0.importance == .high }
    }
    private static var checkType: SummaryCheckType = .review
    private let stylesheet: String? = try? .init(contentsOf: Bundle.main.url(forResource: "markdown", withExtension: "css")!)
    
    @State var titleText: String = "当日事项"
    
    @State var summaryContent: String = ""
    @State var summaryReviewIndex: Int = 3
    @State var summaryReviewText: String = ""
    @State var summaryMoodIndex: Int = 3
    @State var summaryMoodText: String = ""
    @State var summaryBodyIndex: Int = 3
    @State var summaryBodyText: String = ""
    @State var summaryEffectIndex: Int = 3
    @State var summaryEffectText: String = ""
    
    private static var selectSummaryModel: SummaryModel? = nil
    @State var showingSummaryView: Bool = false
    
    var body: some View {
        VStack {
            if timeTab == .day {
                DayHeaderView()
            } else if timeTab == .week || timeTab == .month {
                HeaderView()
            }
            List {
                if highEventListItem.count > 0 {
                    Section(header: Text("高优先级")) {
                        ForEach(highEventListItem) { item in
                            HStack(content: {
                                Image(systemName: "\(item.isFinish ? "circle.circle.fill" : "circle.circle")").foregroundStyle(.blue)
                                Text(item.title)
                                let totalTime = item.totalTime(with: timeTab, selectDate: selectDate)
                                if totalTime > 0 {
                                    Spacer()
                                    Text(totalTime.simpleTimeStr).font(.system(size: 12)).foregroundStyle(.gray).bold()
                                }
                            }).contentShape(Rectangle())
                                .onTapGesture {
                                    self.openEvent(id: item.id)
                                }
                        }
                    }
                }
                
                if eventDetailList.count > 0 {
                    Section(header: HStack(content: {
                        Text("事项")
                        Spacer()
                        let totalTime = eventDetailList.compactMap { $0.totalTime }.reduce(0, +)
                        if let percentTime = EventDetailItem.percentTime(totalTime: totalTime, date: selectDate, timeTab: timeTab) {
                            Text(percentTime).bold()
                        }
                    })) {
                        ForEach(Array(eventDetailList.enumerated()), id: \.1.id) { index, item in
                            DisclosureGroup(
                                content: {
                                    
                                    if timeTab == .week {
                                        VStack(alignment: .leading, spacing: 5) {
                                            chartView(with: item)
                                            detailItemView(with: item)
                                        }
                                    } else {
                                        detailItemView(with: item)
                                    }
                                    
                                },
                                label: {
                                    HStack(content: {
                                        Text(item.tag.title).foregroundStyle(item.tag.titleColor)
                                        Spacer()
                                        Text(item.totalTime.simpleTimeStr).font(.system(size: 12)).foregroundStyle(.gray).bold()
                                        if let percentTime = EventDetailItem.percentTime(totalTime: item.totalTime, date: selectDate, timeTab: timeTab) {
                                            Text(percentTime).font(.system(size: 10)).foregroundStyle(item.tag.titleColor).bold()
                                        }
                                    })
                                }
                            )
                        }
                    }
                }
                
                if noteListItem.count > 0 {
                    Section(header: Text("笔记")) {
                        ForEach(noteListItem) { item in
                            Text(item.title).foregroundColor(.accentColor)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    let openUrl = "note://\(item.id)"
                                    guard let openURL = URL(string: openUrl) else {
                                        return
                                    }
#if os(iOS)
                                    UIApplication.shared.open(openURL) { success in
                                        print("open read: \(success)")
                                    }
                                    #endif
                                }
                        }
                    }
                }
                
                if readListItem.count > 0 {
                    Section(header: Text("阅读")) {
                        ForEach(readListItem) { item in
                            Text((item.title.count > 0 ? item.title : "无标题")).font(.system(size: 12)).foregroundColor(.accentColor)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    let openUrl = "readlist://\(item.id)"
                                    guard let openURL = URL(string: openUrl) else {
                                        return
                                    }
#if os(iOS)
                                    UIApplication.shared.open(openURL) { success in
                                        print("open read: \(success)")
                                    }
                                    #endif
                                }
                        }
                    }
                }
                
                Section {
                    
                    if let reviewText = summaryModel?.reviewText, reviewText.count > 0 {
                        MarkdownWebView(reviewText, customStylesheet: stylesheet)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Self.checkType = .review
                                Self.selectSummaryModel = summaryModel
                                self.showingSummaryView.toggle()
                            }
                    }
                    
                } header: {
                    HStack {
                        Text("整体情况")
                        RatingView(maxRating: 5, rating: $summaryReviewIndex, size: 15, spacing: 2.5, onChange: { index in
                            self.summaryReviewIndex = index
                        }).previewLayout(.sizeThatFits)
                        Spacer()
                        Button("编辑") {
                            Self.checkType = .review
                            Self.selectSummaryModel = summaryModel
                            self.showingSummaryView.toggle()
                        }.font(.system(size: 14))
                    }
                }
                
                Section {
                    
                    if let effectText = summaryModel?.effectText, effectText.count > 0 {
                        MarkdownWebView(effectText, customStylesheet: stylesheet)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Self.checkType = .effect
                                Self.selectSummaryModel = summaryModel
                                self.showingSummaryView.toggle()
                            }
                    }
                    
                } header: {
                    HStack {
                        Text("效率指数")
                        
                        RatingView(maxRating: 5, rating: $summaryEffectIndex, size: 15, spacing: 2.5, onChange: { index in
                            self.summaryEffectIndex = index
                        }).previewLayout(.sizeThatFits)
                        
                        Spacer()
                        Button("编辑") {
                            Self.checkType = .effect
                            Self.selectSummaryModel = summaryModel
                            self.showingSummaryView.toggle()
                        }.font(.system(size: 14))
                    }
                }
                
                Section {
                    
                    if let moodeText = summaryModel?.moodeText, moodeText.count > 0 {
                        MarkdownWebView(moodeText, customStylesheet: stylesheet)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Self.checkType = .mood
                                Self.selectSummaryModel = summaryModel
                                self.showingSummaryView.toggle()
                            }
                    }
                    
                } header: {
                    HStack {
                        Text("心情指数")
                        RatingView(maxRating: 5, rating: $summaryMoodIndex, size: 15, spacing: 2.5, onChange: { index in
                            self.summaryMoodIndex = index
                        }).previewLayout(.sizeThatFits)
                        Spacer()
                        Button("编辑") {
                            Self.checkType = .mood
                            Self.selectSummaryModel = summaryModel
                            self.showingSummaryView.toggle()
                        }.font(.system(size: 14))
                    }
                }
                
                
                
                Section {
                    
                    if let bodyText = summaryModel?.bodyText, bodyText.count > 0 {
                        MarkdownWebView(bodyText, customStylesheet: stylesheet)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Self.checkType = .body
                                Self.selectSummaryModel = summaryModel
                                self.showingSummaryView.toggle()
                            }
                    }
                    
                } header: {
                    HStack {
                        Text("身体指数")
                        RatingView(maxRating: 5, rating: $summaryBodyIndex, size: 15, spacing: 2.5, onChange: { index in
                            self.summaryBodyIndex = index
                        }).previewLayout(.sizeThatFits)
                        Spacer()
                        Button("编辑") {
                            Self.checkType = .body
                            Self.selectSummaryModel = summaryModel
                            self.showingSummaryView.toggle()
                        }.font(.system(size: 14))
                    }
                }
            }
        }
        .onChange(of: timeTab, { oldValue, newValue in
            if oldValue != newValue {
                updateTitleText()
            }
        })
        .onChange(of: selectDate, { oldValue, newValue in
            if oldValue != newValue {
                updateTitleText()
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
            summaryContent = summaryModel?.content ?? ""
            updateTitleText()
        }
    }
}


extension ReviewListView {
    
    @ViewBuilder
    func HeaderView() -> some View {
        HStack(alignment: .center) {
            let font = Font.system(size: 20)
            if timeTab == .day || timeTab == .all {
                Text(titleText).font(font).foregroundColor(.accentColor)
            } else {
                Button {
                    updateSelectDate(next: false)
                } label: {
                    Label("", systemImage: "arrow.left").font(font).foregroundColor(.blue)
                }
                
                Spacer()

                Text(titleText).font(font).foregroundStyle(.blue)
                
                if timeTab == .week {
                    Text("\(Int(selectDate.percentOfWeek))%").font(.system(size: 12)).foregroundStyle(.gray).offset(y: 2)
                } else if timeTab == .month {
                    Text("\(Int(selectDate.percentOfMonth))%").font(.system(size: 12)).foregroundStyle(.gray).offset(y: 2)
                }
                
                Spacer()
                
                let disableRightButton =
                (timeTab == .week && selectDate.isInThisWeek) ||
                (timeTab == .month && selectDate.isInThisMonth)
                
                Button {
                    updateSelectDate(next: true)
                } label: {
                    Label("", systemImage: "arrow.right").font(font).foregroundColor((disableRightButton ? .gray : .blue))
                }.disabled(disableRightButton)
                    .opacity((disableRightButton ? 0.5 : 1.0))
            }
        }.padding(.horizontal, 15)
            .padding(.top, 5)
    }
    
    func updateSelectDate(next: Bool) {
        var date = selectDate
        switch self.timeTab {
        case .week:
            date = next ? date.nextWeekDate : date.previousWeekDate
        case .month:
            date = next ? date.nextMonth : date.previousMonth
        default:
            break
        }
        self.selectDate = date
    }
    
    func updateTitleText() {
        var text = ""
        switch self.timeTab {
        case .day:
            text = "当日事项"
        case .week:
            text = selectDate.simpleWeek
        case .month:
            text = selectDate.simpleMonthAndYear
        case .all:
            text = "所有事项"
        }
        self.titleText = text
    }
    
    func chartView(with item: EventDetailItem) -> some View {
        var totalTimes: [Int] = []
        var maxTotalTime = 0
        let intervals = item.intervals
        selectDate.fetchWeek().compactMap { $0.date }.forEach { date in
            let totalTime = intervals.filter { $0.end.isInSameDay(as: date) }.compactMap { $0.interval }.reduce(0, +)
            totalTimes.append(totalTime)
            maxTotalTime = max(totalTime, maxTotalTime)
        }
        let percents = totalTimes.compactMap { CGFloat($0) / CGFloat(maxTotalTime) }
        let desc = totalTimes.compactMap { $0.simpleTimeStr }
        return BarChartView(data: percents, barColor: item.tag.titleColor, desc: desc)
    }
    
    func detailItemView(with item: EventDetailItem) -> some View {
        let detailItems = item.detailItems?.sorted(by: { $0.totalTime > $1.totalTime })
        return ForEach(detailItems ?? []) { detailItem in
            HStack {
                if let subItem = detailItem.items.first {
                    if subItem.type == .task {
                        Image(systemName: "\(subItem.finish ? "circle.circle.fill" : "circle.circle")").font(.system(size: 12)).foregroundStyle(.blue)
                    }
                }
                
                Text(detailItem.title).font(.system(size: 12)).foregroundStyle(.gray)
                Spacer()
                
                if let subItem = detailItem.items.first, subItem.time > 0 {
                    Text(subItem.time.simpleTimeStr).font(.system(size: 12)).foregroundStyle(.gray)
                }
            }.contentShape(Rectangle())
                .onTapGesture {
                    self.openEvent(id: detailItem.id)
                }
                .id(UUID())
            
        }
    }
    
    func dateInTimeTab(_ date: Date, selectDate: Date, tab: TimeTab) -> Bool {
        switch tab {
        case .day:
            return Date.isSameDay(date1: date, date2: selectDate)
        case .week:
            return Date.isSameWeek(date1: date, date2: selectDate)
        case .month:
            return Date.isSameMonth(date1: date, date2: selectDate)
        case .all:
            return true
        }
    }
    
    func openEvent(id: String) {
        let url = "justdo://\(id)"
        guard let openURL = URL(string: url) else {
            return
        }
#if os(iOS)
        UIApplication.shared.open(openURL) { success in
            print("open justdo: \(success)")
        }
        #endif
    }
    
    @ViewBuilder
    func DayHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            
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
#if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
            .frame(height: 90)
        }
        .hSpacing(.leading)
        .padding(5)
        .background(.white)
    }
    
    @ViewBuilder
    func WeekView(_ weeks: [Date.WeekDay]) -> some View {
        HStack(spacing: 0, content: {
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

struct BarChartView: View {
    let data: [CGFloat] // 这里存储每个柱子的高度
    let barColor: Color // 柱子的颜色
    let desc: [String] // 数值
    let spacing: CGFloat = 10 // 柱子之间的间距
    let totalHeight: CGFloat = 30

    var body: some View {
        HStack(alignment: .bottom, spacing: spacing) {
            ForEach(0..<data.count, id: \.self) { index in
                VStack {
                    let height = max(data[index] * totalHeight, 1)
                    Rectangle()
                        .frame(width: 20, height: height)
                        .foregroundStyle((height <= 1 ? .gray : barColor))
                        .cornerRadius(4)
                    Text(desc[index]).font(.system(size: 10)).foregroundColor(barColor)
                }
                
            }
        }
    }
}

struct BarContentView: View {
    let data: [CGFloat] = [0.4, 0.2, 0.5, 0.1, 0.8] // 示例数据
    let barColor = Color.blue // 柱子颜色
    let spacing: CGFloat = 10 // 柱子间距

    var body: some View {
        BarChartView(data: data, barColor: barColor, desc: [""])
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}