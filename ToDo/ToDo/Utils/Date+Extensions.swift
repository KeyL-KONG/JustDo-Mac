//
//  Date+Extensions.swift
//  JustDo
//
//  Created by LQ on 2024/3/29.
//

import SwiftUI

extension Date {
    
    var simpleMonthAndYear: String {
        format("yyyy-MM")
    }
    
    var simpleDayAndMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd EEEE"
        dateFormatter.locale = Locale(identifier: "zh_CN")
        return dateFormatter.string(from: self)
    }
    
    var simpleWeek: String {
        return startOfWeek.format("MM-dd") + "~" + endOfWeek.format("MM-dd")
    }
    
    var simpleDateStr: String {
        format("yyyy-MM-dd HH:mm")
    }
    
    var simpleDayAndWeekStr: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M.d EEE"
        let chineseLocale = Locale(identifier: "zh_CN")
        dateFormatter.locale = chineseLocale
        return dateFormatter.string(from: self)
    }
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    static func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        
        return components1.year == components2.year &&
               components1.month == components2.month &&
               components1.day == components2.day
    }
    
    static func isSameWeek(date1: Date, date2: Date) -> Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let components1 = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date1)
        let components2 = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date2)
        
        return components1.yearForWeekOfYear == components2.yearForWeekOfYear &&
               components1.weekOfYear == components2.weekOfYear
    }
    
    static func isSameMonth(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month], from: date1)
        let components2 = calendar.dateComponents([.year, .month], from: date2)
        
        return components1.year == components2.year &&
               components1.month == components2.month
    }
    
    var isWeekend: Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.weekday], from: self)
        let weekday = components.weekday
        return weekday == 1 || weekday == 7
    }
    
    func dateByAddingMinutes(_ minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    var previousWeekDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -7, to: self)!
    }
    
    var nextWeekDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 7, to: self)!
    }
    
    var yesterday: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -1, to: self)!
    }
    
    var tomorrowDay: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: +1, to: self)!
    }
    
    var previousMonth: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: -1, to: self)!
    }
    
    var nextMonth: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: 1, to: self)!
    }
    
    /// Checking Whether the date is Today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var startOfWeek: Date {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return self }
        return gregorian.date(byAdding: .day, value: 1, to: sunday) ?? self
    }
    
    var endOfWeek: Date {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return self }
        return gregorian.date(byAdding: .day, value: 7, to: sunday) ?? self
    }
    
    var isSameHour: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedSame
    }
    
    
    var isPast: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedAscending
    }
    
    func fetchWeek(_ date: Date = .init()) -> [WeekDay] {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        var week: [WeekDay] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startOfWeek = weekForDate?.start else {
            return []
        }
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
        return week
    }
    
    func fetchWeekDates(_ date: Date = .init()) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let startOfDate = calendar.startOfDay(for: date)
        var week: [Date] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startOfWeek = weekForDate?.start else {
            return []
        }
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                week.append(weekDay)
            }
        }
        print("week days: \(week)")
        return week
    }
    
    func createNextWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfLastDate = calendar.startOfDay(for: self)
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLastDate) else {
            return []
        }
        return fetchWeek(nextDate)
    }
    
    func createPreviousWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfFirstDate = calendar.startOfDay(for: self)
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: startOfFirstDate) else {
            return []
        }
        return fetchWeek(previousDate)
    }
    
    func isAfter(date: Date, min: Int) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: date, to: self)
        if let minutes = components.minute, minutes >= 0 && minutes <= 30 {
            return true
        }
        return false
    }
    
    func minutesBetweenDates(date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: date, to: self)
        
        if let minutes = components.minute {
            return abs(minutes)
        }
        
        return 0
    }
    
    func daysBetweenDates(date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: self, to: date)
        
        if let days = components.day {
            return abs(days)
        }
        
        return 0
    }
    
    func daysBetweenDates2(date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: date)
        
        if let days = components.day {
            print("days: \(days)")
            return abs(days)
        }
        
        print("days miss")
        return 0
    }
    
    func timeIntervalsBetweenDates(date: Date) -> Double {
        let dateMinutes = date.timeIntervalSince1970 - date.startTimeOfDay.timeIntervalSince1970
        let minutes = self.timeIntervalSince1970 - self.startTimeOfDay.timeIntervalSince1970
        return abs(dateMinutes - minutes)
    }
    
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
    
    var timeIntervalsFromStartOfDay: TimeInterval {
        return self.timeIntervalSince1970 - self.startTimeOfDay.timeIntervalSince1970
    }
    
    var startTimeOfDay: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var lastTimeOfDay: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        return calendar.date(from: components) ?? self
    }
    
    static func min(date1: Date, date2: Date) -> Date {
        return date1.timeIntervalSince1970 < date2.timeIntervalSince1970 ? date1 : date2
    }
    
    static func timelineHeight(start: Date, end: Date) -> CGFloat {
        return (end.timeIntervalSince1970 - start.timeIntervalSince1970) / 1800 * 40
    }
    
    func findClosestDate(to dates: [Date]) -> Date {
        let currentDate = self
        var closestDate: Date?
        var closestInterval: TimeInterval = .greatestFiniteMagnitude
        
        for date in dates {
            let interval = abs(date.timeIntervalSince(currentDate))
            
            if interval < closestInterval {
                closestInterval = interval
                closestDate = date
            }
        }
        
        return closestDate ?? dates.first ?? self
    }
    
}


extension Calendar {
    
    var hours: [Date] {
        let startOfDay = self.startOfDay(for: Date.init())
        var hours: [Date] = []
        for index in 0..<48 {
            if let date = self.date(byAdding: .minute, value: index * 30, to: startOfDay) {
                hours.append(date)
            }
        }
        return hours
    }
    
    func hours(with date: Date) -> [Date] {
        let startOfDay = self.startOfDay(for: date)
        var hours: [Date] = []
        for index in 0..<48 {
            if let date = self.date(byAdding: .minute, value: index * 30, to: startOfDay) {
                hours.append(date)
            }
        }
        return hours
    }
    
}
