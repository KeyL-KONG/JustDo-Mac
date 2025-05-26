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
    var rate: Double = 0
    var intervals: [LQDateInterval] = []
    var finishTimes: [Date] = []
    
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
        rate = try container.decodeIfPresent(Double.self, forKey: .rate) ?? 0
        if let dates = try container.decodeIfPresent([Date].self, forKey: .intervals) {
            var intervals: [LQDateInterval] = []
            for i in stride(from: 0, to: dates.count - 1, by: 2) {
                let interval = LQDateInterval(start: dates[i], end: dates[i+1])
                intervals.append(interval)
            }
            self.intervals = intervals
        }
        finishTimes = try container.decodeIfPresent([Date].self, forKey: .finishTimes) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ReadModelKeys.self)
        try container.encode(tag, forKey: .tag)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(note, forKey: .note)
        if intervals.count > 0 {
            var dates = [Date]()
            for interval in intervals {
                dates += [interval.start, interval.end]
            }
            try container.encode(dates, forKey: .intervals)
        }
        try container.encode(finishTimes, forKey: .finishTimes)
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        title = cloudObj.get(ReadModelKeys.title.rawValue)?.stringValue ?? ""
        url = cloudObj.get(ReadModelKeys.url.rawValue)?.stringValue ?? ""
        note = cloudObj.get(ReadModelKeys.note.rawValue)?.stringValue ?? ""
        tag = cloudObj.get(ReadModelKeys.tag.rawValue)?.stringValue ?? ""
        rate = cloudObj.get(ReadModelKeys.rate.rawValue)?.doubleValue ?? 0.0
        if let dates = cloudObj.get(ReadModelKeys.intervals.rawValue)?.arrayValue as? [Date] {
            var intervals: [LQDateInterval] = []
            for i in stride(from: 0, to: dates.count - 1, by: 2) {
                let interval = LQDateInterval(start: dates[i], end: dates[i+1])
                intervals.append(interval)
            }
            self.intervals = intervals
        }
        if let finishTimes = cloudObj.get(ReadModelKeys.finishTimes.rawValue)?.arrayValue as? [Date] {
            self.finishTimes = finishTimes
        }
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        
        try cloudObj.set(ReadModelKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(ReadModelKeys.url.rawValue, value: url.lcString)
        try cloudObj.set(ReadModelKeys.note.rawValue, value: note.lcString)
        try cloudObj.set(ReadModelKeys.tag.rawValue, value: tag.lcString)
        try cloudObj.set(ReadModelKeys.rate.rawValue, value: rate.lcNumber)
        if intervals.count > 0 {
            var dates = [Date]()
            for interval in intervals {
                dates += [interval.start, interval.end]
            }
            try cloudObj.set(ReadModelKeys.intervals.rawValue, value: dates.lcArray)
        }
        try cloudObj.set(ReadModelKeys.finishTimes.rawValue, value: finishTimes.lcArray)
    }
    
}

extension ReadModel {
    
    enum ReadModelKeys: String, CodingKey {
        case title = "title"
        case url = "url"
        case note = "note"
        case tag
        case rate
        case intervals
        case finishTimes
    }
    
    var readTimes: Int {
        return finishTimes.count
    }
    
    var totalReadTime: Int {
        return intervals.compactMap { $0.interval }.reduce(0, +)
    }
    
}
