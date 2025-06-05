//
//  Date+Extensions.swift
//  JustDo
//
//  Created by LQ on 2024/3/29.
//

import SwiftUI

extension Date {
    
    func isSameTime(timeTab: TimeTab, date: Date) -> Bool {
        switch timeTab {
        case .day:
            return self.isInSameDay(as: date)
        case .week:
            return self.isInSameWeek(as: date)
        case .month:
            return self.isInSameWeek(as: date)
        case .year:
            return self.isInSameYear(as: date)
        case .all:
            return false
        }
    }
    
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
    
    var percentOfDay: Double {
        let calendar = Calendar.current
        let now = self
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let second = calendar.component(.second, from: now)
        
        // 将当前时间转换为一天中的总秒数
        let totalSeconds = hour * 3600 + minute * 60 + second
        
        // 一天的总秒数
        let totalSecondsInADay = 24 * 3600
        
        // 计算百分比
        let percentage = (Double(totalSeconds) / Double(totalSecondsInADay)) * 100
        
        return percentage
    }
    
    var percentOfWeek: Double {
        let calendar = Calendar.current
        let now = self
        
        // 获取当前周的开始时间
        let weekStartDate = startOfWeek
        
        // 计算从周开始到当前时间的总秒数
        let secondsFromWeekStart = calendar.dateComponents([.second], from: weekStartDate, to: now).second!
        
        // 一周的总秒数
        let totalSecondsInAWeek = 7 * 24 * 3600
        
        // 计算百分比
        let percentage = (Double(secondsFromWeekStart) / Double(totalSecondsInAWeek)) * 100
        
        return percentage
    }
    
    var percentOfMonth: Double {
        let calendar = Calendar.current
        let now = self
        
        // 获取当前月的开始时间
        let monthStart = calendar.dateComponents([.year, .month], from: now)
        let monthStartDate = calendar.date(from: monthStart)!
        
        // 计算从月开始到当前时间的总秒数
        let secondsFromMonthStart = calendar.dateComponents([.second], from: monthStartDate, to: now).second!
        
        // 获取当前月的总天数
        let range = calendar.range(of: .day, in: .month, for: monthStartDate)!
        let totalDaysInMonth = range.count
        let totalSecondsInMonth = totalDaysInMonth * 24 * 3600
        
        // 计算百分比
        let percentage = (Double(secondsFromMonthStart) / Double(totalSecondsInMonth)) * 100
        
        return percentage
    }
    
    var percentOfYear: Double {
        let calendar = Calendar.current
        let now = Date()
        
        // 获取当前年的开始时间
        let yearStart = calendar.dateComponents([.year], from: now)
        let yearStartDate = calendar.date(from: yearStart)!
        
        // 计算从年开始到当前时间的总秒数
        let secondsFromYearStart = calendar.dateComponents([.second], from: yearStartDate, to: now).second ?? 0
        
        // 获取当前年的年份
        let year = yearStart.year ?? Calendar.current.component(.year, from: now)
        
        // 获取当前年的总天数（考虑闰年）
        let totalDaysInYear = isLeapYear(year: year) ? 366 : 365
        let totalSecondsInYear = totalDaysInYear * 24 * 3600
        
        // 计算百分比
        let percentage = (Double(secondsFromYearStart) / Double(totalSecondsInYear)) * 100
        
        return percentage
    }
    
    func isLeapYear(year: Int) -> Bool {
        return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
    }
    
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
//        if isToday {
//            return format("HH:mm")
//        }
        return format("MM-dd HH:mm")
    }
    
    var simpleTimeStr: String {
        format("HH:mm")
    }

    var simpleHourMinTimeStr: String {
        format("HH:mm")
    }
    
    var totalDaysThisMonth: Int {
        return Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 0
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
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        let start = Calendar.current.startOfDay(for: self)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else {
            return self
        }
        return end.addingTimeInterval(-0.001) // 精确到毫秒
    }

    var startOfWeek: Date {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return self }
        if sunday.weekday == 2 {
            return sunday
        }
        return gregorian.date(byAdding: .day, value: 1, to: sunday) ?? self
        
//        let calendar = Calendar.current
//        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: self)
//        components.weekday = 2 // 1 represents Sunday
//
//        return calendar.date(from: components) ?? self
        
//        let calendar = Calendar.current
//        let endDay = calendar.startOfDay(for: endOfWeek)
//        return calendar.date(byAdding: .day, value: -6, to: endDay) ?? self
    }
    
    var endOfWeek: Date {
        let startOfWeek = self.startOfWeek
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
        
//        let calendar = Calendar.current
//        return calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
        
//        let calendar = Calendar.current
//        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: self)
//        components.weekday = 2 // 1 represents Sunday
//
//        return calendar.date(from: components) ?? self
        
//        var gregorian = Calendar(identifier: .gregorian)
//        gregorian.firstWeekday = 1
//        guard let date = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return self }
//        return date
    }
    
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        components.month! += 1
        components.day = 0
        return calendar.date(from: components)!
    }
    
    var isSameHour: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedSame
    }
    
    
    var isPast: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedAscending
    }
    
    func fetchWeek(_ date: Date = .init()) -> [WeekDay] {
        let calendar = Calendar.current
        var week: [WeekDay] = []
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: date.startOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
        return week
    }
    
    var weekDays: [Date] {
        var week: [Date] = []
        let calendar = Calendar.current
        let startOfWeek = self.startOfWeek
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                week.append(weekDay)
            }
        }
        return week
    }
    
    var monthDays: [Date] {
        var dates = [Date]()
        var startDate = self.startOfMonth
        let weekDayOfStartDate = startDate.weekday
        if weekDayOfStartDate <= 3 { // 小于三天，则不算做当月
            startDate = startDate.nextWeekDate
        }
        while isInSameMonth(as: startDate) {
            dates.append(startDate)
            startDate = startDate.nextWeekDate
        }
        return dates
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
    
    static func timelineHeight(start: Date, end: Date, isPlan: Bool = false) -> CGFloat {
//        if isPlan {
//            let startTime = start.timeIntervalSince(start.startTimeOfDay)
//            let endTime = end.timeIntervalSince(end.startTimeOfDay)
//            return (endTime - startTime) / 3600 * 40
//        }
        return (end.timeIntervalSince1970 - start.timeIntervalSince1970) / 3600 * 40
    }
    
    var simpleDayAndWeekStr: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M.d EEE"
        let chineseLocale = Locale(identifier: "zh_CN")
        dateFormatter.locale = chineseLocale
        return dateFormatter.string(from: self)
    }
    
    var simpleMonthAndDay: String {
        format("MM-dd")
    }
    
    var monthAbbreviation: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM" // "MMM" 格式会返回月份的缩写，如 "Jan", "Feb" 等
        return dateFormatter.string(from: self)
    }
    
    var isWeekend: Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.weekday], from: self)
        let weekday = components.weekday
        return weekday == 1 || weekday == 7
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

    var timeIntervalsFromStartOfDay: TimeInterval {
        return self.timeIntervalSince1970 - self.startTimeOfDay.timeIntervalSince1970
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
        for index in 0..<24 {
            if let date = self.date(byAdding: .hour, value: index * 1, to: startOfDay) {
                hours.append(date)
            }
        }
        return hours
    }
    
}
