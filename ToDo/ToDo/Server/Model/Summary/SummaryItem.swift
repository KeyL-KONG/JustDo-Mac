//
//  SummaryItem.swift
//  Summary
//
//  Created by LQ on 2024/5/5.
//

import Foundation
import LeanCloud

class SummaryItem: BaseModel, Identifiable {
    var generateId: String = ""
    var summaryId: String = ""
    var content: String = ""
    var improve: String = ""
    var tags: [String] = []
    
    init(generateId: String, summaryId: String, content: String, improve: String) {
        self.generateId = generateId
        self.summaryId = summaryId
        self.content = content
        self.improve = improve
    }
    
    required init() {
    }
    
    override class func modelClassName() -> String {
        return "SummaryItem"
    }
    
    override func modelClassName() -> String {
        return "SummaryItem"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        self.generateId = cloudObj.get(SummaryItemKeys.generateId.rawValue)?.stringValue ?? ""
        self.summaryId = cloudObj.get(SummaryItemKeys.summaryId.rawValue)?.stringValue ?? ""
        self.content = cloudObj.get(SummaryItemKeys.content.rawValue)?.stringValue ?? ""
        self.improve = cloudObj.get(SummaryItemKeys.improve.rawValue)?.stringValue ?? ""
        self.tags = cloudObj.get(SummaryItemKeys.tags.rawValue)?.arrayValue as? [String] ?? []
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(SummaryItemKeys.generateId.rawValue, value: generateId.lcString)
        try cloudObj.set(SummaryItemKeys.summaryId.rawValue, value: summaryId.lcString)
        try cloudObj.set(SummaryItemKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(SummaryItemKeys.improve.rawValue, value: improve.lcString)
        try cloudObj.set(SummaryItemKeys.tags.rawValue, value: tags.lcArray)
    }
    
    enum SummaryItemKeys: String {
        case generateId
        case summaryId
        case content
        case improve
        case tags
    }
    
}

enum SummaryTaskType: String, Identifiable {
    var id: String {
        return self.rawValue
    }
    
    case event
    case reward
    
    var typeTitle: String {
        switch self {
        case .event:
            return "任务"
        case .reward:
            return "积分"
        }
    }
    
    static let taskTypes: [SummaryTaskType] = [.reward, .event]
}

enum SummaryReviewType: Int {
    case verybad = 1
    case bad
    case normal
    case good
    case verygood
    
    static var titles: [String] {
        return ["vary bad", "bad", "normal", "good", "very good"]
    }
}

enum SummaryMoodType: Int {
    case verybad = 1
    case bad
    case normal
    case good
    case verygood
    
    static var titles: [String] {
        return ["vary bad", "bad", "normal", "good", "very good"]
    }
}

enum SummaryBodyType: Int {
    case verybad = 1
    case bad
    case normal
    case good
    case verygood
    
    static var titles: [String] {
        return ["vary bad", "bad", "normal", "good", "very good"]
    }
}

enum SummaryEffectType: Int {
    case verybad = 1
    case bad
    case normal
    case good
    case verygood
    
    static var titles: [String] {
        return ["vary bad", "bad", "normal", "good", "very good"]
    }
}

enum SummaryCheckType: Int {
    case review
    case mood
    case body
    case effect
}

class SummaryModel: BaseModel, Identifiable {
    
    var generateId: String = ""
    var taskId: String = ""
    var taskType: SummaryTaskType = .event
    var items: [String] = []
    var summaryDate: Date = .now
    var content: String = ""
    var timeTab: TimeTab = .day
    
    var reviewType: SummaryReviewType = .normal
    var moodType: SummaryMoodType = .normal
    var bodyType: SummaryBodyType = .normal
    var effectType: SummaryEffectType = .normal
    
    var reviewText: String = ""
    var moodeText: String = ""
    var bodyText: String = ""
    var effectText: String = ""
    
    init(generateId: String, taskId: String, taskType: SummaryTaskType, items: [String], summaryDate: Date = .now) {
        self.generateId = generateId
        self.taskId = taskId
        self.taskType = taskType
        self.items = items
        self.summaryDate = summaryDate
    }
    
