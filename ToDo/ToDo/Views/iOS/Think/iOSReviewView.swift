//
//  iOSReviewView.swift
//  Summary
//
//  Created by LQ on 2024/5/3.
//

import SwiftUI

struct iOSReviewView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State var timeTab: TimeTab = .all
    @State var selectDate: Date = .now
    @State var showingSummaryView: Bool = false
    @State var showingEditTagView: Bool = false
    
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @Namespace private var animation
    
    @State var titleText: String = "当日事项"
    
    private static var selectTask: (any BasicTaskProtocol)?
    private static var selectSummaryItem: SummaryItem?
    private static var deleteSummaryItem: SummaryItem?
    @State var showingDeleteAlert: Bool = false
    
    @State var toggleRefresh: Bool = false
    var tabs: [TimeTab] = [.day, .week, .month, .all]
#if os(iOS)
    @State var offsetObserver = PageOffsetObserver()
    #endif
    
    @State var summaryText = "" {
        didSet {
            print("summary text: \(summaryText)")
        }
    }
    @State var inputHeight: CGFloat = 0.0
    @State var showTagList: Bool = false
    @State var filterTag: String = "所有"
    var filterTags: [String] {
        var tags = modelData.summaryTagList.compactMap { $0.content }
        tags.insert("所有", at: 0)
        return tags
    }
    
    var eventList: [EventItem] {
        let eventList = modelData.itemList.filter { event in
//            guard let planTime = event.planTime else { return false}
//            guard self.dateInTimeTab(planTime, selectDate: selectDate, tab: timeTab) else { return false }
            return  modelData.summaryModelList.filter({ summary in
                guard let updateTime = summary.updateAt else { return false }
                guard self.dateInTimeTab(updateTime, selectDate: selectDate, tab: timeTab) else { return false }
                return summary.taskId == event.id
            }).count > 0
        }.sorted { first, second in
            if first.isFinish && !second.isFinish {
                return true
            } else if !first.isFinish && second.isFinish {
                return false
            }
            return first.importance > second.importance
        }
        return eventList
    }
    
    var rewardList: [RewardModel] {
        let rewardList = modelData.rewardList.filter { reward in
            return  modelData.summaryModelList.filter({ summary in
                guard let updateTime = summary.updateAt else { return false }
                guard self.dateInTimeTab(updateTime, selectDate: selectDate, tab: timeTab) else { return false }
                return summary.taskId == reward.id
            }).count > 0
        }
        return rewardList
    }
    
    var summaryItemList: [SummaryItem] {
        modelData.summaryItemList.filter { item in
            if item.isSummary { return false }
            guard let updateTime = item.updateAt else { return false }
            if let tagId = modelData.summaryTagList.first(where: { $0.content == filterTag })?.id {
                if !item.tags.contains(where: { $0 == tagId}) {
                    return false
                }
            }
            return self.dateInTimeTab(updateTime, selectDate: selectDate, tab: timeTab)
        }.sorted {
            $0.updateAt?.timeIntervalSince1970 ?? 0 > $1.updateAt?.timeIntervalSince1970 ?? 0
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
//                HStack(alignment: .top) {
//                    Text("复盘").font(.title.bold()).foregroundStyle(.blue)
//                    Spacer()
//                    Menu {
//                        Button("标签列表") {
//                            showTagList.toggle()
//                        }
//                        Picker("过滤标签", selection: $filterTag) {
//                            ForEach(filterTags, id: \.self) { tag in
//                                let times = tag == "所有" ? summaryItemList.count :  self.countSummayTag(tag)
//                                Text("\(tag)(\(times))").tag(tag)
//                            }
//                        }
//                    } label: {
//                        Label("", systemImage: "ellipsis.circle").foregroundStyle(.blue).font(.title2)
//                    }
//                }.padding(.leading, 15)
                
                if toggleRefresh {
                    Text("")
                }
                
                ListView().tag(TimeTab.all)
                
            }
        }
