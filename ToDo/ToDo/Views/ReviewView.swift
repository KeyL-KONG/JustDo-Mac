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
    
    @State var selectTaskChange: ((BaseModel?) -> ())
    
    var body: some View {
        TabView {
            ReviewListView(timeTab: .day, selectTaskChange: selectTaskChange).environmentObject(modelData)
                .tabItem {
                    Label(TimeTab.day.title, image: "")
                }
                .tag(TimeTab.day)
            
            ReviewListView(timeTab: .week, selectTaskChange: selectTaskChange).environmentObject(modelData)
                .tabItem {
                    Label(TimeTab.week.title, image: "")
                }
                .tag(TimeTab.week)
            
            ReviewListView(timeTab: .month, selectTaskChange: selectTaskChange).environmentObject(modelData)
                .tabItem {
                    Label(TimeTab.month.title, image: "")
                }
                .tag(TimeTab.month)
            
            ReviewListView(timeTab: .all, selectTaskChange: selectTaskChange).environmentObject(modelData)
                .tabItem {
                    Label(TimeTab.all.title, image: "")
                }
                .tag(TimeTab.all)
        }
        .toolbar {
            Button {
                modelData.loadFromServer()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
        }
    }
}


struct ReviewListView: View {
    
    @State var timeTab: TimeTab
    @EnvironmentObject var modelData: ModelData
    @State var selectDate: Date = .now {
        didSet {
            print("select date: \(selectDate)")
            updateTitleText()
            updateSelectIndexes()
            resetSelectTask()
        }
    }
    
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    private let maxWeekIndex: Int = 2
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
    
    var summaryItemList: [SummaryItem] {
        modelData.summaryItemList.filter { item in
            guard let createTime = item.createTime else { return false }
            return dateInTimeTab(createTime, selectDate: selectDate, tab: timeTab)
        }
    }
    
