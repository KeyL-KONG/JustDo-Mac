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
    var projectId: String = ""
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: TagModelKeys.self)
        content = try container.decode(String.self, forKey: .content)
        projectId = try container.decode(String.self, forKey: .projectId)
    }
    
    init(content: String) {
        super.init()
        self.content = content
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TagModelKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(projectId, forKey: .projectId)
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
        projectId = cloudObj.get(TagModelKeys.projectId.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(TagModelKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(TagModelKeys.projectId.rawValue, value: projectId.lcString)
    }
    
}

extension TagModel {
    
    enum TagModelKeys: String, CodingKey {
        case content = "content"
        case projectId
    }
    
}
