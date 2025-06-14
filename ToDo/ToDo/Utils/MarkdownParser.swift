//
//  MarkdownParser.swift
//  ToDo
//
//  Created by ByteDance on 2025/6/11.
//

import Foundation

/// 标题节点数据结构
final class HeadingNode: Hashable {
    enum Level: Int {
        case h1 = 1
        case h2 = 2
        case h3 = 3
    }
    
    let id: String = UUID().uuidString
    let level: Level
    let title: String
    var content: [String]
    var children: [HeadingNode]
    
    init(level: Level, title: String) {
        self.level = level
        self.title = title
        self.content = []
        self.children = []
    }
    
    static func == (lhs: HeadingNode, rhs: HeadingNode) -> Bool {
        lhs.level == rhs.level &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.children == rhs.children
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(level)
        hasher.combine(title)
        hasher.combine(content)
        hasher.combine(children)
    }
    
    var description: String {
        var desc = title
        children.forEach { node in
            desc += " - \(node.description) "
        }
        return desc
    }
}

/// Markdown 解析器
struct MarkdownParser {
    
    /// 解析 Markdown 文本并生成标题结构树
    static func parse(markdown: String) -> [HeadingNode] {
        let lines = markdown.components(separatedBy: .newlines)
        var nodes: [HeadingNode] = []
        var stack = [HeadingNode]()  // 用于处理嵌套结构
        
        for line in lines {
            // 检测标题行（支持1-3级）
            if let heading = detectHeading(line: line) {
                print("heading: \(heading.title), \(heading.level)")
                let node = HeadingNode(level: heading.level, title: heading.title)
                
                // 处理层级关系
                while let lastNode = stack.last, lastNode.level.rawValue >= heading.level.rawValue {
                    print("remove stack node: \(lastNode.description)")
                    stack.removeLast()
                }
                
                // 更新父节点子列表
                if let parent = stack.last {
                    let newParent = parent
                    newParent.children.append(node)
                    stack[stack.count-1] = newParent  // 关键修复点
                    print("update parent node: \(node.description)")
                } else {
                    nodes.append(node)
                    stack.append(node)
                    print("append node: \(node.description)")
                }
                continue
            }
            
            // 非标题内容处理
            if !line.isEmpty, let last = stack.last {
                let newLast = last
                newLast.content.append(line)
                stack[stack.count-1] = newLast  // 确保内容更新
            }
        }
        
        print("parse node: \(nodes.compactMap { $0.description })")
        
        return nodes
    }
    
    /// 检测标题行并提取信息
    private static func detectHeading(line: String) -> (level: HeadingNode.Level, title: String)? {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        
        // 检测标题模式：1-3个#开头，后跟空格
        guard
            trimmedLine.hasPrefix("#"),
            let firstSpaceIndex = trimmedLine.firstIndex(of: " "),
            firstSpaceIndex > trimmedLine.startIndex
        else { return nil }
        
        // 计算标题级别
        let prefix = String(trimmedLine[..<firstSpaceIndex])
        let levelCount = prefix.filter { $0 == "#" }.count
        
        guard (1...3).contains(levelCount) else { return nil }
        
        // 提取标题文本
        let titleStart = trimmedLine.index(after: firstSpaceIndex)
        let title = String(trimmedLine[titleStart...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let level = HeadingNode.Level(rawValue: levelCount) else {
            return nil
        }
        
        return (level, title)
    }
}

/// 树形结构打印器
struct HeadingTreePrinter {
    static func printTree(_ nodes: [HeadingNode], indent: Int = 0) {
        for node in nodes {
            let indentStr = String(repeating: "  ", count: indent)
            print("\(indentStr)\(node.levelSymbol) \(node.title)")
            
            // 打印内容摘要
            if !node.content.isEmpty {
                let contentPreview = node.content
                    .prefix(3)
                    .map { "\($0.prefix(30))\($0.count > 30 ? "..." : "")" }
                    .joined(separator: "\n\(indentStr)  ")
                print("\(indentStr)  └─ \(contentPreview)")
            }
            
            // 递归打印子节点
            printTree(node.children, indent: indent + 1)
        }
    }
}

// 扩展 HeadingNode 添加实用属性
extension HeadingNode {
    var levelSymbol: String {
        switch level {
        case .h1: return "#"
        case .h2: return "##"
        case .h3: return "###"
        }
    }
}
