//
//  RewardModel.swift
//  JustDo
//
//  Created by LQ on 2024/4/4.
//

import Foundation
import LeanCloud

enum RewardTabType {
    case reward
    case summary
    case wish
    
    static var allCases: [RewardTabType] {
        [.reward, .summary, .wish]
    }
}

extension RewardTabType {
    var title: String {
        switch self {
        case .reward:
            return "积分"
        case .summary:
            return "总结"
        case .wish:
            return "愿望"
        }
    }
}

enum RewardFixTimeType: Int {
    case onlyWeek
    case onlyWeekend
    case everyday
    
    var title: String {
        switch self {
        case .onlyWeek:
            return "工作日"
        case .onlyWeekend:
            return "周末"
        case .everyday:
            return "每天"
        }
    }
}

enum TaskType {
    case task
    case reward
    
    var type: String {
        switch self {
        case .task:
            return "task"
        case .reward:
            return "reward"
        }
    }
}

protocol BasicTaskProtocol: Identifiable {
    var actionType: EventActionType { get set }
    var setPlanTime: Bool { get set }
    var planTime: Date? { get set }
    var updateAt:Date? { get set }
    var type: TaskType { get }
    var id: String { get set }
    var generateId: String { get set }
    var title: String { get set }
    var mark: String { get set }
    var tag: String { get set }
    var eventType: EventValueType { get set }
    var isFinish: Bool { get set }
    var isCollect: Bool { get set }
    var finishTime: Date? { get set }
    var intervals: [LQDateInterval] { get set }
    var rewardType: RewardType { get set }
    var rewardValueType: RewardValueType { get set }
    var rewardValue: Int { get set }
    var isArchive: Bool { get set }
    func totalTime(with tabTab: TimeTab) -> Int
    func summaryScore(with tabType: TimeTab) -> Int
    func score(with tabType: RewardTabType) -> Int
}

class RewardModel: BaseModel, Identifiable {
    
    var generateId: String = ""
    var title: String = ""
    var mark: String = ""
    var tag: String = "work"
    var eventType: EventValueType = .num
    var isFinish: Bool = false
    var finishTime: Date?
    var intervals: [LQDateInterval] = []
    var rewardType: RewardType = .none
    var rewardValueType: RewardValueType = .num
    var rewardValue: Int = 0
    var rewardCount: Int = 0
    var isCollect: Bool = false // 新增收藏状态字段
    var isArchive: Bool = false
    var planTime: Date? = nil
    
    var fatherId: String = ""
    var childrenIds: [String] = []
    
    var fixTimeType: RewardFixTimeType = .everyday
    var fixTimes: [LQDateInterval] = []
    var actionType: EventActionType = .project
    
    var setPlanTime: Bool = false
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: RewardModelKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createTime = try container.decode(Date.self, forKey: .createTime)
        self.updateAt = try container.decode(Date.self, forKey: .updateAt)
        self.generateId = try container.decode(String.self, forKey: .generateId)
        self.title = try container.decode(String.self, forKey: .title)
        self.mark = try container.decode(String.self, forKey: .mark)
        self.tag = try container.decode(String.self, forKey: .tag)
        self.eventType = EventValueType(rawValue: try container.decode(Int.self, forKey: .eventType)) ?? .num
        self.isFinish = try container.decode(Bool.self, forKey: .isFinish)
        
        var intervals = [LQDateInterval]()
        let dates = try container.decode([[Date]].self, forKey: .intervals)
        dates.forEach { pair in
            if let first = pair.first, let second = pair.last {
                intervals.append(LQDateInterval(start: first, end: second))
            }
        }
        self.intervals = intervals
        self.rewardType = RewardType(rawValue: try container.decode(Int.self, forKey: .rewardType)) ?? .none
        self.rewardValueType = RewardValueType(rawValue: try container.decode(Int.self, forKey: .rewardValueType)) ?? .num
        self.rewardValue = try container.decode(Int.self, forKey: .rewardValue)
        self.rewardCount = try container.decode(Int.self, forKey: .rewardCount)
        self.isCollect = try container.decode(Bool.self, forKey: .isCollect) // 新增解码
        self.fatherId = try container.decode(String.self, forKey: .fatherId)
        self.childrenIds = try container.decode([String].self, forKey: .childrenId)
            
        self.fixTimeType = RewardFixTimeType(rawValue: try container.decode(Int.self, forKey: .fixTimeType)) ?? .everyday
        