    var summaryModel: SummaryModel? {
        modelData.summaryModelList.filter { model in
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
        }.sorted { $0.createTime?.timeIntervalSince1970 ?? 0 > $1.createTime?.timeIntervalSince1970 ?? 0
        }.first
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
    @State var summaryReviewEditMode: Bool = false
    @State var summaryMoodIndex: Int = 3
    @State var summaryMoodText: String = ""
    @State var summaryMoodEditMode: Bool = false
    @State var summaryBodyIndex: Int = 3
    @State var summaryBodyText: String = ""
    @State var summaryBodyEditMode: Bool = false
    @State var summaryEffectIndex: Int = 3
    @State var summaryEffectText: String = ""
    @State var summaryEffectEditMode: Bool = false
    
    private static var selectSummaryModel: SummaryModel? = nil
    @State var showingSummaryView: Bool = false
    
    @State private var isExpanded: Bool = true
    @State private var expandList: [Bool] = Array(repeating: true, count: 100)
    
    @State var selectTaskChange: ((BaseModel?) -> ())
    @State var selectTask: BaseModel? = nil
    
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
                            DisclosureGroup(isExpanded: $expandList[index]) {
                                if timeTab == .week {
                                    VStack(alignment: .leading, spacing: 5) {
                                        chartView(with: item)
                                        detailItemView(with: item)
                                    }
                                } else {
                                    detailItemView(with: item)
                                }
                            } label: {
                                HStack(content: {
                                    Text(item.tag.title).foregroundStyle(item.tag.titleColor)
                                    Spacer()
                                    Text(item.totalTime.simpleTimeStr).font(.system(size: 12)).foregroundStyle(.gray).bold()
                                    if let percentTime = EventDetailItem.percentTime(totalTime: item.totalTime, date: selectDate, timeTab: timeTab) {
                                        Text(percentTime).font(.system(size: 10)).foregroundStyle(item.tag.titleColor).bold()
                                    }
                                })
                            }
                        }
                    }
                }
                
                if summaryItemList.count > 0 {
                    Section {
                        ForEach(summaryItemList, id: \.self.id) { item in
                            let selected = selectTask?.id ?? "" == item.id
                            Text(item.content).foregroundStyle(.gray)
                                .id(UUID())
                                .contentShape(Rectangle())
                                .background(selected ? .gray.opacity(0.5) : .clear)
                                .onTapGesture {
                                    self.selectTask = item
                                    self.selectTaskChange(item)
                                }
                        }
                    } header: {
                        Text("感想")
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
                    
                    if !summaryReviewEditMode {
                        MarkdownWebView(summaryReviewText, customStylesheet: stylesheet)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Self.checkType = .review
                                Self.selectSummaryModel = summaryModel
                                self.showingSummaryView.toggle()
                            }
                    } else {
                        TextEditor(text: $summaryReviewText)
                            .font(.system(size: 14))
                            .frame(minHeight: 50)
                            .border(.blue, width: 1)
                    }
                    
                } header: {
                    HStack {
                        Text("整体情况")
                        RatingView(maxRating: 5, rating: $summaryReviewIndex, size: 15, spacing: 2.5, onChange: { index in
                            self.summaryReviewIndex = index
                            self.saveSummaryModel()
                        }).previewLayout(.sizeThatFits)
                        Spacer()
                        let title = summaryReviewEditMode ? "预览" : "编辑"
                        Button(title) {
                            self.summaryReviewEditMode = !self.summaryReviewEditMode
                            if !self.summaryReviewEditMode {
                                self.saveSummaryModel()
                            }
                        }.font(.system(size: 14))
                    }
                }
                
                Section {
                    
                    if !summaryEffectEditMode {
                        MarkdownWebView(summaryEffectText, customStylesheet: stylesheet)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Self.checkType = .effect
                                Self.selectSummaryModel = summaryModel
                                self.showingSummaryView.toggle()
                            }
                    } else {
                        TextEditor(text: $summaryEffectText)
                            .font(.system(size: 14))
                            .frame(minHeight: 50)
                            .border(.blue, width: 1)
                    }
                    
                } header: {
                    HStack {
                        Text("效率指数")
                        
                        RatingView(maxRating: 5, rating: $summaryEffectIndex, size: 15, spacing: 2.5, onChange: { index in
                            self.summaryEffectIndex = index
                            self.saveSummaryModel()
                        }).previewLayout(.sizeThatFits)
                        
                        Spacer()
                        let title = summaryEffectEditMode ? "预览" : "编辑"
                        Button(title) {
                            self.summaryEffectEditMode = !self.summaryEffectEditMode
                            if !self.summaryEffectEditMode {
                                self.saveSummaryModel()
                            }
                        }.font(.system(size: 14))
                    }
                }
                
                Section {
                    
                    if !summaryMoodEditMode {
                        MarkdownWebView(summaryMoodText, customStylesheet: stylesheet)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Self.checkType = .mood
                                Self.selectSummaryModel = summaryModel
                                self.showingSummaryView.toggle()
                            }
                    } else {
                        TextEditor(text: $summaryMoodText)
                            .font(.system(size: 14))
                            .frame(minHeight: 50)
                            .border(.blue, width: 1)
                    }
                    
                } header: {
                    HStack {
                        Text("心情指数")
                        RatingView(maxRating: 5, rating: $summaryMoodIndex, size: 15, spacing: 2.5, onChange: { index in
                            self.summaryMoodIndex = index
                            self.saveSummaryModel()
                        }).previewLayout(.sizeThatFits)
                        Spacer()
                        let title = summaryMoodEditMode ? "预览" : "编辑"
                        Button(title) {
                            self.summaryMoodEditMode = !self.summaryMoodEditMode
                            if !self.summaryMoodEditMode {
                                self.saveSummaryModel()
                            }
                        }.font(.system(size: 14))
                    }
                }
                
                
                
                Section {
                    
                    if !summaryBodyEditMode {
                        MarkdownWebView(summaryBodyText, customStylesheet: stylesheet)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Self.checkType = .body
                                Self.selectSummaryModel = summaryModel
                                self.showingSummaryView.toggle()
                            }
                    } else {
                        TextEditor(text: $summaryBodyText)
                            .font(.system(size: 14))
                            .frame(minHeight: 50)
                            .border(.blue, width: 1)
                    }
                    
                } header: {
                    HStack {
                        Text("身体指数")
                        RatingView(maxRating: 5, rating: $summaryBodyIndex, size: 15, spacing: 2.5, onChange: { index in
                            self.summaryBodyIndex = index
                            self.saveSummaryModel()
                        }).previewLayout(.sizeThatFits)
                        Spacer()
                        let title = summaryBodyEditMode ? "预览" : "编辑"
                        Button(title) {
                            self.summaryBodyEditMode = !self.summaryBodyEditMode
                            if !self.summaryBodyEditMode {
                                self.saveSummaryModel()
                            }
                        }.font(.system(size: 14))
                    }
                }
            }
        }
