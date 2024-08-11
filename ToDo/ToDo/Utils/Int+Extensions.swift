//
//  Int+Extension.swift
//  JustDo
//
//  Created by LQ on 2024/4/20.
//

import Foundation

extension Int {
    
    var timeStr: String {
        let sec = (self % 3600) % 60
        let min = (self % 3600) / 60
        let hour = self / 3600
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    
    var simpleTimeStr: String {
        let min = Int((self % 3600) / 60)
        let hour = Int(self / 3600)
        return hour > 0 ? (min > 0 ? "\(hour)h\(min)m" : "\(hour)h") : (min > 0 ? "\(min)m" : "")
    }
    
}
