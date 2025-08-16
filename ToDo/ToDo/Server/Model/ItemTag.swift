//
//  ItemTag.swift
//  JustDo
//
//  Created by LQ on 2024/4/21.
//

import Foundation
import LeanCloud
import SwiftUI

class ItemTag: BaseModel, Identifiable {
    
    public static let work = ItemTag(title: "work", hexColor: "#3498DB")
    public static let learn = ItemTag(title: "learn", hexColor: "#2ECC71")
    public static let life = ItemTag(title: "life", hexColor: "#17A589")
    
    var title: String = ""
    var fatherId: String = ""
    var descrip: String = ""
    var hexColor: String = ""
    var priority: Int = 0
    
    init(title: String, fatherId: String = "", descrip: String = "", hexColor: String) {
        super.init()
        self.title = title
        self.fatherId = fatherId
        self.descrip = descrip
        self.hexColor = hexColor
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ItemTagKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createTime = try container.decode(Date.self, forKey: .createTime)
        self.updateAt = try container.decode(Date.self, forKey: .updateAt)
        self.title = try container.decode(String.self, forKey: .title)
        self.fatherId = try container.decode(String.self, forKey: .fatherId)
        self.descrip = try container.decode(String.self, forKey: .descrip)
        self.hexColor = try container.decode(String.self, forKey: .hexColor)
        self.priority = try container.decode(Int.self, forKey: .priority)
    }
    
    required init() {
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ItemTagKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.createTime, forKey: .createTime)
        try container.encode(self.updateAt, forKey: .updateAt)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.fatherId, forKey: .fatherId)
        try container.encode(self.descrip, forKey: .descrip)
        try container.encode(self.hexColor, forKey: .hexColor)
        try container.encode(self.priority, forKey: .priority)
    }
    
    override class func modelClassName() -> String {
        return "ItemTag"
    }
    
    override func modelClassName() -> String {
        return "ItemTag"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        title = cloudObj.get(ItemTagKeys.title.rawValue)?.stringValue ?? ""
        fatherId = cloudObj.get(ItemTagKeys.fatherId.rawValue)?.stringValue ?? ""
        descrip = cloudObj.get(ItemTagKeys.descrip.rawValue)?.stringValue ?? ""
        hexColor = cloudObj.get(ItemTagKeys.hexColor.rawValue)?.stringValue ?? ""
        priority = cloudObj.get(ItemTagKeys.priority.rawValue)?.intValue ?? 0
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(ItemTagKeys.title.rawValue, value: title.lcString)
        try cloudObj.set(ItemTagKeys.fatherId.rawValue, value: fatherId.lcString)
        try cloudObj.set(ItemTagKeys.descrip.rawValue, value: descrip.lcString)
        try cloudObj.set(ItemTagKeys.hexColor.rawValue, value: hexColor.lcString)
        try cloudObj.set(ItemTagKeys.priority.rawValue, value: priority.lcNumber)
    }
    
}

extension ItemTag {
    
    enum ItemTagKeys: String, CodingKey {
        case id
        case createTime
        case updateAt
        case title
        case fatherId
        case descrip
        case hexColor
        case priority
    }
    
}


extension ItemTag {
    
    var titleColor: Color {
        return hexColor.count > 0 ? Color.init(hex: hexColor) : .green
    }

    
}
