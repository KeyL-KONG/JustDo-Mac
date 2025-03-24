//
//  WeekCalendarView.swift
//  ToDo
//
//  Created by LQ on 2025/3/23.
//

import SwiftUI

struct Constants {
    static let dayHeight = 50.0
}

@available(macOS 15.0, *)
struct WeekCalendarView: View {
    
    let isDragging: Bool
    @Binding var title: String
    @Binding var focused: Week
    @Binding var selection: Date?
    
    @State private var weeks: [Week]
    @State private var position: ScrollPosition
    @State private var calendarWidth: CGFloat = .zero
    
    init(_ title: Binding<String>, selection: Binding<Date?>, focused: Binding<Week>, isDragging: Bool) {
        self.isDragging = isDragging
        _title = title
        _focused = focused
        _selection = selection
        
        let theNearestMonday = Calendar.neareastMonday(from: focused.wrappedValue.days.first ?? .now)
        let currentWeek = Week(order: .current, days: Calendar.currentWeek(from: theNearestMonday))
        
        let previousWeek: Week = if let firstDay = currentWeek.days.first {
            Week(order: .previous, days: Calendar.previousWeek(from: firstDay))
        } else {
            Week(order: .previous, days: [])
        }
        
        let nextWeek: Week = if let lastDay = currentWeek.days.last {
            Week(order: .next, days: Calendar.nextWeek(from: lastDay))
        } else {
            Week(order: .next, days: [])
        }
        
        _weeks = .init(initialValue: [previousWeek, currentWeek, nextWeek])
        _position = State(initialValue: ScrollPosition(id: focused.id))
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(weeks) { week in
                    VStack {
                        WeekView(week: week, selectDate: $selection, dragProgress: .zero)
                            .frame(width: calendarWidth, height: Constants.dayHeight)
                            .onAppear {
                                loadWeek(from: week)
                            }
                    }
                }
            }
            .scrollTargetLayout()
            .frame(height: Constants.dayHeight)
        }
        .scrollDisabled(isDragging)
        .scrollPosition($position)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            calendarWidth = newValue
        }
        .onChange(of: position) { oldValue, newValue in
            guard let focusedWeek = weeks.first(where: { $0.id == (newValue.viewID as? String)
            }) else {
                return
            }
            focused = focusedWeek
            title = Calendar.monthAndYear(from: focusedWeek.days.last!)
        }
        .onChange(of: selection) { oldValue, newValue in
            guard let date = newValue, let week = weeks.first(where: { $0.days.contains(date) }) else {
                return
            }
            focused = week
        }

    }
}

@available(macOS 15.0, *)
extension WeekCalendarView {
    func loadWeek(from week: Week) {
        if week.order == .previous, weeks.first == week, let firstDay = week.days.first {
            let previousWeek = Week(order: .previous, days: Calendar.previousWeek(from: firstDay))
            
            var weeks = self.weeks
            weeks.insert(previousWeek, at: 0)
            self.weeks = weeks
        } else if week.order == .next, weeks.last == week, let lastDay = week.days.last {
            let nextWeek = Week(order: .next, days: Calendar.nextWeek(from: lastDay))
            
            var weeks = self.weeks
            weeks.append(nextWeek)
            self.weeks = weeks
        }
    }
}

extension Calendar {
    
    static func neareastMonday(from date: Date) -> Date {
        let calendar = Calendar.current
        // 获取日期所在的周并找到周一
        guard let monday = calendar.date(bySetting: .weekday, value: 2, of: date) else {
            return date
        }
        return monday
    }
    
    static func currentWeek(from date: Date) -> [Date] {
        let monday = neareastMonday(from: date) // 先找到最近的周一
        var dates: [Date] = []
        let calendar = Calendar.current
        var currentDate = monday
        
        // 生成完整的周一到周日日期
        for _ in 0..<7 {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        return dates
    }
    
    static func previousWeek(from date: Date) -> [Date] {
        let prevMonday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: neareastMonday(from: date))!
        return currentWeek(from: prevMonday)
    }
    
    static func nextWeek(from date: Date) -> [Date] {
        let nextMonday = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: neareastMonday(from: date))!
        return currentWeek(from: nextMonday)
    }
    
    static func monthAndYear(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"  // 设置日期格式为年-月
        formatter.locale = Locale(identifier: "en_US_POSIX") // 固定格式防止地区差异
        return formatter.string(from: date)
    }
}

#Preview {
    if #available(macOS 15.0, *) {
        WeekCalendarView(.constant(""), selection: .constant(nil), focused: .constant(Week(order: .current, days: [.now])), isDragging: false)
    } else {
        // Fallback on earlier versions
    }
}
