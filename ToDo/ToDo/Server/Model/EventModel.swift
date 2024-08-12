//
//  EventModel.swift
//  JustDo
//
//  Created by ByteDance on 2023/7/16.
//

import Foundation
import LeanCloud

struct LQDateInterval: Identifiable, Equatable {
    var id: String {
        return "\(start.timeIntervalSince1970)-\(end.timeIntervalSince1970)"
    }
    
    var start: Date
    var end: Date
    
    static func == (lhs: LQDateInterval, rhs: LQDateInterval) -> Bool {
        return lhs.id == rhs.id
    }
}

extension LQDateInterval {
    var interval: Int {
        return Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
    }
}

class EventModel: BaseModel, Identifiable, Encodable, Decodable {
    
    var generateId: String = UUID().uuidString
    var title: String = ""
    var mark: String = ""
    var tag: String = ""
    var importance: ImportanceTag = .mid
    var eventType: EventValueType = .num
    var isFinish: Bool = false
    var finishTime: Date? = nil
    var planTime: Date? = nil
    var isPlay: Bool = false
    var playTime: Date? = nil
    var intervals: [LQDateInterval] = []
    var rewardType: RewardType = .none
    var rewardValueType: RewardValueType = .num
    var rewardValue: Int = 0
    var rewardCount: Int = 0
    var fixedReward: Bool = false
    var rewardId: String = ""
    
