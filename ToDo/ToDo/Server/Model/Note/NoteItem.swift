//
//  NoteModel.swift
//  Note
//
//  Created by ByteDance on 2023/8/22.
//

import Foundation
import LeanCloud

class NoteItem: BaseModel, Identifiable, Codable {
    
    var title: String = ""
    var content: String = ""
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy:  NoteItemKeys.self)
        content = try container.decode(String.self, forKey: .content)
        title = try container.decode(String.self, forKey: .title)
    }
    
    init(content: String, title: String = "") {
        super.init()
        self.content = content
        self.title = title
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NoteItemKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(title, forKey: .title)
    }
    
    override class func modelClassName() -> String {
        return "NoteItem"
    }
    
    override func modelClassName() -> String {
        return "NoteItem"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        content = cloudObj.get(NoteItemKeys.content.rawValue)?.stringValue ?? ""
        title = cloudObj.get(NoteItemKeys.title.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(NoteItemKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(NoteItemKeys.title.rawValue, value: title.lcString)
    }
    
}

extension NoteItem {
    
    enum NoteItemKeys: String, CodingKey {
        case content = "content"
        case title
    }
    
}
