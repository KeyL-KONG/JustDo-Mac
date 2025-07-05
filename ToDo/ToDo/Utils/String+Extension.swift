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


extension String {
    /// 在指定位置插入字符串
    /// - Parameters:
    ///   - text: 要插入的文本
    ///   - position: 插入位置（基于字符索引）
    ///   - useUTF16Offset: 是否使用 UTF-16 偏移量（默认为字符索引）
    func insert(_ text: String, at position: Int, useUTF16Offset: Bool = false) -> String {
        // 处理边界情况
        if position <= 0 {
            return text + self
        }
        
        let maxPosition = useUTF16Offset ? self.utf16.count : self.count
        if position >= maxPosition {
            return self + text
        }
        
        // 根据选择的索引类型计算位置
        let index: String.Index
        if useUTF16Offset {
            // 使用 UTF-16 偏移量
            guard let utf16Index = self.utf16.index(
                self.utf16.startIndex,
                offsetBy: position,
                limitedBy: self.utf16.endIndex
            ) else {
                return self + text
            }
            
            index = String.Index(utf16Index, within: self) ?? self.endIndex
        } else {
            // 使用字符索引
            index = self.index(self.startIndex, offsetBy: position)
        }
        
        // 执行插入
        var result = self
        result.insert(contentsOf: text, at: index)
        return result
    }
    
}

extension String {
    /// 截取到指定数量的字符
    /// - Parameter length: 要保留的字符数量
    /// - Returns: 截取后的字符串
    func substring(to length: Int) -> String {
        guard length > 0 else { return "" }
        guard count > length else { return self }
        
        let endIndex = index(startIndex, offsetBy: length)
        return String(self[..<endIndex])
    }
    
    /// 截取到指定数量的字符，添加后缀
    /// - Parameters:
    ///   - length: 要保留的字符数量
    ///   - suffix: 截取后添加的后缀（如省略号）
    /// - Returns: 截取后的字符串
    func truncated(to length: Int, suffix: String = "...") -> String {
        guard count > length else { return self }
        return substring(to: max(0, length - suffix.count)) + suffix
    }
}
