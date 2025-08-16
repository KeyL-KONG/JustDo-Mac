//
//  PersonalTag.swift
//  ToDo
//
//  Created by LQ on 2025/5/24.
//

import Foundation
import LeanCloud
import SwiftUI


enum PersonalTagType {
    case good
    case bad
    
    var title: String {
        switch self {
        case .good:
            return "正向"
        case .bad:
            return "负向"
        }
    }
    
    var nums: [Int] {
        switch self {
        case .good:
            return [1, 3, 5]
        case .bad:
            return [-1, -3, -5]
        }
    }
    
    static func type(with title: String) -> PersonalTagType {
        if title == PersonalTagType.bad.title {
            return .bad
        }
        return .good
    }
    
    static let titles = [PersonalTagType.good.title, PersonalTagType.bad.title]
}

enum PersonalTagNumType {
    case normal
    case more
    case excellent
}

class PersonalTag: BaseModel, Identifiable {
    var tag: String = ""
    var goodEvents: [String: Int] = [:]
    var badEvents: [String: Int] = [:]
    var goodColorHex: String = "4CAF50" // 新增默认绿色
    var badColorHex: String = "F44336" // 新增默认红色
    
    var goodColor: Color {
        Color.init(hex: goodColorHex)
    }
    
    var badColor: Color {
        Color.init(hex: badColorHex)
    }
    
    init(tag: String, goodColorHex: String = "#4CAF50", badColorHex: String = "#F44336") {
        self.tag = tag
        self.goodColorHex = goodColorHex
        self.badColorHex = badColorHex
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
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: PersonalTagKeys.self)
        tag = try container.decodeIfPresent(String.self, forKey: .tag) ?? ""
        goodEvents = try container.decodeIfPresent([String: Int].self, forKey: .goodEvents) ?? [:]
        badEvents = try container.decodeIfPresent([String: Int].self, forKey: .badEvents) ?? [:]
        goodColorHex = try container.decodeIfPresent(String.self, forKey: .goodColorHex) ?? "#4CAF50"
        badColorHex = try container.decodeIfPresent(String.self, forKey: .badColorHex) ?? "#F44336"
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: PersonalTagKeys.self)
        try container.encode(tag, forKey: .tag)
        try container.encode(goodEvents, forKey: .goodEvents)
        try container.encode(badEvents, forKey: .badEvents)
        try container.encode(goodColorHex, forKey: .goodColorHex)
        try container.encode(badColorHex, forKey: .badColorHex)
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        if let tag = cloudObj.get(PersonalTagKeys.tag.rawValue)?.stringValue {
            self.tag = tag
        }
        if let goodEventStr = cloudObj.get(PersonalTagKeys.goodEvents.rawValue)?.stringValue, let goodEvents = goodEventStr.toJson() as? [String: Int] {
            self.goodEvents = goodEvents
        }
        if let badEventStr = cloudObj.get(PersonalTagKeys.badEvents.rawValue)?.stringValue, let badEvents = badEventStr.toJson() as? [String: Int] {
            self.badEvents = badEvents
        }
        if let goodColor = cloudObj.get(PersonalTagKeys.goodColorHex.rawValue)?.stringValue {
            self.goodColorHex = goodColor
        }
        if let badColor = cloudObj.get(PersonalTagKeys.badColorHex.rawValue)?.stringValue {
            self.badColorHex = badColor
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
        try cloudObj.set(PersonalTagKeys.goodColorHex.rawValue, value: goodColorHex.lcString)
        try cloudObj.set(PersonalTagKeys.badColorHex.rawValue, value: badColorHex.lcString)
    }
}

extension PersonalTag {
    enum PersonalTagKeys: String, CodingKey {
        case tag
        case goodEvents
        case badEvents
        case goodColorHex // 新增
        case badColorHex  // 新增
    }
}
