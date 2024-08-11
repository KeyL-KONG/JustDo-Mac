//
//  UserModel.swift
//  Reading
//
//  Created by liuqiang on 2022/7/13.
//

import Foundation

class UserModel {
    var email:String = ""
    var password:String = ""
    
    init(email:String, password:String) {
        self.email = email
        self.password = password
    }
    
}

extension UserModel: Equatable {
    
    static func == (lhs:UserModel, rhs:UserModel) -> Bool {
        return lhs.email == rhs.email
    }
    
}
