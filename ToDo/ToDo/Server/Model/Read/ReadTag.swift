//
//  ReadTag.swift
//  ReadList
//
//  Created by ByteDance on 2024/1/6.
//

import Foundation
import LeanCloud

class ReadTag: BaseModel, Identifiable {
    
    public static let createTag = ReadTag(type: "创建")
    
    var type: String = ""
    
    init(type: String) {
        self.type = type
        super.init()
    }
        
    override class func modelClassName() -> String {
        return "ReadTag"
    }
    
    override func modelClassName() -> String {
        return "ReadTag"
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ReadTagKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
    }
    
    required init() {
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ReadTagKeys.self)
        try container.encode(type, forKey: .type)
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        if let type = cloudObj.get(ReadTagKeys.type.rawValue)?.stringValue {
            self.type = type
        }
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(ReadTagKeys.type.rawValue, value: type.lcString)
    }
    
}

extension ReadTag {
    enum ReadTagKeys: String, CodingKey {
        case type
    }
    
    var isCreateType: Bool {
        return type == Self.createTag.type
    }
}
