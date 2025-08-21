//
//  ProgressView.swift
//  Summary
//
//  Created by LQ on 2024/6/30.
//

import SwiftUI
//
//struct ProgressView: View {
//    
//    @EnvironmentObject var modelData: ModelData
//    @State var timeTab: TimeTab = .week
//    @State var selectDate: Date = .now {
//        didSet {
//            print("select date: \(selectDate)")
//        }
//    }
//    @State private var showProgressMenu = false
//    @State private var showingEditProgress = false
//    
//    private static var selectEditProgress: ProgressItem?
//    
//    @State private var weekSlider: [[Date.WeekDay]] = []
//    @State private var currentWeekIndex: Int = 1
//    @Namespace private var animation
//    
//    @State var titleText: String = "当日进度"
//    @State var toggleRefresh: Bool = false
//    
//    var tabs: [TimeTab] = [.day, .week, .month, .all]
//#if os(iOS)
//    @State var offsetObserver = PageOffsetObserver()
//    #endif
//    
//    var progressItems: [ProgressItem] {
//        modelData.progressItemList.filter { item in
//            switch self.timeTab {
//            case .day:
//                return item.progresssType == .day
//            case .week:
//                return item.progresssType == .week
//            case .month:
//                return item.progresssType == .month
//            case .all:
//                return item.progresssType == .all || item.progresssType == .custom
//            }
//        }.sorted { first, second in
//            return self.progressValue(with: first) > self.progressValue(with: second)
//        }
//    }
//    
//    var body: some View {
//        NavigationView(content: {
//            VStack(alignment: .leading, content: {
//
//                HStack(alignment: .top) {
//                    Text("进度").font(.title.bold()).foregroundStyle(.blue)
//                    Spacer()
//                    
//                    Menu {
//                        Button("进度列表") {
//                            
//                        }
//                    } label: {
//                        Label("", systemImage: "ellipsis.circle").foregroundStyle(.blue).font(.title2)
//                    }
//
//                }.padding(.leading, 15)
//                
//                if toggleRefresh {
//                    Text("")
//                }
//                
//                Tabbar(.gray)
//                    .overlay(content: {
//#if os(iOS)
//                        if let collectionViewBounds = offsetObserver.collectionView?.bounds {
//                            GeometryReader(content: { geometry in
//                                let width = geometry.size.width
//                                let tabCount = CGFloat(tabs.count)
//                                let capsuleWidth = width / tabCount
//                                let progress = offsetObserver.offset / collectionViewBounds.size.width
//                                
//                                Capsule()
//                                    .fill(.black)
//                                    .frame(width: capsuleWidth)
//                                    .offset(x: progress * capsuleWidth)
//                                
//                                Tabbar(.white, .semibold)
//                                    .mask(alignment: .leading) {
//                                        Capsule()
//                                            .frame(width: capsuleWidth)
//                                            .offset(x: progress * capsuleWidth)
//                                    }
//                            })
//                        }
//                        #endif
//                    })
//                    .background(.ultraThinMaterial)
//                    .clipShape(.capsule)
//                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
//                    .shadow(color: .black.opacity(0.05), radius: 5, x: -5, y: -5)
//                    .padding([.horizontal, .top], 10)
//                
//                TabView(selection: $timeTab,
//                        content:  {
//                    ListView().tag(TimeTab.day)
//                        .background {
//#if os(iOS)
////                            if !offsetObserver.isObserving {
////                                FindCollectionView {
////                                    offsetObserver.collectionView = $0
////                                    offsetObserver.observer()
////                                    toggleRefresh.toggle()
////                                }
////                            }
//                            #endif
//                        }
//                    
//                    ListView().tag(TimeTab.week)
//                    
//                    ListView().tag(TimeTab.month)
//                    
//                    ListView().tag(TimeTab.all)
//                    
//                    
//                })
//#if os(iOS)
//                .tabViewStyle(.page(indexDisplayMode: .never))
//                #endif
//            })
//        })
//#if os(iOS)
//        .onChange(of: timeTab) { oldValue, newValue in
//            if oldValue != newValue {
//                updateTitleText()
//            }
//        }
//        .onChange(of: selectDate) { oldValue, newValue in
//            if oldValue != newValue {
//                updateTitleText()
//            }
//        }
//        #endif
//        .onAppear {
//            if weekSlider.isEmpty {
//                let currentWeek = Date().fetchWeek()
//                if let firstDate = currentWeek.first?.date {
//                    weekSlider.append(firstDate.createPreviousWeek())
//                }
//                weekSlider.append(currentWeek)
//                if let lastDate = currentWeek.last?.date {
//                    weekSlider.append(lastDate.createNextWeek())
//                }
//            }
//            updateTitleText()
//        }
//        .sheet(isPresented: $showingEditProgress, content: {
//            if let item = Self.selectEditProgress {
//                EditProgressView(showSheetView: $showingEditProgress, progressItem: item).environmentObject(modelData)
//            } else {
//                EditProgressView(showSheetView: $showingEditProgress).environmentObject(modelData)
//            }
//        })
//        .overlay(alignment: .bottomTrailing, content: {
//            Button(action: {
//                Self.selectEditProgress = nil
//                showingEditProgress.toggle()
//            }, label: {
//                Image(systemName: "plus")
//                    .fontWeight(.semibold)
//                    .foregroundStyle(.white)
//                    .frame(width: 55, height: 55)
//                    .background(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
//            })
//            .padding(.vertical, 20)
//            .padding(.horizontal, 40)
//        })
//    }
//    
//    @ViewBuilder
//    func ListView() -> some View {
//        VStack {
//            if timeTab == .day {
//                DayHeaderView()
//            }
//
//            if timeTab == .week || timeTab == .month {
//                HeaderView()
//            }
//            
//            List {
//                ForEach(progressItems, id: \.self) { item in
//                    Section {
//                        HStack {
//                            if item.progresssType == .week || item.progresssType == .month {
//                                VStack {
//                                    HStack {
//                                        Text(item.content).font(.system(size: 15))
//                                        Spacer()
//                                    }.padding(.top, 10)
//                                    
//                                    Spacer(minLength: 5)
//                                    
//                                    if item.progresssType == .week {
//                                        BarChartWeekView(data: barChartWeekData(with: item), color: barColor(with: item))
//                                            .frame(maxHeight: 30)
//                                    } else if item.progresssType == .month {
//                                        BarChartMonthView(data: barChartMonthData(with: item), color: barColor(with: item))
//                                            .frame(maxHeight: 30)
//                                    }
//                                   
//                                }
//                                
//                            } else {
//                                Text(item.content).font(.system(size: 15))
//                            }
//                            Spacer()
//#if os(iOS)
//                            ProgressCircleView(scale: 0.3, progressValue: progressValue(with: item), colors: progressColors(with: item)).padding(5)
//                            #endif
//                        }
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            Self.selectEditProgress = item
//                            showingEditProgress.toggle()
//                        }
//                    }
//                }
//                
//            }
//#if os(iOS)
//            .listSectionSpacing(15)
//            #endif
//            .refreshable {
//                modelData.loadFromServer {}
//            }
//        }
//        
//    }
//    
//}
//
//extension ProgressView {
//    
//    @ViewBuilder
//    func Tabbar(_ tint: Color, _ weight: Font.Weight = .regular) -> some View {
//        HStack(spacing: 0, content: {
//            ForEach(tabs, id: \.self) { tab in
//                Text(tab.title)
//                    .foregroundStyle(tint)
//                    .font(.system(size: 15))
//                    .fontWeight(weight)
//                    .padding(.vertical, 8)
//                    .frame(maxWidth: .infinity)
//                    .contentShape(.rect)
//                    .onTapGesture {
//                        withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
//                            timeTab = tab
//                        }
//                    }
//            }
//        })
//    }
//    
//}
//
//extension ProgressView {
//    
//    func progressValue(with item: ProgressItem) -> CGFloat {
//        let totalMins = totalTimeMins(with: item)
//        let progressValue = CGFloat(totalMins) / CGFloat(item.totalMins)
//        return progressValue
//    }
//    
//    func totalTimeMins(with item: ProgressItem) -> Int {
//        var totalMins = 0
//        item.rewardIds.forEach { reward in
//            modelData.rewardList.filter { $0.id == reward }.forEach { model in
//                let intervals = model.intervals + modelData.itemList.filter({ $0.rewardId == model.id }).compactMap { $0.intervals }.joined()
//                var startTime = item.startTime
//                var endTime = item.endTime
//                switch item.progresssType {
//                case .day:
//                    startTime = selectDate.startTimeOfDay
//                    endTime = selectDate.lastTimeOfDay
//                case .week:
//                    startTime = selectDate.startOfWeek.startTimeOfDay
//                    endTime = selectDate.endOfWeek.lastTimeOfDay
//                case .month:
//                    startTime = selectDate.startOfMonth.startTimeOfDay
//                    endTime = selectDate.endOfMonth.lastTimeOfDay
//                default:
//                    break
//                }
//                print("select date start: \(startTime.simpleDateStr)")
//                print("select date end: \(endTime.simpleDateStr)")
//                
//                var totalIntervals = intervals
//                if item.progresssType != .all {
//                    totalIntervals = intervals.filter {
//                        startTime < $0.end && $0.end < endTime && $0.interval < 60 * 60 * 24
//                    }
//                }
//                totalMins += Int(totalIntervals.compactMap {$0.interval}.reduce(0, +) / 60)
//            }
//        }
//        return totalMins
//    }
//    
//    func progressColors(with item: ProgressItem) -> [Color] {
//        let goodReward: Bool = modelData.rewardList.first { reward in
//            return item.rewardIds.contains(reward.id)
//        }?.rewardType ?? .none == .good
//        return goodReward ? [.green, .green.opacity(0.6)] : [.red, .red.opacity(0.6)]
//    }
//    
//    func barColor(with item: ProgressItem) -> Color {
//        let goodReward: Bool = modelData.rewardList.first { reward in
//            return item.rewardIds.contains(reward.id)
//        }?.rewardType ?? .none == .good
//        return goodReward ? .green.opacity(0.6) : .red.opacity(0.6)
//    }
//    
//    func barChartWeekData(with item: ProgressItem) -> [BarChartDateData] {
//        var weekData = [BarChartDateData]()
//        selectDate.weekDays.forEach { date in
//            var totalMins = 0
//            item.rewardIds.forEach { reward in
//                modelData.rewardList.filter { $0.id == reward }.forEach { model in
//                    let intervals = model.intervals + modelData.itemList.filter({ $0.rewardId == model.id }).compactMap { $0.intervals }.joined()
//                    intervals.forEach { interval in
//                        if date.isInSameDay(as: interval.end) {
//                            totalMins += Int(interval.interval / 60)
//                        }
//                    }
//                }
//            }
//            weekData.append(BarChartDateData.init(date: date, value: totalMins))
//        }
//        return weekData
//    }
//    
//    func barChartMonthData(with item: ProgressItem) -> [BarChartDateData] {
//        var monthData = [BarChartDateData]()
//        selectDate.monthDays.forEach { date in
//            var totalMins = 0
//            item.rewardIds.forEach { reward in
//                modelData.rewardList.filter { $0.id == reward }.forEach { model in
//                    let intervals = model.intervals + modelData.itemList.filter({ $0.rewardId == model.id }).compactMap { $0.intervals }.joined()
//                    intervals.forEach { interval in
//                        if date.isInSameWeek(as: interval.end) {
//                            totalMins += Int(interval.interval / 60)
//                        }
//                    }
//                }
//            }
//            monthData.append(BarChartDateData.init(date: date, value: totalMins))
//        }
//        return monthData
//    }
//    
//}
//
//extension ProgressView {
//    
//    @ViewBuilder
//    func HeaderView() -> some View {
//        HStack(alignment: .center) {
//            let font = Font.system(size: 20)
//            if timeTab == .day || timeTab == .all {
//                Text(titleText).font(font).foregroundColor(.accentColor)
//            } else {
//                Button {
//                    updateSelectDate(next: false)
//                } label: {
//                    Label("", systemImage: "arrow.left").font(font).foregroundColor(.blue)
//                }
//                
//                Spacer()
//
//                Text(titleText).font(font).foregroundStyle(.blue)
//                
//                Spacer()
//                
//                let disableRightButton =
//                (timeTab == .week && selectDate.isInThisWeek) ||
//                (timeTab == .month && selectDate.isInThisMonth)
//                
//                Button {
//                    updateSelectDate(next: true)
//                } label: {
//                    Label("", systemImage: "arrow.right").font(font).foregroundColor((disableRightButton ? .gray : .blue))
//                }.disabled(disableRightButton)
//                    .opacity((disableRightButton ? 0.5 : 1.0))
//            }
//        }.padding(.horizontal, 15)
//            .padding(.top, 5)
//    }
//    
//}
//
//extension ProgressView {
//    @ViewBuilder
//    func DayHeaderView() -> some View {
//        VStack(alignment: .leading, spacing: 6) {
//            
//            /// Week Slider
//            TabView(selection: $currentWeekIndex,
//                    content:  {
//                ForEach(weekSlider.indices, id: \.self) { index in
//                    let week = weekSlider[index]
//                    WeekView(week)
//                        .padding(.horizontal, 15)
//                        .tag(index)
//                }
//            })
//#if os(iOS)
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            #endif
//            .frame(height: 90)
//        }
//        .hSpacing(.leading)
//        .padding(5)
//        .background(.white)
//    }
//    
//    @ViewBuilder
//    func WeekView(_ weeks: [Date.WeekDay]) -> some View {
//        HStack(spacing: 0, content: {
//            ForEach(weeks) { day in
//                VStack(spacing: 8, content: {
//                    Text(day.date.format("E"))
//#if os(iOS)
//                        .font(.callout)
//                        .textScale(.secondary)
//                    #endif
//                        .fontWeight(.medium)
//                        .foregroundStyle(.gray)
//                    
//                    Text(day.date.format("dd"))
//#if os(iOS)
//                        .font(.callout)
//                        .textScale(.secondary)
//                    #endif
//                        .fontWeight(.bold)
//                        .foregroundStyle(isSameDate(day.date, selectDate) ? .white : .gray)
//                        .frame(width: 35, height: 35)
//                        .background(content: {
//                            if isSameDate(day.date, selectDate) {
//                                Circle().fill(.blue)
//                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
//                            }
//                            
//                            if day.date.isToday {
//                                Circle()
//                                    .fill(.cyan)
//                                    .frame(width: 5, height: 5)
//                                    .vSpacing(.bottom)
//                                    .offset(y: 12)
//                            }
//                        })
//                        .background(.white.shadow(.drop(radius: 1)), in: .circle)
//                })
//                .hSpacing(.center)
//                .contentShape(.rect)
//                .onTapGesture {
//                    withAnimation {
//                        selectDate = day.date
//                    }
//                }
//            }
//        })
//    }
//}
//
//
//extension ProgressView {
//    
//    func updateSelectDate(next: Bool) {
//        var date = selectDate
//        switch self.timeTab {
//        case .week:
//            date = next ? date.nextWeekDate : date.previousWeekDate
//        case .month:
//            date = next ? date.nextMonth : date.previousMonth
//        default:
//            break
//        }
//        self.selectDate = date
//    }
//    
//    func updateTitleText() {
//        var text = ""
//        switch self.timeTab {
//        case .day:
//            text = "当日进度"
//        case .week:
//            text = selectDate.simpleWeek
//        case .month:
//            text = selectDate.simpleMonthAndYear
//        case .all:
//            text = "所有进度"
//        }
//        self.titleText = text
//        print("select title date: \(selectDate.simpleDateStr)")
//    }
//    
//}
//
//#Preview {
//    ProgressView()
//}


class PageOffsetObserver: NSObject, ObservableObject {
    @Published var collectionView: UICollectionView?
    @Published var offset: CGFloat = 0
    @Published private(set) var isObserving: Bool = false
    func observe() {
        
    }
    
    func remove() {
        
    }
    
}

struct FindCollectionView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
