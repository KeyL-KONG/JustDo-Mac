//
//  EventItem.swift
//  JustDo
//
//  Created by ByteDance on 2023/7/7.
//

import SwiftUI

//struct EventItem: Identifiable, Codable, Hashable {
//
//    var id: String
//    var title: String
//    var mark: String = ""
//    var tag: ItemTag
//    var isFinish: Bool
//    var importance: ImportanceTag
//    var createTime: Date?
//    var planTime: Date?
//    var finishTime: Date?
//
//}

extension EventItem {
    
    var score: Int {
        switch eventType {
        case .num:
            return rewardValue
        case .time:
            let totalTime: Int = intervals.compactMap { $0.interval }.reduce(0, +) / 60
            return totalTime * rewardValue
        case .count:
            return rewardValue * rewardCount
        }
    }
    
    func totalTime(with tabTab: TimeTab) -> Int {
        intervals.filter { dateInTimeTab($0.start, tab: tabTab)}
            .compactMap { $0.interval }
            .reduce(0, +)
    }
    
    func summaryScore(with tabType: TimeTab) -> Int {
        switch eventType {
        case .num:
            if let finishTime = self.finishTime, dateInTimeTab(finishTime, tab: tabType) {
                return rewardValue
            }
            return 0
        //TODO: 补充次数逻辑
        case .count:
            return 0
        case .time:
            let intervals = self.intervals.filter {
                self.dateInTimeTab($0.start, tab: tabType)
            }
            let totalTime: Int = intervals.compactMap { $0.interval }.reduce(0, +) / 60
            return totalTime * rewardValue
        }
    }
    
    func dateInTimeTab(_ date: Date, tab: TimeTab) -> Bool {
        switch tab {
        case .day:
            return date.isInToday
        case .week:
            return date.isInThisWeek
        case .month:
            return date.isInThisMonth
        case .all:
            return true
        }
    }
    
    func score(with tabType: RewardTabType) -> Int {
        switch eventType {
        case .num:
            return rewardValue
        case .time:
            let intervals = tabType == .summary ? self.intervals : self.intervals.filter({ $0.start.isInToday })
            let totalTime: Int = intervals.compactMap { $0.interval }.reduce(0, +) / 60
            return totalTime * rewardValue
        case .count:
            return rewardValue * rewardCount
        }
    }
    
    var sortedIntervals: [LQDateInterval] {
        return intervals.sorted(by: { $0.start.timeIntervalSince1970 >= $1.start.timeIntervalSince1970})
    }
    
}


//enum ItemTag: String, Codable, Identifiable, CaseIterable {
//    var id: String {
//        return description
//    }
//    
//    case work, learn, life
//    
//    static var allCases: [ItemTag] { O
//        return [.work, .learn, .life]
//    }
//    
//    var description: String {
//        switch self {
//        case .work:
//            return "work"
//        case .learn:
//            return "learn"
//        case .life:
//            return "life"
//        }
//    }
//    
//    var titleColor: Color {
//        switch self {
//        case .work:
//            return .green
//        case .learn:
//            return .blue
//        case .life:
//            return .brown
//        }
//    }
//}

enum ImportanceTag: String, Codable, Identifiable, Comparable {
    
    var id: String {
        return description
    }
    
    case low, mid, high
    
    static var allCases: [ImportanceTag] = [.high, .mid, .low]
    
    var value: Int {
        switch self {
        case .low:
            return 0
        case .mid:
            return 1
        case .high:
            return 2
        }
    }
    
    var description: String {
        switch self {
        case .low:
            return "低优先级"
        case .mid:
            return "中优先级"
        case .high:
            return "高优先级"
        }
    }
    
    var simpleDescription: String {
        switch self {
        case .low:
            return "低"
        case .mid:
            return "中"
        case .high:
            return "高"
        }
    }
    
    var titleColor: Color {
        switch self {
        case .low:
            return .green
        case .mid:
            return .yellow
        case .high:
            return .red
        }
    }
    
    static func < (lhs: ImportanceTag, rhs: ImportanceTag) -> Bool {
        let priorityOrder: [ImportanceTag] = [.low, .mid, .high]
        guard let lhsIndex = priorityOrder.firstIndex(of: lhs), let rhsIndex = priorityOrder.firstIndex(of: rhs) else {
            return lhs.rawValue < rhs.rawValue
        }
        return lhsIndex < rhsIndex
    }
    
}

enum EventValueType: Int {
    case num
    case time 
    case count
    
    var description: String {
        switch self {
        case .num:
            return "数值"
        case .time:
            return "时间"
        case .count:
            return "次数"
        }
    }
}

enum FinishState: String, Codable, Identifiable {
    case bad, normal, good
    
    var id: String {
        return description
    }
    
    var description: String {
        switch self {
        case .bad:
            return "糟糕"
        case .normal:
            return "正常"
        case .good:
            return "优秀"
        }
    }
    
    var markText: String {
        switch self {
        case .bad:
            return "不足之处"
        case .normal:
            return "总结"
        case .good:
            return "满意之处"
        }
    }
}

enum TimeTab: Int, Identifiable {
    var id: String {
        switch self {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .all: return "all"
        }
    }
    
    var title: String {
        switch self {
        case .day:
            return "当日"
        case .week:
            return "当周"
        case .month:
            return "当月"
        case .all:
            return "所有"
        }
    }
    
    case day
    case week
    case month
    case all
}

enum RewardType: Int {
    case none
    case good
    case bad
    
    var title: String {
        switch self {
        case .none:
            return ""
        case .good:
            return "奖励"
        case .bad:
            return "惩罚"
        }
    }
    
    var tag: String {
        switch self {
        case .none:
            return ""
        case .good:
            return "+"
        case .bad:
            return "-"
        }
    }
    
    var tagColor: Color {
        switch self {
        case .none:
            return .black
        case .good:
            return .green
        case .bad:
            return .red
        }
    }
}

enum RewardValueType: Int {
    case num
    case time
    
    var title: String {
        switch self {
        case .num:
            return "数值"
        case .time:
            return "时间"
        }
    }
}

enum DisplayMode: Int, Identifiable {
    case time
    case task
    var id: String {
        switch self {
        case .task:
            return "按任务类型"
        case .time:
            return "按时间类型"
        }
    }
}

extension Date {
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var weekday: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar.component(.weekday, from: self)
    }
    
    var weekOfMonth: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar.component(.weekOfMonth, from: self)
    }
    
    var weekFormatString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self)
    }
    
    var formatString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = "E MMMM d日"
        return dateFormatter.string(from: self)
    }

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        var calendar = calendar
        calendar.firstWeekday = 2
        return calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
    
    var firstDayOfMonth: Date {
        let calendar = Calendar.current
        let firstDayComponents = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: firstDayComponents) ?? self
    }

    var lastDayOfMonth: Date {
        let currentDate = Date()
        let calendar = Calendar.current
        var lastDayComponents = DateComponents()
        lastDayComponents.month = 1
        lastDayComponents.day = -1
        let firstDay = firstDayOfMonth
        if
            let lastDay = calendar.date(byAdding: lastDayComponents, to: firstDay) {
            return lastDay
        }
        return self
    }
    
}
