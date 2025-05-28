//
//  TagModel.swift
//  Note
//
//  Created by ByteDance on 2023/8/25.
//

import Foundation
import LeanCloud

class TagModel: BaseModel, Identifiable, Codable {
    
    var content: String = ""
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: TagModelKeys.self)
        content = try container.decode(String.self, forKey: .content)
    }
    
    init(content: String) {
        super.init()
        self.content = content
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TagModelKeys.self)
        try container.encode(content, forKey: .content)
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
    
    enum TagModelKeys: String, CodingKey {
        case content = "content"
    }
    
}
