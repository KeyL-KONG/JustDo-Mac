//
//  iOSSummaryView.swift
//  ToDo
//
//  Created by LQ on 2025/7/6.
//

import SwiftUI

struct iOSSummaryView: View {
    @EnvironmentObject var modelData: ModelData
    @State var selection: TimeTab = .day
    var timeTabs: [TimeTab] = [.day, .week, .month, .year]
    
    @State var titleText: String = ""
    @State var selectDate: Date = .now
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("时间统计").font(.title.bold()).foregroundStyle(.blue)
                
                Spacer()
                
                Menu {
                    
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
    }
}

extension iOSSummaryView {
    
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