//        .onChange(of: timeTab, { oldValue, newValue in
//            if oldValue != newValue {
//                updateTitleText()
//                updateSelectIndexes()
//            }
//        })
//        .onChange(of: selectDate, { oldValue, newValue in
//            if oldValue != newValue {
//                updateTitleText()
//                updateSelectIndexes()
//            }
//        })
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
            resetSelectTask()
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
                    Image(systemName: "chevron.left").foregroundColor(.blue).font(.system(size: 20)).bold()
                }
                    .buttonStyle(BorderlessButtonStyle())
                
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
                    Image(systemName: "chevron.right").foregroundColor((disableRightButton ? .gray : .blue)).font(.system(size: 20)).bold()
                }.disabled(disableRightButton)
                    .buttonStyle(BorderlessButtonStyle())
                
            }
        }.padding(.horizontal, 15)
            .padding(.top, 5)
    }
    
    func updateSelectIndexes() {
        if let summaryModel {
            self.summaryReviewIndex = summaryModel.reviewType.rawValue
            self.summaryMoodIndex = summaryModel.moodType.rawValue
            self.summaryBodyIndex = summaryModel.bodyType.rawValue
            self.summaryEffectIndex = summaryModel.effectType.rawValue
            
            self.summaryReviewText = summaryModel.reviewText
            self.summaryMoodText = summaryModel.moodeText
            self.summaryBodyText = summaryModel.bodyText
            self.summaryEffectText = summaryModel.effectText
        } else {
            self.summaryReviewIndex = 3
            self.summaryMoodIndex = 3
            self.summaryBodyIndex = 3
            self.summaryEffectIndex = 3
            
            self.summaryReviewText = ""
            self.summaryMoodText = ""
            self.summaryBodyText = ""
            self.summaryEffectText = ""
            let summaryModel = SummaryModel()
            summaryModel.summaryDate = selectDate
            summaryModel.timeTab = timeTab
            modelData.updateSummaryModel(summaryModel)
        }
    }
    
    func resetSelectTask() {
        selectTask = nil
        selectTaskChange(nil)
    }
    
    func saveSummaryModel() {
        guard let summaryModel else { return }
        summaryModel.reviewType = SummaryReviewType(rawValue: self.summaryReviewIndex) ?? .normal
        summaryModel.reviewText = summaryReviewText
        
        summaryModel.moodType = SummaryMoodType(rawValue: self.summaryMoodIndex) ?? .normal
        summaryModel.moodeText = summaryMoodText
        
        summaryModel.bodyType = SummaryBodyType(rawValue: self.summaryBodyIndex) ?? .normal
        summaryModel.bodyText = summaryBodyText
        
        summaryModel.effectType = SummaryEffectType(rawValue: self.summaryEffectIndex) ?? .normal
        summaryModel.effectText = summaryEffectText
        modelData.updateSummaryModel(summaryModel)
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
            let selected = selectTask?.id ?? "" == detailItem.id
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
                    if let taskId = detailItem.items.first?.id, let event = modelData.itemList.first(where: { $0.id == taskId
                    }) {
                        self.selectTask = event
                        self.selectTaskChange(event)
                    }
                }
                .id(UUID())
                .background(selected ? .gray.opacity(0.5) : .clear)
            
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
