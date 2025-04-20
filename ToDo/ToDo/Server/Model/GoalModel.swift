//
//  GoalModel.swift
//  JustDo
//
//  Created by ByteDance on 2024/1/1.
//

import Foundation
import LeanCloud

class GoalModel: BaseModel, Identifiable {
    
    var title: String = ""
    var tag: String = "work"
    var deadline: Date?
    var mark: String = ""
    
    required init() {
        
    }
    
    init(title: String) {
        self.title = title
        super.init()
    }
    
    override class func modelClassName() -> String {
        return "GoalModel"
    }
    
    override func modelClassName() -> String {
        return "GoalModel"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        title = cloudObj.get(GoalModelKeys.title.rawValue)?.stringValue ?? ""
        mark = cloudObj.get(GoalModelKeys.mark.rawValue)?.stringValue ?? ""
        if let tag = cloudObj.get(GoalModelKeys.tag.rawValue)?.stringValue {
            self.tag = tag
        }
        if let deadline = cloudObj.get(GoalModelKeys.deadline.rawValue)?.dateValue {
            self.deadline = deadline
        }
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(GoalModelKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(GoalModelKeys.mark.rawValue, value: mark.lcString)
        try cloudObj.set(GoalModelKeys.tag.rawValue, value: tag)
        if let deadline = self.deadline {
            try cloudObj.set(GoalModelKeys.deadline.rawValue, value: deadline.lcDate)
        }
    }
    
}

extension GoalModel {
    
    enum GoalModelKeys: String {
        case title
        case tag
        case deadline
        case mark
    }
    
}
