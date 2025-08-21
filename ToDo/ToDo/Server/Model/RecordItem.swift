//
//  RecordItem.swift
//  Summary
//
//  Created by LQ on 2024/10/20.
//

import Foundation
import LeanCloud

class RecordItem: BaseModel, Identifiable {
    
    var avatar: String = ""
    var content: String = ""
    var imageList: [String] = []
    var videoList: [String] = []
    var evaluateIds: [String] = []
    var evaluateValues: [Int] = []
    
    var mediaList: [String] {
        imageList + videoList
    }
    
    func isImage(assetID: String) -> Bool {
        return imageList.contains(assetID)
    }
    
    var recordTime: Date?
    var displayTime: Date {
        return recordTime ?? createTime ?? .now
    }
    
    override class func modelClassName() -> String {
        return "RecordItem"
    }
    
    override func modelClassName() -> String {
        return "RecordItem"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        self.avatar = cloudObj.get(RecordItemKeys.avatar.rawValue)?.stringValue ?? ""
        self.content = cloudObj.get(RecordItemKeys.content.rawValue)?.stringValue ?? ""
        self.imageList = cloudObj.get(RecordItemKeys.imageList.rawValue)?.arrayValue as? [String] ?? []
        self.videoList = cloudObj.get(RecordItemKeys.videoList.rawValue)?.arrayValue as? [String] ?? []
        if let recordTime = cloudObj.get(RecordItemKeys.recordTime.rawValue)?.dateValue {
            self.recordTime = recordTime
        }
        self.evaluateIds = cloudObj.get(RecordItemKeys.evaluateIds.rawValue)?.arrayValue as? [String] ?? []
        self.evaluateValues = cloudObj.get(RecordItemKeys.evaluateValues.rawValue)?.arrayValue?.compactMap({ ($0 as AnyObject).intValue}) ?? []
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(RecordItemKeys.avatar.rawValue, value: avatar.lcString)
        try cloudObj.set(RecordItemKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(RecordItemKeys.imageList.rawValue, value: imageList.lcArray)
        try cloudObj.set(RecordItemKeys.videoList.rawValue, value: videoList.lcArray)
        if let recordTime {
            try cloudObj.set(RecordItemKeys.recordTime.rawValue, value: recordTime.lcDate)
        }
        try cloudObj.set(RecordItemKeys.evaluateIds.rawValue, value: evaluateIds.lcArray)
        try cloudObj.set(RecordItemKeys.evaluateValues.rawValue, value: evaluateValues.lcArray)
    }
    
    enum RecordItemKeys: String, CodingKey {
        case avatar
        case content
        case imageList
        case videoList
        case recordTime
        case evaluateIds
        case evaluateValues
    }
    required init(from decoder: any Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: RecordItemKeys.self)
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.imageList = try container.decodeIfPresent([String].self, forKey: .imageList) ?? []
        self.videoList = try container.decodeIfPresent([String].self, forKey: .videoList) ?? []
        self.recordTime = try container.decodeIfPresent(Date.self, forKey: .recordTime)
        self.evaluateIds = try container.decodeIfPresent([String].self, forKey: .evaluateIds) ?? []
        self.evaluateValues = try container.decodeIfPresent([Int].self, forKey: .evaluateValues) ?? []
    }
    
    required init() {
        super.init()
    }
    
    override func encode(to encoder: any Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: RecordItemKeys.self)
        try container.encode(self.avatar, forKey: .avatar)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.imageList, forKey: .imageList)
        try container.encode(self.videoList, forKey: .videoList)
        try container.encode(self.recordTime, forKey: .recordTime)
        try container.encode(self.evaluateIds, forKey: .evaluateIds)
        try container.encode(self.evaluateValues, forKey: .evaluateValues)
    }
}
