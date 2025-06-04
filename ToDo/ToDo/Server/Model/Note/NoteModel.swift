//
//  NoteModel.swift
//  Note
//
//  Created by ByteDance on 2023/8/22.
//

import Foundation
import LeanCloud

class NoteModel: BaseModel, Identifiable, Codable {
    
    var convertId: String  = ""
    var title: String = ""
    var content: String = ""
    var tags: [String] = []
    var summary: String = ""
    var overview: String = ""
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: NoteModelKeys.self)
        title = try container.decode(String.self, forKey: .title)
        tags = try container.decode([String].self, forKey: .tags)
        content = try container.decode(String.self, forKey: .content)
        convertId = try container.decode(String.self, forKey: .convertId)
        summary = try container.decode(String.self, forKey: .summary)
        overview = try container.decode(String.self, forKey: .overview)
    }
    
    init(content: String) {
        super.init()
        self.content = content
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NoteModelKeys.self)
        try container.encode(tags, forKey: .tags)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(convertId, forKey: .convertId)
        try container.encode(summary, forKey: .summary)
        try container.encode(overview, forKey: .overview)
    }
    
    override class func modelClassName() -> String {
        return "NoteModel"
    }
    
    override func modelClassName() -> String {
        return "NoteModel"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        title = cloudObj.get(NoteModelKeys.title.rawValue)?.stringValue ?? ""
        content = cloudObj.get(NoteModelKeys.content.rawValue)?.stringValue ?? ""
        if let tags = cloudObj.get(NoteModelKeys.tags.rawValue)?.arrayValue as? [String] {
            self.tags = tags
        }
        convertId = cloudObj.get(NoteModelKeys.convertId.rawValue)?.stringValue ?? ""
        summary = cloudObj.get(NoteModelKeys.summary.rawValue)?.stringValue ?? ""
        overview = cloudObj.get(NoteModelKeys.overview.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(NoteModelKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(NoteModelKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(NoteModelKeys.tags.rawValue, value: tags.lcArray)
        try cloudObj.set(NoteModelKeys.convertId.rawValue, value: convertId.lcString)
        try cloudObj.set(NoteModelKeys.overview.rawValue, value: overview.lcString)
        try cloudObj.set(NoteModelKeys.summary.rawValue, value: summary.lcString)
    }
    
}

extension NoteModel {
    
    enum NoteModelKeys: String, CodingKey {
        
        case title = "title"
        case content = "content"
        case tags = "tags"
        case convertId
        case overview
        case summary
    }
    
}
