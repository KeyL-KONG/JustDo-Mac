//
//  String+Extension.swift
//  ToDo
//
//  Created by LQ on 2025/5/24.
//

import Foundation

extension String {
    
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

