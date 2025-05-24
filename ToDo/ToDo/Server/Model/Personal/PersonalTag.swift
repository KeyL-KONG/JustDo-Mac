//
//  PersonalTag.swift
//  ToDo
//
//  Created by LQ on 2025/5/24.
//

import Foundation
import LeanCloud

class PersonalTag: BaseModel, Identifiable, Codable {
    var tag: String = ""
    var goodEvents: [String: Int] = [:]
    var badEvents: [String: Int] = [:]
    
    init(tag: String) {
        self.tag = tag
        super.init()
    }
    
    required init() {
        super.init()
    }
    
    override class func modelClassName() -> String {
        return "PersonalTag"
    }
    
    override func modelClassName() -> String {
        return "PersonalTag"
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: PersonalTagKeys.self)
        tag = try container.decodeIfPresent(String.self, forKey: .tag) ?? ""
        goodEvents = try container.decodeIfPresent([String: Int].self, forKey: .goodEvents) ?? [:]
        badEvents = try container.decodeIfPresent([String: Int].self, forKey: .badEvents) ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PersonalTagKeys.self)
        try container.encode(tag, forKey: .tag)
        try container.encode(goodEvents, forKey: .goodEvents)
        try container.encode(badEvents, forKey: .badEvents)
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        if let tag = cloudObj.get(PersonalTagKeys.tag.rawValue)?.stringValue {
            self.tag = tag
        }
        if let goodEventStr = cloudObj.get(PersonalTagKeys.goodEvents.rawValue)?.dictionaryValue as? String, let goodEvents = goodEventStr.toJson() as? [String: Int] {
            self.goodEvents = goodEvents
        }
        if let badEventStr = cloudObj.get(PersonalTagKeys.badEvents.rawValue)?.dictionaryValue as? String, let badEvents = badEventStr.toJson() as? [String: Int] {
            self.badEvents = badEvents
        }
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(PersonalTagKeys.tag.rawValue, value: tag.lcString)
        if let goodEventJson = goodEvents.toJsonString() {
            try cloudObj.set(PersonalTagKeys.goodEvents.rawValue, value: goodEventJson)
        }
        if let badEventJson = badEvents.toJsonString() {
            try cloudObj.set(PersonalTagKeys.badEvents.rawValue, value: badEventJson)
        }
    }
}

extension PersonalTag {
    enum PersonalTagKeys: String, CodingKey {
        case tag
        case goodEvents
        case badEvents
    }
}