#if os(iOS)
        .onChange(of: timeTab) { oldValue, newValue in
            if oldValue != newValue {
                updateTitleText()
            }
        }
        .onChange(of: selectDate) { oldValue, newValue in
            if oldValue != newValue {
                updateTitleText()
            }
        }
        #endif
        .sheet(isPresented: $showTagList, content: {
            SummaryTagListView(showEditTagView: $showingEditTagView).environmentObject(modelData)
        })
//        .fullScreenCover(isPresented: $showTagList, content: {
//            SummaryTagListView().environmentObject(modelData)
//        })
        .sheet(isPresented: $showingSummaryView, content: {
            EditSummaryView(showSheetView: $showingSummaryView, showEditTagView: $showingEditTagView, summaryItem: Self.selectSummaryItem, task: Self.selectTask).environmentObject(modelData)
                    .presentationDetents([.height(400)])
                    .sheet(isPresented: $showingEditTagView, content: {
                        EditTagView(showSheetView: $showingEditTagView).environmentObject(modelData)
                            .presentationDetents([.height(150)])
                    })
                    
        })
        .alert(isPresented: $showingDeleteAlert, content: {
            Alert(title: Text("是否删除该内容"), primaryButton: .destructive(Text("取消")), secondaryButton: .default(Text("确定"), action: {
                if let deleteItem = Self.deleteSummaryItem {
                    modelData.deleteSummaryItem(deleteItem)
                    Self.deleteSummaryItem = nil
                }
            }))
        })
        .overlay(alignment: .bottomTrailing, content: {
//            Button(action: {
//                Self.selectTask = nil
//                Self.selectSummaryItem = nil
//                showingSummaryView.toggle()
//            }, label: {
//                Image(systemName: "plus")
//                    .fontWeight(.semibold)
//                    .foregroundStyle(.white)
//                    .frame(width: 55, height: 55)
//                    .background(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
//            })
//            .padding(.vertical, 20)
//            .padding(.horizontal, 40)
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

extension iOSReviewView {
    
    @ViewBuilder
    func TabbarView() -> some View {
        Tabbar(.gray)
            .overlay(content: {
#if os(iOS)
                if let collectionViewBounds = offsetObserver.collectionView?.bounds {
                    GeometryReader(content: { geometry in
                        let width = geometry.size.width
                        let tabCount = CGFloat(tabs.count)
                        let capsuleWidth = width / tabCount
                        let progress = offsetObserver.offset / collectionViewBounds.size.width
                        
                        Capsule()
                            .fill(.black)
                            .frame(width: capsuleWidth)
                            .offset(x: progress * capsuleWidth)
                        
                        Tabbar(.white, .semibold)
                            .mask(alignment: .leading) {
                                Capsule()
                                    .frame(width: capsuleWidth)
                                    .offset(x: progress * capsuleWidth)
                            }
                    })
                }
                #endif
            })
            .background(.ultraThinMaterial)
            .clipShape(.capsule)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
            .shadow(color: .black.opacity(0.05), radius: 5, x: -5, y: -5)
            .padding([.horizontal, .top], 10)
    }
    
    @ViewBuilder
    func ListView() -> some View {
        VStack {
            if timeTab == .day {
                DayHeaderView()
            }
            
            if timeTab == .week || timeTab == .month {
                HeaderView()
            }
            
            List {
                ReviewSectionView()
            }
#if os(iOS)
            .listRowSpacing((timeTab == .day) ? 15  : 0)
                .listSectionSpacing(15)
            #endif
                .refreshable {
                    modelData.loadSummaryList {
                        
                    }
                }
            
            HStack(spacing: 8, content: {
#if os(iOS)
                ResizableTF(txt: $summaryText, height: $inputHeight).frame(height: self.inputHeight < 150 ? self.inputHeight : 150)
                    .padding(.horizontal)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                #endif
                
                Button(action: {
                    saveSummaryText()
                    endEdit()
                }, label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(10)
                })
            })
            .padding(.horizontal)
            .padding(.vertical)
        }
        .onTapGesture {
            endEdit()
        }
        .onAppear {
#if os(iOS)
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { data in
                
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { data in
                
            }
            #endif
        }
    }
    
    @ViewBuilder
    func Tabbar(_ tint: Color, _ weight: Font.Weight = .regular) -> some View {
        HStack(spacing: 0, content: {
            ForEach(tabs, id: \.self) { tab in
                Text(tab.title)
                    .foregroundStyle(tint)
                    .font(.system(size: 15))
                    .fontWeight(weight)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                            timeTab = tab
                        }
                    }
            }
        })
    }
    
}

