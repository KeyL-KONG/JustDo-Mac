//
//  ReadModel.swift
//  ReadList
//
//  Created by ByteDance on 2023/9/16.
//

import Foundation
import LeanCloud

class ReadModel: BaseModel, Identifiable {
    
    var title: String = ""
    var url: String = ""
    var note: String = ""
    var tag: String = ""
    
    required init() {
        
    }
    
    override class func modelClassName() -> String {
        return "ReadModel"
    }
    
    override func modelClassName() -> String {
        return "ReadModel"
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
    
    enum ReadModelKeys: String {
        case title = "title"
        case url = "url"
        case note = "note"
        case tag
    }
    
}