        var fixedTimeIntervals = [LQDateInterval]()
        let fixedDates = try container.decode([[Date]].self, forKey: .fixTimes)
        fixedDates.forEach { pair in
            if let first = pair.first, let second = pair.last {
                fixedTimeIntervals.append(LQDateInterval(start: first, end: second))
            }
        }
        self.fixTimes = fixedTimeIntervals
        
        self.isArchive = try container.decode(Bool.self, forKey: .isArchive)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: RewardModelKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.createTime, forKey: .createTime)
        try container.encode(self.updateAt, forKey: .updateAt)
        try container.encode(self.generateId, forKey: .generateId)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.mark, forKey: .mark)
        try container.encode(self.tag, forKey: .tag)
        try container.encode(self.eventType.rawValue, forKey: .eventType)
        try container.encode(self.isFinish, forKey: .isFinish)
        try container.encode(self.intervals.compactMap({ [$0.start, $0.end]}), forKey: .intervals)
        try container.encode(self.rewardType.rawValue, forKey: .rewardType)
        try container.encode(self.rewardValueType.rawValue, forKey: .rewardValueType)
        try container.encode(self.rewardValue, forKey: .rewardValue)
        try container.encode(self.rewardCount, forKey: .rewardCount)
        try container.encode(self.fatherId, forKey: .fatherId)
        try container.encode(self.childrenIds, forKey: .childrenId)
        try container.encode(self.isCollect, forKey: .isCollect)
        
        try container.encode(self.fixTimeType.rawValue, forKey: .fixTimeType)
        try container.encode(self.fixTimes.compactMap { [$0.start, $0.end]}, forKey: .fixTimes)
        try container.encode(isArchive, forKey: .isArchive)
    }
    
    init(id: String, title: String, mark: String, tag: String, eventType: EventValueType, isFinish: Bool, createTime: Date? = nil, finishTime: Date? = nil, rewardType: RewardType, rewardValueType: RewardValueType = .time, rewardValue: Int = 0, rewardCount: Int = 0, intervals: [LQDateInterval] = []) {
        super.init()
        self.generateId = id
        self.title = title
        self.mark = mark
        self.tag = tag
        self.eventType = eventType
        self.isFinish = isFinish
        self.createTime = createTime
        self.finishTime = finishTime
        self.rewardType = rewardType
        self.rewardValueType = rewardValueType
        self.rewardValue = rewardValue
        self.rewardCount = rewardCount
        self.intervals = intervals
    }
    
    required init() {
        super.init()
    }
    
    
    override class func modelClassName() -> String {
        return "RewardModel"
    }
    
    override func modelClassName() -> String {
        return "RewardModel"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        title = cloudObj.get(RewardModelKeys.title.rawValue)?.stringValue ?? ""
        mark = cloudObj.get(RewardModelKeys.mark.rawValue)?.stringValue ?? ""
        if let tag = cloudObj.get(RewardModelKeys.tag.rawValue)?.stringValue {
            self.tag = tag
        }
        isFinish = cloudObj.get(RewardModelKeys.isFinish.rawValue)?.boolValue ?? false
        finishTime = cloudObj.get(RewardModelKeys.finishTime.rawValue)?.dateValue
        if let dates = cloudObj.get(RewardModelKeys.intervals.rawValue)?.arrayValue as? [Date] {
            var intervals: [LQDateInterval] = []
            for i in stride(from: 0, to: dates.count - 1, by: 2) {
                let interval = LQDateInterval(start: dates[i], end: dates[i+1])
                intervals.append(interval)
            }
            self.intervals = intervals
        }
        if let generateId = cloudObj.get(RewardModelKeys.generateId.rawValue)?.stringValue {
            self.generateId = generateId
        } else {
            self.generateId = id
        }
        self.rewardType = RewardType(rawValue: cloudObj.get(RewardModelKeys.rewardType.rawValue)?.intValue ?? 0) ?? .none
        self.rewardValueType = RewardValueType(rawValue: cloudObj.get(RewardModelKeys.rewardValueType.rawValue)?.intValue ?? 0) ?? .num
        self.rewardValue = cloudObj.get(RewardModelKeys.rewardValue.rawValue)?.intValue ?? 0
        self.eventType = EventValueType(rawValue: cloudObj.get(RewardModelKeys.eventType.rawValue)?.intValue ?? 0) ?? .num
        self.rewardCount = cloudObj.get(RewardModelKeys.rewardCount.rawValue)?.intValue ?? 0
        self.isCollect = cloudObj.get(RewardModelKeys.isCollect.rawValue)?.boolValue ?? false // 新增
        self.fatherId = cloudObj.get(RewardModelKeys.fatherId.rawValue)?.stringValue ?? ""
        self.childrenIds = cloudObj.get(RewardModelKeys.childrenId.rawValue)?.arrayValue as? [String] ?? []
        
        self.fixTimeType = RewardFixTimeType(rawValue: cloudObj.get(RewardModelKeys.fixTimeType.rawValue)?.intValue ?? 0) ?? .everyday
        if let dates = cloudObj.get(RewardModelKeys.fixTimes.rawValue)?.arrayValue as? [Date] {
            var intervals: [LQDateInterval] = []
            for i in stride(from: 0, to: dates.count - 1, by: 2) {
                let interval = LQDateInterval(start: dates[i], end: dates[i+1])
                intervals.append(interval)
            }
            self.fixTimes = intervals
        }
        self.isArchive = cloudObj.get(RewardModelKeys.isArchive.rawValue)?.boolValue ?? false
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(RewardModelKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(RewardModelKeys.mark.rawValue, value: mark.lcString)
        try cloudObj.set(RewardModelKeys.tag.rawValue, value: tag.lcString)
        try cloudObj.set(RewardModelKeys.isFinish.rawValue, value: isFinish.lcBool)
        if let finishTime = finishTime {
            try cloudObj.set(RewardModelKeys.finishTime.rawValue, value: finishTime.lcDate)
        }
        if intervals.count > 0 {
            var dates = [Date]()
            for interval in intervals {
                dates += [interval.start, interval.end]
            }
            try cloudObj.set(RewardModelKeys.intervals.rawValue, value: dates.lcArray)
        }
        try cloudObj.set(RewardModelKeys.generateId.rawValue, value: generateId.lcString)
        try cloudObj.set(RewardModelKeys.rewardType.rawValue, value: rewardType.rawValue.lcNumber)
        try cloudObj.set(RewardModelKeys.rewardValueType.rawValue, value: rewardValueType.rawValue.lcNumber)
        try cloudObj.set(RewardModelKeys.rewardValue.rawValue, value: rewardValue.lcNumber)
        try cloudObj.set(RewardModelKeys.eventType.rawValue, value: eventType.rawValue.lcNumber)
        try cloudObj.set(RewardModelKeys.rewardCount.rawValue, value: rewardCount.lcNumber)
        try cloudObj.set(RewardModelKeys.isCollect.rawValue, value: isCollect.lcBool) // 新增
        try cloudObj.set(RewardModelKeys.fatherId.rawValue, value: fatherId.stringValue)
        try cloudObj.set(RewardModelKeys.childrenId.rawValue, value: childrenIds.lcArray)
        
        try cloudObj.set(RewardModelKeys.fixTimeType.rawValue, value: fixTimeType.rawValue.lcNumber)
        if fixTimes.count > 0 {
            var dates = [Date]()
            for interval in fixTimes {
                dates += [interval.start, interval.end]
            }
            try cloudObj.set(RewardModelKeys.fixTimes.rawValue, value: dates.lcArray)
        }
        try cloudObj.set(RewardModelKeys.isArchive.rawValue, value: isArchive.lcBool)
    }
    
}