extension iOSReviewView {
    
    func countSummayTag(_ tag: String) -> Int {
        guard let tagModel = modelData.summaryTagList.first(where: { $0.content == tag
        }) else {
            return 0
        }
        return modelData.summaryItemList.filter { item in
            item.tags.contains { $0 == tagModel.id }
        }.count
    }
    
    func beginEdit() {
        //UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
        //toggleRefresh.toggle()
    }
    
    func endEdit() {
#if os(iOS)
        UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
        #endif
    }
    
    func saveSummaryText() {
        guard summaryText.count > 0 else {
            return
        }
        let summaryItem = SummaryItem()
        summaryItem.generateId = UUID().uuidString
        summaryItem.content = summaryText
        modelData.updateSummaryItem(summaryItem)
        summaryText = ""
    }
    
}

extension iOSReviewView {
    
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
    
}

extension iOSReviewView {
    
    @ViewBuilder
    func ReviewSectionView() -> some View {
        ForEach(summaryItemList, id: \.self) { item in
            Section {
                Text(item.content).font(.system(size: 16)).foregroundColor(.black).multilineTextAlignment(.leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Self.selectSummaryItem = item
                        self.showingSummaryView.toggle()
                    }
                    .swipeActions {
                        Button {
                            let noteItem = NoteItem()
                            noteItem.content = item.content
                            noteItem.createTime = item.createTime
                            modelData.updateNoteItem(noteItem) { success in
                                if success {
                                    modelData.deleteSummaryItem(item)
                                }
                            }
                        } label: {
                            Text("转换")
                        }.tint(.green)
                        
//                        Button {
//                            Self.deleteSummaryItem = item
//                            self.showingDeleteAlert.toggle()
//                        } label: {
//                            Label("Delete", systemImage: "trash")
//                        }.tint(.red)
                    }
                    .frame(maxWidth: .infinity)
            }.padding(.vertical, 15)
                .background(alignment: .bottomTrailing) {
                    HStack {
                        let tags = item.tags.compactMap { tagId in modelData.summaryTagList.first { $0.id == tagId}?.content }
#if os(iOS)
                        TagList(tags: tags) { tag in
                            let tagColor = modelData.summaryTagList.first { $0.content == tag
                            }?.titleColor ?? .gray.opacity(0.2)
                            Text(tag)
                                .font(.system(size: 8))
                                .foregroundColor(.black)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(tagColor)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        #endif
                        Spacer()
                        let timeStr = timeTab == .day ? item.updateAt!.simpleHourMinTimeStr : item.updateAt!.simpleDateStr
                        Text(timeStr).font(.system(size: 12)).foregroundColor(.secondary)
                    }
                    .padding(.bottom, -10)
                }
                .background(alignment: .topTrailing) {
                    HStack {
                        Spacer()
                        Menu {
                            Button("删除", role: .destructive) {
                                Self.deleteSummaryItem = item
                                self.showingDeleteAlert.toggle()
                            }
                        } label: {
                            Label("", systemImage: "ellipsis").foregroundColor(.secondary).font(.system(size: 12))
                        }
                    }
                    .offset(x: 20, y: -8)
                }
        }
    }
}

extension iOSReviewView {
    
