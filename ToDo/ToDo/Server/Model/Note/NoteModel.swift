//
//  NoteModel.swift
//  Note
//
//  Created by ByteDance on 2023/8/22.
//

import Foundation
import LeanCloud

class NoteModel: BaseModel, Identifiable {
    
    var convertId: String  = ""
    var title: String = ""
    var content: String = ""
    var tags: [String] = []
    var summary: String = ""
    var overview: String = ""
    var rate: Int = 0
    var items: [String] = []
    
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
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: NoteModelKeys.self)
        title = try container.decode(String.self, forKey: .title)
        tags = try container.decode([String].self, forKey: .tags)
        content = try container.decode(String.self, forKey: .content)
        convertId = try container.decode(String.self, forKey: .convertId)
        summary = try container.decode(String.self, forKey: .summary)
        overview = try container.decode(String.self, forKey: .overview)
        rate = try container.decode(Int.self, forKey: .rate)
        items = try container.decode([String].self, forKey: .items)
        faTimes = try container.decode([Date].self, forKey: .faTimes)
        stTimes = try container.decode([Date].self, forKey: .stTimes)
        needReview = try container.decode(Bool.self, forKey: .needReview)
    }
    
    init(content: String) {
        super.init()
        self.content = content
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: NoteModelKeys.self)
        try container.encode(tags, forKey: .tags)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(convertId, forKey: .convertId)
        try container.encode(summary, forKey: .summary)
        try container.encode(overview, forKey: .overview)
        try container.encode(rate, forKey: .rate)
        try container.encode(items, forKey: .items)
        try container.encode(faTimes, forKey: .faTimes)
        try container.encode(stTimes, forKey: .stTimes)
        try container.encode(needReview, forKey: .needReview)
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
        rate = cloudObj.get(NoteModelKeys.rate.rawValue)?.intValue ?? 0
        items = cloudObj.get(NoteModelKeys.items.rawValue)?.arrayValue as? [String] ?? []
        faTimes = cloudObj.get(NoteModelKeys.faTimes.rawValue)?.arrayValue as? [Date] ?? []
        stTimes = cloudObj.get(NoteModelKeys.stTimes.rawValue)?.arrayValue as? [Date] ?? []
        needReview = cloudObj.get(NoteModelKeys.needReview.rawValue)?.boolValue ?? false
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(NoteModelKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(NoteModelKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(NoteModelKeys.tags.rawValue, value: tags.lcArray)
        try cloudObj.set(NoteModelKeys.convertId.rawValue, value: convertId.lcString)
        try cloudObj.set(NoteModelKeys.overview.rawValue, value: overview.lcString)
        try cloudObj.set(NoteModelKeys.summary.rawValue, value: summary.lcString)
        try cloudObj.set(NoteModelKeys.rate.rawValue, value: rate.lcNumber)
        try cloudObj.set(NoteModelKeys.items.rawValue, value: items.lcArray)
        try cloudObj.set(NoteModelKeys.faTimes.rawValue, value: faTimes.lcArray)
        try cloudObj.set(NoteModelKeys.stTimes.rawValue, value: stTimes.lcArray)
        try cloudObj.set(NoteModelKeys.needReview.rawValue, value: needReview.lcBool)
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
        case rate
        case items
        case faTimes
        case stTimes
        case needReview
    }
    
}
