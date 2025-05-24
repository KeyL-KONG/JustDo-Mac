//
//  Dictionary+Extensions.swift
//  ToDo
//
//  Created by LQ on 2025/5/24.
//

import Foundation

extension Dictionary {
    func toJsonString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("转换失败: \(error)")
        }
        return nil
    }
}