    // 废弃字段
    var finishState: FinishState = .normal
    var finishRating: Int = 3
    var difficultRating: Int = 3
    var finishText: String = ""
    var difficultText: String = ""

    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: EventModelKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createTime = try container.decode(Date.self, forKey: .createTime)
        self.updateAt = try container.decode(Date.self, forKey: .updateAt)
        self.generateId = try container.decode(String.self, forKey: .generateId)
        self.title = try container.decode(String.self, forKey: .title)
        self.mark = try container.decode(String.self, forKey: .mark)
        self.importance = ImportanceTag(rawValue: try container.decode(String.self, forKey: .importance)) ?? .mid
        self.finishTime = try container.decodeIfPresent(Date.self, forKey: .finishTime)
        self.playTime = try container.decodeIfPresent(Date.self, forKey: .playTime)
        self.planTime = try container.decodeIfPresent(Date.self, forKey: .planTime)
        
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
        self.fixedReward = try container.decode(Bool.self, forKey: .fixedReward)
        self.rewardId = try container.decode(String.self, forKey: .rewardId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EventModelKeys.self)
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
        try container.encode(self.importance, forKey: .importance)
        try container.encode(self.fixedReward, forKey: .fixedReward)
        try container.encode(self.rewardId, forKey: .rewardId)
        if let finishTime {
            try container.encode(finishTime, forKey: .finishTime)
        }
        if let planTime {
            try container.encode(planTime, forKey: .planTime)
        }
        if let playTime {
            try container.encode(playTime, forKey: .playTime)
        }
    }
    
    init(id: String, title: String, mark: String, tag: String, isFinish: Bool, importance: ImportanceTag, finishState: FinishState = .normal, finishText: String = "", finishRating: Int = 3, difficultRating: Int = 3, difficultText: String = "", createTime: Date? = nil, planTime: Date? = nil, finishTime: Date? = nil, rewardType: RewardType = .none, rewardValue: Int = 0, fixedReward: Bool = false) {
        super.init()
        self.generateId = id
        self.title = title
        self.mark = mark
        self.tag = tag
        self.isFinish = isFinish
        self.importance = importance
        self.finishState = finishState
        self.finishText = finishText
        self.createTime = createTime
        self.planTime = planTime
        self.finishTime = finishTime
        self.finishRating = finishRating
        self.difficultRating = difficultRating
        self.rewardType = rewardType
        self.rewardValue = rewardValue
        self.fixedReward = fixedReward
    }
    
    override class func modelClassName() -> String {
        return "EventItem"
    }
    
    override func modelClassName() -> String {
        return "EventItem"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        title = cloudObj.get(EventModelKeys.title.rawValue)?.stringValue ?? ""
        mark = cloudObj.get(EventModelKeys.mark.rawValue)?.stringValue ?? ""
        finishRating = cloudObj.get(EventModelKeys.finishRating.rawValue)?.intValue ?? 0
        difficultRating = cloudObj.get(EventModelKeys.difficultRating.rawValue)?.intValue ?? 0
        if let tag = cloudObj.get(EventModelKeys.tag.rawValue)?.stringValue {
            self.tag = tag
        }
        if let importance = cloudObj.get(EventModelKeys.importance.rawValue)?.stringValue {
            self.importance = ImportanceTag(rawValue: importance) ?? .mid
        } else {
            self.importance = .mid
        }
        if let finishState = cloudObj.get(EventModelKeys.finishState.rawValue)?.stringValue {
            self.finishState = FinishState(rawValue: finishState) ?? .normal
        } else {
            self.finishState = .normal
        }
        finishText = cloudObj.get(EventModelKeys.finishText.rawValue)?.stringValue ?? ""
        isFinish = cloudObj.get(EventModelKeys.isFinish.rawValue)?.boolValue ?? false
        finishTime = cloudObj.get(EventModelKeys.finishTime.rawValue)?.dateValue
        planTime = cloudObj.get(EventModelKeys.planTime.rawValue)?.dateValue
        difficultText = cloudObj.get(EventModelKeys.difficultText.rawValue)?.stringValue ?? ""
        isPlay = cloudObj.get(EventModelKeys.isPlay.rawValue)?.boolValue ?? false
        if let dates = cloudObj.get(EventModelKeys.intervals.rawValue)?.arrayValue as? [Date] {
            var intervals: [LQDateInterval] = []
            for i in stride(from: 0, to: dates.count - 1, by: 2) {
                let interval = LQDateInterval(start: dates[i], end: dates[i+1])
                intervals.append(interval)
            }
            self.intervals = intervals
        }
        if let generateId = cloudObj.get(EventModelKeys.generateId.rawValue)?.stringValue {
            self.generateId = generateId
        } else {
            self.generateId = id
        }
        self.rewardType = RewardType(rawValue: cloudObj.get(EventModelKeys.rewardType.rawValue)?.intValue ?? 0) ?? .none
        self.rewardValueType = RewardValueType(rawValue: cloudObj.get(EventModelKeys.rewardValueType.rawValue)?.intValue ?? 0) ?? .num
        self.rewardValue = cloudObj.get(EventModelKeys.rewardValue.rawValue)?.intValue ?? 0
        self.fixedReward = cloudObj.get(EventModelKeys.fixedReward.rawValue)?.boolValue ?? false
        self.eventType = EventValueType(rawValue: cloudObj.get(EventModelKeys.eventType.rawValue)?.intValue ?? 0) ?? .num
        if let playTime = cloudObj.get(EventModelKeys.playTime.rawValue)?.dateValue {
            self.playTime = playTime
        }
        self.rewardCount = cloudObj.get(EventModelKeys.rewardCount.rawValue)?.intValue ?? 0
        self.rewardId = cloudObj.get(EventModelKeys.rewardId.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(EventModelKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(EventModelKeys.mark.rawValue, value: mark.lcString)
        try cloudObj.set(EventModelKeys.tag.rawValue, value: tag.lcString)
        try cloudObj.set(EventModelKeys.importance.rawValue, value: importance.rawValue.lcString)
        try cloudObj.set(EventModelKeys.finishState.rawValue, value: finishState.rawValue.lcString)
        try cloudObj.set(EventModelKeys.finishText.rawValue, value: finishText.lcString)
        try cloudObj.set(EventModelKeys.isFinish.rawValue, value: isFinish.lcBool)
        if let finishTime = finishTime {
            try cloudObj.set(EventModelKeys.finishTime.rawValue, value: finishTime.lcDate)
        }
        if let planTime = planTime {
            try cloudObj.set(EventModelKeys.planTime.rawValue, value: planTime.lcDate)
        }
        try cloudObj.set(EventModelKeys.finishRating.rawValue, value: finishRating.lcNumber)
        try cloudObj.set(EventModelKeys.difficultRating.rawValue, value: difficultRating.lcNumber)
        try cloudObj.set(EventModelKeys.difficultText.rawValue, value: difficultText.lcString)
        try cloudObj.set(EventModelKeys.isPlay.rawValue, value: isPlay.lcBool)
        if intervals.count > 0 {
            var dates = [Date]()
            for interval in intervals {
                dates += [interval.start, interval.end]
            }
            try cloudObj.set(EventModelKeys.intervals.rawValue, value: dates.lcArray)
        }
        try cloudObj.set(EventModelKeys.generateId.rawValue, value: generateId.lcString)
        try cloudObj.set(EventModelKeys.rewardType.rawValue, value: rewardType.rawValue.lcNumber)
        try cloudObj.set(EventModelKeys.rewardValueType.rawValue, value: rewardValueType.rawValue.lcNumber)
        try cloudObj.set(EventModelKeys.rewardValue.rawValue, value: rewardValue.lcNumber)
        try cloudObj.set(EventModelKeys.fixedReward.rawValue, value: fixedReward.lcBool)
        try cloudObj.set(EventModelKeys.eventType.rawValue, value: eventType.rawValue.lcNumber)
        if let playTime = self.playTime {
            try cloudObj.set(EventModelKeys.playTime.rawValue, value: playTime.lcDate)
        }
        try cloudObj.set(EventModelKeys.rewardCount.rawValue, value: rewardCount.lcNumber)
        try cloudObj.set(EventModelKeys.rewardId.rawValue, value: rewardId.lcString)
    }
    
}

extension EventModel: BasicTaskProtocol {
    
    var type: TaskType {
        .task
    }
}

extension EventModel {
    
    enum EventModelKeys: String, CodingKey {
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
        case rewardId
    }
    
}