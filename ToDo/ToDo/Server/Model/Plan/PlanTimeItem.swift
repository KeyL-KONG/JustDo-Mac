//
//  PlanTimeItem.swift
//  ToDo
//
//  Created by LQ on 2025/5/17.
//

import Foundation
import LeanCloud

class PlanTimeItem: BaseModel, Identifiable {
    var startTime: Date = .now
    var endTime: Date = .now
    var content: String = ""
    var tagId: String = ""
    var eventIds: [String] = []
    var timeInterval: Int = 0
    var totalInterval: Int = 0
    var timeType: String = ""
    
    var timeTab: TimeTab {
        return TimeTab(rawValue: timeType) ?? .week
    }
    
    var percentValue: CGFloat {
        guard timeInterval > 0, totalInterval > 0 else {
            return 0.0
        }
        return CGFloat(totalInterval) / CGFloat(timeInterval)
    }
    
    enum PlanTimeItemKeys: String {
        case startTime
        case endTime
        case content
        case eventIds
        case tagId
        case timeInterval
        case totalInterval
        case timeType
    }
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        content = try container.decode(String.self, forKey: .content)
        eventIds = try container.decode([String].self, forKey: .eventIds)
        tagId = try container.decodeIfPresent(String.self, forKey: .tagId) ?? ""
        timeInterval = try container.decodeIfPresent(Int.self, forKey: .timeInterval) ?? 0
        totalInterval = try container.decodeIfPresent(Int.self, forKey: .totalInterval) ?? 0
        timeType = try container.decodeIfPresent(String.self, forKey: .timeType) ?? ""
    }
    
    init(startTime: Date, endTime: Date, content: String) {
        super.init()
        self.startTime = startTime
        self.endTime = endTime
        self.content = content
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(content, forKey: .content)
        try container.encode(eventIds, forKey: .eventIds)
        try container.encode(tagId, forKey: .tagId)
        try container.encode(timeInterval, forKey: .timeInterval)
        try container.encode(totalInterval, forKey: .totalInterval)
        try container.encode(timeType, forKey: .timeType)
    }
    
    override class func modelClassName() -> String {
        return "PlanTimeItem"
    }
    
    override func modelClassName() -> String {
        return "PlanTimeItem"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        startTime = cloudObj.get(PlanTimeItemKeys.startTime.rawValue)?.dateValue ?? Date()
        endTime = cloudObj.get(PlanTimeItemKeys.endTime.rawValue)?.dateValue ?? Date()
        content = cloudObj.get(PlanTimeItemKeys.content.rawValue)?.stringValue ?? ""
        eventIds = cloudObj.get(PlanTimeItemKeys.eventIds.rawValue)?.arrayValue as? [String] ?? []
        tagId = cloudObj.get(PlanTimeItemKeys.tagId.rawValue)?.stringValue ?? ""
        timeInterval = cloudObj.get(PlanTimeItemKeys.timeInterval.rawValue)?.intValue ?? 0
        totalInterval = cloudObj.get(PlanTimeItemKeys.totalInterval.rawValue)?.intValue ?? 0
        timeType = cloudObj.get(PlanTimeItemKeys.timeType.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(PlanTimeItemKeys.startTime.rawValue, value: startTime.lcDate)
        try cloudObj.set(PlanTimeItemKeys.endTime.rawValue, value: endTime.lcDate)
        try cloudObj.set(PlanTimeItemKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(PlanTimeItemKeys.eventIds.rawValue, value: eventIds.lcArray)
        try cloudObj.set(PlanTimeItemKeys.tagId.rawValue, value: tagId.lcString)
        try cloudObj.set(PlanTimeItemKeys.timeInterval.rawValue, value: timeInterval.lcNumber)
        try cloudObj.set(PlanTimeItemKeys.totalInterval.rawValue, value: totalInterval.lcNumber)
        try cloudObj.set(PlanTimeItemKeys.timeType.rawValue, value: timeType.lcString)
    }
    
    private enum CodingKeys: String, CodingKey {
        case startTime, endTime, content, eventIds, tagId,timeInterval, totalInterval, timeType
    }
    
}
