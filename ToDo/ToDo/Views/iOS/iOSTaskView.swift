//
//  iOSTaskView.swift
//  ToDo
//
//  Created by LQ on 2025/6/28.
//

import SwiftUI

#if os(iOS)
struct iOSTaskView: View {
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel
    @State var selection: TimeTab = .day
    var timeTabs: [TimeTab] = [.day, .week, .month, .year]
    
    @State var titleText: String = ""
    @State var selectDate: Date = .now
    
    @State var showUnFinishOnly: Bool = false
    @State var selectedMode: DisplayMode = .time
    var displayModes: [DisplayMode] = [.task, .time]
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("事项统计").font(.title.bold()).foregroundStyle(.blue)
                
                Spacer()
                
                Menu {
                    Toggle(isOn: $showUnFinishOnly) {
                        Text("显示未完成")
                    }
                    
                    Picker("排序类型", selection: $selectedMode) {
                        ForEach(displayModes, id:\.self) { mode in
                            Text(mode.id).tag(mode)
                        }
                    }
                } label: {
                    Label("", systemImage: "ellipsis.circle").foregroundStyle(.blue).font(.title2)
                }
            }.padding(.leading, 15)
            
            Picker("", selection: $selection) {
                Label("日", systemImage: "")
                    .tag(TimeTab.day)
                Label("周", systemImage: "")
                    .tag(TimeTab.week)
                Label("月", systemImage: "")
                    .tag(TimeTab.month)
                Label("年", systemImage: "")
                    .tag(TimeTab.year)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if selection == .day || selection == .week || selection == .month {
                let font = Font.system(size: 20)
                HStack {
                    Button {
                        updateSelectDate(next: false)
                    } label: {
                        Label("", systemImage: "arrow.left").font(font).foregroundColor(.blue)
                    }

                    Spacer()

                    Text(titleText).font(font).foregroundStyle(.blue)
                    
                    if currentTime() {
                        Circle()
                            .frame(width: 8, height: 8, alignment: .center)
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    let disableRightButton = false
                    Button {
                        updateSelectDate(next: true)
                    } label: {
                        Label("", systemImage: "arrow.right").font(font).foregroundColor((disableRightButton ? .gray : .blue))
                    }.disabled(disableRightButton)
                        .opacity((disableRightButton ? 0.5 : 1.0))
                }
                .padding(.horizontal, 10)
                
            }

            Spacer()
            
            switch selection {
            case .day:
                iOSTaskListView(timerModel: timerModel, selectDate: selectDate, timeTab: .day).environmentObject(modelData)
            case .week:
                iOSTaskListView(timerModel: timerModel, selectDate: selectDate, timeTab: .week).environmentObject(modelData)
            case .month:
                iOSTaskListView(timerModel: timerModel, selectDate: selectDate, timeTab: .month).environmentObject(modelData)
            case .year:
                iOSTaskListView(timerModel: timerModel, selectDate: selectDate, timeTab: .year).environmentObject(modelData)
            case .all:
                iOSTaskListView(timerModel: timerModel, selectDate: selectDate, timeTab: .all).environmentObject(modelData)
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            if oldValue != newValue {
                updateTitleText()
            }
        }
        .onChange(of: selectDate) { oldValue, newValue in
            if oldValue != newValue {
                updateTitleText()
            }
        }
        .onAppear {
            updateTitleText()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if selectDate != .now {
                selectDate = .now
            }
        }
    }
    
    func updateSelectDate(next: Bool) {
        var date = selectDate
        switch self.selection {
        case .day:
            date = next ? date.tomorrowDay : date.yesterday
        case .week:
            date = next ? date.nextWeekDate : date.previousWeekDate
        case .month:
            date = next ? date.nextMonth : date.previousMonth
        default:
            break
        }
        selectDate = date
    }
    
    func updateTitleText() {
        var text = ""
        switch self.selection {
        case .day:
            text = selectDate.monthDayAndWeek
        case .week:
            text = selectDate.simpleWeek
        case .month:
            text = selectDate.simpleMonthAndYear
        case .year:
            text = selectDate.year.stringValue ?? ""
        case .all:
            text = "所有事项"
        }
        self.titleText = text
    }
    
    func currentTime() -> Bool {
        switch self.selection {
        case .day:
            return selectDate.isToday
        case .week:
            return selectDate.isInThisWeek
        case .month:
            return selectDate.isInThisMonth
        default:
            return false
        }
    }
    
}
#endif