    required init() {
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        generateId = cloudObj.get(SummaryModelKeys.generateId.rawValue)?.stringValue ?? ""
        taskId = cloudObj.get(SummaryModelKeys.taskId.rawValue)?.stringValue ?? ""
        taskType = SummaryTaskType(rawValue: cloudObj.get(SummaryModelKeys.taskType.rawValue)?.stringValue ?? "") ?? .event
        items = cloudObj.get(SummaryModelKeys.items.rawValue)?.arrayValue as? [String] ?? []
        summaryDate = cloudObj.get(SummaryModelKeys.summaryDate.rawValue)?.dateValue ?? .now
        content = cloudObj.get(SummaryModelKeys.content.rawValue)?.stringValue ?? ""
        // TODO
        //timeTab = TimeTab(rawValue: cloudObj.get(SummaryModelKeys.timeTab.rawValue)?.stringValue ?? "") ?? .day
        reviewType = SummaryReviewType(rawValue: cloudObj.get(SummaryModelKeys.reviewType.rawValue)?.intValue ?? 2) ?? .normal
        moodType = SummaryMoodType(rawValue: cloudObj.get(SummaryModelKeys.moodType.rawValue)?.intValue ?? 2) ?? .normal
        bodyType = SummaryBodyType(rawValue: cloudObj.get(SummaryModelKeys.bodyType.rawValue)?.intValue ?? 2) ?? .normal
        effectType = SummaryEffectType(rawValue: cloudObj.get(SummaryModelKeys.effectType.rawValue)?.intValue ?? 2) ?? .normal
        reviewText = cloudObj.get(SummaryModelKeys.reviewText.rawValue)?.stringValue ?? ""
        moodeText = cloudObj.get(SummaryModelKeys.moodText.rawValue)?.stringValue ?? ""
        bodyText = cloudObj.get(SummaryModelKeys.bodyText.rawValue)?.stringValue ?? ""
        effectText = cloudObj.get(SummaryModelKeys.effectText.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(SummaryModelKeys.generateId.rawValue, value: generateId.lcString)
        try cloudObj.set(SummaryModelKeys.taskId.rawValue, value: taskId.lcString)
        try cloudObj.set(SummaryModelKeys.taskType.rawValue, value: taskType.rawValue.lcString)
        try cloudObj.set(SummaryModelKeys.items.rawValue, value: items.lcArray)
        try cloudObj.set(SummaryModelKeys.summaryDate.rawValue, value: summaryDate.lcDate)
        try cloudObj.set(SummaryModelKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(SummaryModelKeys.timeTab.rawValue, value: timeTab.rawValue)
        try cloudObj.set(SummaryModelKeys.reviewType.rawValue, value: reviewType.rawValue)
        try cloudObj.set(SummaryModelKeys.moodType.rawValue, value: moodType.rawValue)
        try cloudObj.set(SummaryModelKeys.bodyType.rawValue, value: bodyType.rawValue)
        try cloudObj.set(SummaryModelKeys.effectType.rawValue, value: effectType.rawValue)
        try cloudObj.set(SummaryModelKeys.reviewText.rawValue, value: reviewText.lcString)
        try cloudObj.set(SummaryModelKeys.moodText.rawValue, value: moodeText.lcString)
        try cloudObj.set(SummaryModelKeys.bodyText.rawValue, value: bodyText.lcString)
        try cloudObj.set(SummaryModelKeys.effectText.rawValue, value: effectText.lcString)
    }
    
    override class func modelClassName() -> String {
        return "SummaryModel"
    }
    
    override func modelClassName() -> String {
        return "SummaryModel"
    }
    
    enum SummaryModelKeys: String {
        case generateId
        case taskId
        case taskType
        case items
        case summaryDate
        case content
        case timeTab
        case reviewType
        case moodType
        case bodyType
        case effectType
        case reviewText
        case moodText
        case bodyText
        case effectText
    }
    
}
