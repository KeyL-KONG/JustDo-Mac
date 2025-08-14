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
    var faTimes: [Date] = []
    var stTimes: [Date] = []
    var needReview: Bool = true
    
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
        super.init()
        let container = try decoder.container(keyedBy:  NoteItemKeys.self)
        content = try container.decode(String.self, forKey: .content)
        title = try container.decode(String.self, forKey: .title)
        faTimes = try container.decode([Date].self, forKey: .faTimes)
        stTimes = try container.decode([Date].self, forKey: .stTimes)
        needReview = try container.decode(Bool.self, forKey: .needReview)
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
        try container.encode(faTimes, forKey: .faTimes)
        try container.encode(stTimes, forKey: .stTimes)
        try container.encode(needReview, forKey: .needReview)
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
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(NoteItemKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(NoteItemKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(NoteItemKeys.faTimes.rawValue, value: faTimes.lcArray)
        try cloudObj.set(NoteItemKeys.stTimes.rawValue, value: stTimes.lcArray)
        try cloudObj.set(NoteItemKeys.needReview.rawValue, value: needReview.lcBool)
    }
    
}

extension NoteItem {
    
    enum NoteItemKeys: String, CodingKey {
        case content = "content"
        case title
        case faTimes
        case stTimes
        case needReview
    }
    
}
