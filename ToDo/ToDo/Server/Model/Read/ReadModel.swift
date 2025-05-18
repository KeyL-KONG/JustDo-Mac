//
//  ReadModel.swift
//  ReadList
//
//  Created by ByteDance on 2023/9/16.
//

import Foundation
import LeanCloud

class ReadModel: BaseModel, Identifiable, Codable {
    
    var title: String = ""
    var url: String = ""
    var note: String = ""
    var tag: String = ""
    
    required init() {
        super.init()
    }
    
    override class func modelClassName() -> String {
        return "ReadModel"
    }
    
    override func modelClassName() -> String {
        return "ReadModel"
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: ReadModelKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .tag) ?? ""
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        tag = try container.decodeIfPresent(String.self, forKey: .tag) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ReadModelKeys.self)
        try container.encode(tag, forKey: .tag)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(note, forKey: .note)
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        title = cloudObj.get(ReadModelKeys.title.rawValue)?.stringValue ?? ""
        url = cloudObj.get(ReadModelKeys.url.rawValue)?.stringValue ?? ""
        note = cloudObj.get(ReadModelKeys.note.rawValue)?.stringValue ?? ""
        tag = cloudObj.get(ReadModelKeys.tag.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        
        try cloudObj.set(ReadModelKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(ReadModelKeys.url.rawValue, value: url.lcString)
        try cloudObj.set(ReadModelKeys.note.rawValue, value: note.lcString)
        try cloudObj.set(ReadModelKeys.tag.rawValue, value: tag.lcString)
    }
    
}

extension ReadModel {
    
    enum ReadModelKeys: String, CodingKey {
        case title = "title"
        case url = "url"
        case note = "note"
        case tag
    }
    
}
