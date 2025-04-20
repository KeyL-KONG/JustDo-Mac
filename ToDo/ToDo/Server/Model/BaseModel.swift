//
//  BaseModel.swift
//  Reading
//
//  Created by liuqiang on 2022/7/13.
//

import Foundation
import LeanCloud

class BaseModel: NSObject {
    var id:String = ""
    var createTime:Date?
    var updateAt:Date?
    var user:LCUser?
    
    required override init() {}
    
    class func modelClassName() -> String {
        return "BaseModel"
    }
}

extension BaseModel: CloudProtocol {
    enum BaseModelKeys: String {
        case user = "user"
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
