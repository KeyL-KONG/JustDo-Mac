//
//  PrincipleModel.swift
//  ToDo
//
//  Created by LQ on 2025/4/13.
//

import Foundation
import LeanCloud

class PrincipleModel: BaseModel, Identifiable {
    var tag: String = ""
    var content: String = ""
    var taskIds: [String] = []
    
    enum PrincipleKeys: String {
        case tag
        case content
        case taskIds
    }
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tag = try container.decode(String.self, forKey: .tag)
        taskIds = try container.decode([String].self, forKey: .taskIds)
        content = try container.decode(String.self, forKey: .content)
    }
    
    init(content: String) {
        super.init()
        self.content = content
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tag, forKey: .tag)
        try container.encode(taskIds, forKey: .taskIds)
        try container.encode(content, forKey: .content)
    }
    
    override class func modelClassName() -> String {
        return "PrincipleModel"
    }
    
    override func modelClassName() -> String {
        return "PrincipleModel"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        tag = cloudObj.get(PrincipleKeys.tag.rawValue)?.stringValue ?? ""
        taskIds = cloudObj.get(PrincipleKeys.taskIds.rawValue)?.arrayValue as? [String] ?? []
        content = cloudObj.get(PrincipleKeys.content.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(PrincipleKeys.tag.rawValue, value: tag.lcString)
        try cloudObj.set(PrincipleKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(PrincipleKeys.taskIds.rawValue, value: taskIds.lcArray)
    }
    
    private enum CodingKeys: String, CodingKey {
        case tag
        case content
        case taskIds
    }
    

}
