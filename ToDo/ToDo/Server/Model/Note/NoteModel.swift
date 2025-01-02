//
//  NoteModel.swift
//  Note
//
//  Created by ByteDance on 2023/8/22.
//

import Foundation
import LeanCloud

class NoteModel: BaseModel, Identifiable {
    
    var title: String = ""
    var content: String = ""
    var tags: [String] = []
    
    required init() {
    
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
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(NoteModelKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(NoteModelKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(NoteModelKeys.tags.rawValue, value: tags.lcArray)
    }
    
}

extension NoteModel {
    
    enum NoteModelKeys: String {
        
        case title = "title"
        case content = "content"
        case tags = "tags"
        
    }
    
}
