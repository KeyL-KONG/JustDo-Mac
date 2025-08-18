//
//  NoteModel.swift
//  Note
//
//  Created by ByteDance on 2023/8/22.
//

import Foundation
import LeanCloud

enum NoteType: String {
    case text
    case web
    
    static let types: [String] = ["text", "web"]
}

class NoteItem: BaseModel, Identifiable {
    
    var title: String = ""
    var content: String = ""
    var faTimes: [Date] = []
    var stTimes: [Date] = []
    var needReview: Bool = true
    var type: String = "text"
    var url: String = ""
    
    var noteType: NoteType {
        return NoteType(rawValue: type) ?? .text
    }
    
    var faScore: Int { faTimes.count }
    var stScore: Int { stTimes.count }
    
    var score: Int {
        return faScore - stScore
    }
    
    func hasReview(date: Date) -> Bool {
        let times = faTimes + stTimes
        return times.contains { $0.isInSameDay(as: date)}
    }
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy:  NoteItemKeys.self)
        content = try container.decode(String.self, forKey: .content)
        title = try container.decode(String.self, forKey: .title)
        faTimes = try container.decode([Date].self, forKey: .faTimes)
        stTimes = try container.decode([Date].self, forKey: .stTimes)
        needReview = try container.decode(Bool.self, forKey: .needReview)
        type = try container.decode(String.self, forKey: .type)
        url = try container.decode(String.self, forKey: .url)
    }
    
    init(content: String, title: String = "") {
        super.init()
        self.content = content
        self.title = title
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: NoteItemKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(title, forKey: .title)
        try container.encode(faTimes, forKey: .faTimes)
        try container.encode(stTimes, forKey: .stTimes)
        try container.encode(needReview, forKey: .needReview)
        try container.encode(type, forKey: .type)
        try container.encode(url, forKey: .url)
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
        faTimes = cloudObj.get(NoteItemKeys.faTimes.rawValue)?.arrayValue as? [Date] ?? []
        stTimes = cloudObj.get(NoteItemKeys.stTimes.rawValue)?.arrayValue as? [Date] ?? []
        needReview = cloudObj.get(NoteItemKeys.needReview.rawValue)?.boolValue ?? true
        type = cloudObj.get(NoteItemKeys.type.rawValue)?.stringValue ?? ""
        url = cloudObj.get(NoteItemKeys.url.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(NoteItemKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(NoteItemKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(NoteItemKeys.faTimes.rawValue, value: faTimes.lcArray)
        try cloudObj.set(NoteItemKeys.stTimes.rawValue, value: stTimes.lcArray)
        try cloudObj.set(NoteItemKeys.needReview.rawValue, value: needReview.lcBool)
        try cloudObj.set(NoteItemKeys.type.rawValue, value: type.lcString)
        try cloudObj.set(NoteItemKeys.url.rawValue, value: url.lcString)
    }
    
}

extension NoteItem {
    
    enum NoteItemKeys: String, CodingKey {
        case content = "content"
        case title
        case faTimes
        case stTimes
        case needReview
        case type
        case url
    }
    
}
