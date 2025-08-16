//
//  Int+Extension.swift
//  JustDo
//
//  Created by LQ on 2024/4/20.
//

import Foundation

extension Int {
    
    var weekDayStr: String {
        let arr = ["一", "二", "三", "四", "五", "六", "日"]
        let index = self % arr.count
        return arr[index]
    }
    
    var timeStr: String {
        let sec = (self % 3600) % 60
        let min = (self % 3600) / 60
        let hour = self / 3600
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, min, sec)
        } else {
            return String(format: "%02d:%02d", min, sec)
        }
    }
    
    var secondAndMinTimeStr: String {
        let seconds = self % 60
        let min = self / 60
        return String(format: "%02d:%02d", min, seconds)
    }
    
    var minAndHourTimeStr: String {
        let min = (self % 3600) / 60
        let hour = self / 3600
        return String(format: "%02d:%02d", hour, min)
    }
    
    var simpleTimeStr: String {
        let min = Int((self % 3600) / 60)
        let hour = Int(self / 3600)
        return hour > 0 ? (min > 0 ? "\(hour)h\(min)m" : "\(hour)h") : (min > 0 ? "\(min)m" : "")
    }
    
    var symbolStr: String {
        return self > 0 ? "+\(self)" : "\(self)"
    }
    
}

extension Date {
    /// 计算与另一个日期的时间差并返回格式化字符串
    /// - Parameter anotherDate: 要比较的另一个日期
    /// - Returns: 格式化后的时间差字符串，例如 "2h 后" 或 "30min 后"
    func timeDifferenceString(from anotherDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self, to: anotherDate)
        
        // 计算总分钟差（绝对值）
        let totalMinutes = abs((components.hour ?? 0) * 60 + (components.minute ?? 0))
        
        if totalMinutes >= 60 {
            // 超过1小时，显示小时数
            let hours = totalMinutes / 60
            return "\(hours)h 后"
        } else {
            // 不足1小时，显示分钟数
            // 如果分钟数为0，显示"即将"
            return totalMinutes == 0 ? "即将" : "\(totalMinutes)min 后"
        }
    }
    
}