extension RewardModel: BasicTaskProtocol {
    
    func totalTime(with tabTab: TimeTab) -> Int {
        intervals.filter { dateInTimeTab($0.start, tab: tabTab)}
            .compactMap { $0.interval }
            .reduce(0, +)
    }
    
    var type: TaskType {
        .reward
    }
    
}

extension RewardModel {
    enum RewardModelKeys: String, CodingKey {
        case id
        case createTime
        case updateAt
        case title = "title"
        case mark = "mark"
        case tag = "tag"
        case importance = "importance"
        case isFinish = "isFinish"
        case finishTime = "finishTime"
        case planTime = "planTime"
        case finishState = "finishState"
        case finishText = "finishText"
        case finishRating = "finishRating"
        case difficultRating = "difficultRating"
        case difficultText = "difficultText"
        case isPlay = "isPlay"
        case intervals = "intervals"
        case generateId = "generateId"
        case rewardType
        case rewardValueType
        case rewardValue
        case fixedReward
        case eventType
        case playTime
        case rewardCount
        case isCollect
        case fatherId
        case childrenId
        
        case fixTimeType
        case fixTimes
        case isArchive
    }
}


extension RewardModel {
    
    var fixedTimeList: [RewardTimeItem] {
        return fixTimes.compactMap { RewardTimeItem(interval: $0, title: self.title, type: .fixedTime, id: self.id) }
            .sorted { $0.interval.start > $1.interval.start }
    }
    
