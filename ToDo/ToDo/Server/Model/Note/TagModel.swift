//
//  TagModel.swift
//  Note
//
//  Created by ByteDance on 2023/8/25.
//

import Foundation
import LeanCloud

class TagModel: BaseModel, Identifiable {
    
    var content: String = ""
    
    required init() {
        
    }
    
    override class func modelClassName() -> String {
        return "TagModel"
    }
    
    override func modelClassName() -> String {
        return "TagModel"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        content = cloudObj.get(TagModelKeys.content.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(TagModelKeys.content.rawValue, value: content.lcString)
    }
    
}

extension TagModel {
    
    enum TagModelKeys: String {
        case content = "content"
    }
    
}
