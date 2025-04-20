//
//  ReadingProtocol.swift
//  Reading
//
//  Created by liuqiang on 2022/7/12.
//

import Foundation
import LeanCloud

@objc protocol CloudProtocol {
    
    init()
    
    static func className() -> String
    
    func modelClassName() -> String
    
    func identify() -> String
    
    func fillIdentify(_ identify:String) -> Void
    
    func convert(to cloudObj:LCObject) throws
    
    func fillModel(with cloudObj:LCObject) -> Void
    
}

enum CloudError: Error {
    case message(String)
    case notLogin
}

extension CloudError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .message(let msg):
            return NSLocalizedString(msg, comment: "")
        case .notLogin:
            return NSLocalizedString("未登录，请登录", comment: "")
        }
    }
    
}
