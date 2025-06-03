//
//  String+Extension.swift
//  ToDo
//
//  Created by LQ on 2025/5/24.
//

import Foundation

extension String {
    
    var formatImageUrl: String {
        var url = self
        if !url.hasPrefix("https") {
            url = url.replacingOccurrences(of: "http://", with: "https://")
        }
        return "![image](\(url))"
    }
    
    func toJson() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return dictionary
        } catch {
            print("JSON 解析失败: \(error.localizedDescription)")
            return nil
        }
    }
    
}

extension String {
    /// 截断到指定子字符串的位置
    /// - Parameters:
    ///   - substring: 目标子字符串
    ///   - options: 搜索选项（默认区分大小写）
    ///   - includingSubstring: 是否包含子字符串本身（默认不包含）
    /// - Returns: 截断后的字符串（未找到时返回 nil）
    func truncateAfter(
        substring: String,
        options: String.CompareOptions = [],
        includingSubstring: Bool = false
    ) -> String {
        guard let range = self.range(of: substring, options: options) else {
            return self
        }
        
        let cutoffIndex = includingSubstring ? range.upperBound : range.lowerBound
        return String(self[..<cutoffIndex])
    }
}
