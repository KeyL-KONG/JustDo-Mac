//
//  SummaryTag.swift
//  Summary
//
//  Created by LQ on 2024/7/21.
//

import SwiftUI
import LeanCloud

class SummaryTag: BaseModel, Identifiable {
    var generateId: String = ""
    var content: String = ""
    var hexColor: String = ""

    
    override class func modelClassName() -> String {
        return "SummaryTag"
    }
    
    override func modelClassName() -> String {
        return "SummaryTag"
    }
    
    required init(from decoder: any Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: SummaryTagKeys.self)
        self.generateId = try container.decodeIfPresent(String.self, forKey: .generateId) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.hexColor = try container.decodeIfPresent(String.self, forKey: .hexColor) ?? ""
    }
    
    init(content: String = "") {
        super.init()
        self.content = content
    }
    
    required init() {
        super.init()
    }
    
    override func encode(to encoder: any Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: SummaryTagKeys.self)
        try container.encode(self.generateId, forKey: .generateId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.hexColor, forKey: .hexColor)
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        self.generateId = cloudObj.get(SummaryTagKeys.generateId.rawValue)?.stringValue ?? ""
        self.content = cloudObj.get(SummaryTagKeys.content.rawValue)?.stringValue ?? ""
        self.hexColor = cloudObj.get(SummaryTagKeys.hexColor.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(SummaryTagKeys.generateId.rawValue, value: generateId)
        try cloudObj.set(SummaryTagKeys.content.rawValue, value: content)
        try cloudObj.set(SummaryTagKeys.hexColor.rawValue, value: hexColor)
    }
    
    enum SummaryTagKeys: String, CodingKey {
        case generateId
        case content
        case hexColor
    }
    
    var titleColor: Color {
        return hexColor.count > 0 ? Color.init(hex: hexColor) : .green
    }
    
}
