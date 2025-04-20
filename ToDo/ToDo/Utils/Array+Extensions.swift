//
//  Array+Extensions.swift
//  ToDo
//
//  Created by LQ on 2024/8/14.
//

import SwiftUI

extension Array where Element == String {
    
    var uniqueArray: [String] {
        let set = Set(self)
        return Array(set)
    }
    
}