    @ViewBuilder
    func RewardSectionView() -> some View {
        Section {
            ForEach(rewardList, id: \.self) { reward in
                
                if let summaryModel = modelData.summaryModelList.filter({ $0.taskId == reward.id
                }).first {
                    let summaryItems = modelData.summaryItemList.filter({ $0.summaryId == summaryModel.generateId })
                        .sorted {
                            $0.updateAt?.timeIntervalSince1970 ?? 0 > $1.updateAt?.timeIntervalSince1970 ?? 0
                        }
                    DisclosureGroup {
                        ForEach(summaryItems) { item in
                            Text(item.content).font(.system(size: 12)).foregroundColor(.secondary)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    Self.selectTask = reward
                                    Self.selectSummaryItem = item
                                    self.showingSummaryView.toggle()
                                }
                                .swipeActions {
                                    Button {
                                        Self.deleteSummaryItem = item
                                        self.showingDeleteAlert.toggle()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }.tint(.red)
                                }
                        }
                    } label: {
                        RewardRowView(reward: reward)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.openEvent(id: reward.id)
                            }
                    }

                } else {
                    RewardRowView(reward: reward)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.openEvent(id: reward.id)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    func EventSectionView() -> some View {
        Section {
            ForEach(eventList, id: \.self) { event in
                
                if let summaryModel = modelData.summaryModelList.filter({ $0.taskId == event.id
                }).first {
                    let summaryItems = modelData.summaryItemList.filter({ $0.summaryId == summaryModel.generateId })
                        .sorted {
                            $0.updateAt?.timeIntervalSince1970 ?? 0 > $1.updateAt?.timeIntervalSince1970 ?? 0
                        }
                    DisclosureGroup {
                        ForEach(summaryItems) { item in
                            Text(item.content).font(.system(size: 12)).foregroundColor(.secondary)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    Self.selectTask = event
                                    Self.selectSummaryItem = item
                                    self.showingSummaryView.toggle()
                                }
                                .swipeActions {
                                    Button {
                                        Self.deleteSummaryItem = item
                                        self.showingDeleteAlert.toggle()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }.tint(.red)
                                }
                        }
                    } label: {
                        EventRowView(event: event)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.openEvent(id: event.id)
                            }
                    }

                } else {
                    EventRowView(event: event)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.openEvent(id: event.id)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    func DayRowView() -> some View {
        Section {
            ForEach(summaryItemList, id: \.self) { item in
                Text(item.content).font(.system(size: 12))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard let summaryModel = modelData.summaryModelList.first(where: { $0.items.contains { itemId in
                            return itemId == item.generateId}
                        }) else {
                            return
                        }
                        let tasks: [any BasicTaskProtocol] = modelData.itemList + modelData.rewardList
                        guard let task = tasks.first(where: { $0.id == summaryModel.taskId }) else {
                            return
                        }
                        Self.selectTask = task
                        Self.selectSummaryItem = item
                        self.showingSummaryView.toggle()
                    }
                    .swipeActions {
                        Button {
                            Self.deleteSummaryItem = item
                            self.showingDeleteAlert.toggle()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }.tint(.red)
                    }
            }
        }
    }
    
    @ViewBuilder
    func EventRowView(event: EventItem) -> some View {
        HStack {
            Image(systemName: event.isFinish ? "largecircle.fill.circle" : "circle")
                .imageScale(.medium)
                .foregroundColor(.accentColor)
            Text(event.title)
        }
        .swipeActions {
            Button {
                Self.selectTask = event
                self.showingSummaryView.toggle()
            } label: {
                Label("复盘", systemImage: "Flag")
            }.tint(.accentColor)
        }
    }
    
    @ViewBuilder
    func RewardRowView(reward: RewardModel) -> some View {
        HStack {
            Text(reward.title)
        }
        .swipeActions {
            Button {
                Self.selectTask = reward
                self.showingSummaryView.toggle()
            } label: {
                Label("复盘", systemImage: "Flag")
            }.tint(.accentColor)
        }
    }
    
}

extension iOSReviewView {
    
    func dateInTimeTab(_ date: Date, selectDate: Date, tab: TimeTab) -> Bool {
        switch tab {
        case .day:
            return Date.isSameDay(date1: date, date2: selectDate)
        case .week:
            return Date.isSameWeek(date1: date, date2: selectDate)
        case .month:
            return Date.isSameMonth(date1: date, date2: selectDate)
        case .all, .year:
            return true
        }
    }
}

extension iOSReviewView {
    
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
        case .all, .year:
            text = "所有事项"
        }
        self.titleText = text
    }
    
}

extension iOSReviewView {
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
