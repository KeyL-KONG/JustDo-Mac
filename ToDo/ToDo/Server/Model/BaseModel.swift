//
//  BaseModel.swift
//  Reading
//
//  Created by liuqiang on 2022/7/13.
//

import Foundation
import LeanCloud

class BaseModel: NSObject, Codable {
    var id:String = ""
    var createTime:Date?
    var updateAt:Date?
    var user:LCUser?
    
    required override init() {}
    
    class func modelClassName() -> String {
        return "BaseModel"
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: BaseModelKeys.self)
        self.createTime = try container.decodeIfPresent(Date.self, forKey: .createTime)
        self.updateAt = try container.decodeIfPresent(Date.self, forKey: .updateAt)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BaseModelKeys.self)
        try container.encode(self.id, forKey: .id)
        if let createTime {
            try container.encode(createTime, forKey: .createTime)
        }
        if let updateAt {
            try container.encode(updateAt, forKey: .updateAt)
        }
    }
    
}

extension BaseModel: CloudProtocol {
    enum BaseModelKeys: String, CodingKey {
        case user = "user"
        case id
        case createTime
        case updateAt
    }
    
    #if os(macOS)
    override static func className() -> String {
        return self.modelClassName()
    }
    #endif
    
    #if os(iOS)
    static func className() -> String {
        return self.modelClassName()
    }
    #endif
    
    func modelClassName() -> String {
        return "BaseModel"
    }
    
    func identify() -> String {
        return self.id
    }
    
    func fillIdentify(_ identify: String) {
        self.id = identify
    }
    
    func convert(to cloudObj: LCObject) throws {
        if createTime == nil {
            createTime = Date.init()
        }
        if updateAt == nil {
            updateAt = Date.init()
        }
    }
    
    func fillModel(with cloudObj: LCObject) {
        self.id = cloudObj.objectId?.stringValue ?? ""
        self.createTime = cloudObj.createdAt?.dateValue
        self.updateAt = cloudObj.updatedAt?.dateValue
        //self.user = UserManager.shared.currentLoginUser
    }
}
