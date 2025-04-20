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
    
    required init() {
        
    }
    
    override class func modelClassName() -> String {
        return "SummaryTag"
    }
    
    override func modelClassName() -> String {
        return "SummaryTag"
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
    
    enum SummaryTagKeys: String {
        case generateId
        case content
        case hexColor
    }
    
    var titleColor: Color {
        return hexColor.count > 0 ? Color.init(hex: hexColor) : .green
    }
    
}
