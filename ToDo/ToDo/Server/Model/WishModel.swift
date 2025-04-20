//
//  WishModel.swift
//  JustDo
//
//  Created by ByteDance on 2024/1/28.
//

import Foundation
import LeanCloud

enum WishValueType: Int {
    case num
    case times
    
    var description: String {
        switch self {
        case .num:
            return "数值"
        case .times:
            return "计次"
        }
    }
}

class WishModel: BaseModel, Identifiable, Decodable, Encodable {
    
    var title: String = ""
    var score: Int = 0
    var valueType: WishValueType = .num
    var mark: String = ""
    var isFinish: Bool = false
    
    required init() {
        
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: WishModelKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createTime = try container.decode(Date.self, forKey: .createTime)
        self.updateAt = try container.decode(Date.self, forKey: .updateAt)
        self.title = try container.decode(String.self, forKey: .title)
        self.score = try container.decode(Int.self, forKey: .score)
        self.valueType = WishValueType(rawValue: try container.decode(Int.self, forKey: .valueType)) ?? .num
        self.mark = try container.decode(String.self, forKey: .mark)
        self.isFinish = try container.decode(Bool.self, forKey: .isFinish)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WishModelKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.createTime, forKey: .createTime)
        try container.encode(self.updateAt, forKey: .updateAt)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.score, forKey: .score)
        try container.encode(self.valueType.rawValue, forKey: .valueType)
        try container.encode(self.mark, forKey: .mark)
        try container.encode(self.isFinish, forKey: .isFinish)
    }
    
    
    override class func modelClassName() -> String {
        return "WishModel"
    }
    
    override func modelClassName() -> String {
        return "WishModel"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        title = cloudObj.get(WishModelKeys.title.rawValue)?.stringValue ?? ""
        score = cloudObj.get(WishModelKeys.score.rawValue)?.intValue ?? 0
        mark = cloudObj.get(WishModelKeys.mark.rawValue)?.stringValue ?? ""
        isFinish = cloudObj.get(WishModelKeys.isFinish.rawValue)?.boolValue ?? false
        valueType = WishValueType(rawValue: cloudObj.get(WishModelKeys.valueType.rawValue)?.intValue ?? 0) ?? .num
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(WishModelKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(WishModelKeys.score.rawValue, value: score.lcNumber)
        try cloudObj.set(WishModelKeys.mark.rawValue, value: mark.lcString)
        try cloudObj.set(WishModelKeys.isFinish.rawValue, value: isFinish.lcBool)
        try cloudObj.set(WishModelKeys.valueType.rawValue, value: valueType.rawValue.lcNumber)
    }
    
}

extension WishModel {
    enum WishModelKeys: String, CodingKey {
        case id
        case createTime
        case updateAt
        case title
        case score
        case mark
        case isFinish
        case valueType
    }
}