    var isRootReward: Bool {
        fatherId.isEmpty
    }
    
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
    
    func totalTime(with tabTab: TimeTab, intervals: [LQDateInterval], selectDate: Date? = nil) -> Int {
        intervals.filter { dateInTimeTab($0.end, selectDate: selectDate, tab: tabTab)}
            .compactMap { $0.interval }
            .reduce(0, +)
    }
    
    func intervals(with tab: TimeTab, selectDate: Date? = nil) -> [LQDateInterval] {
        return intervals.filter { dateInTimeTab($0.end, selectDate: selectDate, tab: tab)}
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
                self.dateInTimeTab($0.end, tab: tabType)
            }
            let totalTime: Int = intervals.compactMap { $0.interval }.reduce(0, +) / 60
            return totalTime * rewardValue
        }
    }
    
    func totalSummaryScore(tabType: TimeTab, rewardList: [RewardModel], eventList: [EventItem]) -> Int {
        var score = 0
        score += summaryScore(with: tabType)
        score += eventList.filter { $0.rewardId == id && id.count > 0 }.compactMap { $0.summaryScore(with: tabType) }.reduce(0, +)
        rewardList.filter { $0.fatherId == id && id.count > 0 }.forEach { reward in
            score += reward.totalSummaryScore(tabType: tabType, rewardList: rewardList, eventList: eventList)
        }
        return score
    }
    
    func dateInTimeTab(_ date: Date, selectDate: Date? = nil, tab: TimeTab) -> Bool {
        if let selectDate {
            switch tab {
            case .day:
                return Date.isSameDay(date1: date, date2: selectDate)
            case .week:
                return Date.isSameWeek(date1: date, date2: selectDate)
            case .month:
                return Date.isSameMonth(date1: date, date2: selectDate)
            case .year:
                return date.isInSameYear(as: selectDate)
            case .all:
                return true
            }
        }
        
        switch tab {
        case .day:
            return date.isInToday
        case .week:
            return date.isInThisWeek
        case .month:
            return date.isInThisMonth
        case .year:
            return date.isInThisYear
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
    
    var rewardTimeList: [RewardTimeItem] {
        var items = [RewardTimeItem]()
        items += intervals.compactMap { RewardTimeItem(interval: $0, title: self.title, type: .interval, id: self.id)}
        return items.sorted { $0.interval.start > $1.interval.start }
    }
    
    func rewardTimeList(goalList: [RewardModel], eventList: [EventItem]) -> [RewardTimeItem] {
        var items = [RewardTimeItem]()
        items += intervals.compactMap { RewardTimeItem(interval: $0, title: self.title, type: .interval, id: self.id)}
        eventList.filter { $0.rewardId == self.id && id.count > 0 }.forEach { event in
            event.intervals.forEach { interval in
                items.append(RewardTimeItem(interval: interval, title: event.title, type: .task, id: event.id))
            }
        }
        goalList.filter { $0.fatherId == self.id }.forEach { reward in
            items += reward.rewardTimeList(goalList: goalList, eventList: eventList)
        }
        return items
    }
    
    func rewardTimeIntervals(rewardList: [RewardModel], eventList: [EventItem]) -> [LQDateInterval] {
        var intervals = [LQDateInterval]()
        intervals += self.intervals
        intervals += eventList.filter { $0.rewardId == self.id && id.count > 0 }.compactMap { $0.intervals }.joined()
        let filteredRewardList =  rewardList.filter { $0.fatherId == self.id && self.id.count > 0 }
        filteredRewardList.forEach { reward in
            intervals += reward.rewardTimeIntervals(rewardList: rewardList, eventList: eventList)
        }
        return intervals.sorted { $0.end.timeIntervalSince1970 >= $1.end.timeIntervalSince1970 }
    }
    
    func newestTimeInterval(rewardList: [RewardModel], eventList: [EventItem]) -> LQDateInterval? {
        return rewardTimeIntervals(rewardList: rewardList, eventList: eventList).first
    }
    
}


enum RewardTimeType {
    case interval
    case task
    case fixedTime
}

struct RewardTimeItem {
    var interval: LQDateInterval
    var title: String
    var type: RewardTimeType
    var id: String
    
    init(interval: LQDateInterval, title: String, type: RewardTimeType, id: String) {
        self.interval = interval
        self.title = title
        self.type = type
        self.id = id
    }
}
