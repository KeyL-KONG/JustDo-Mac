//
//  ToDoSection.swift
//  ToDo
//
//  Created by LQ on 2024/8/10.
//

import Foundation

enum ToDoSection: Identifiable, CaseIterable, Hashable {
    case today
    case week
    case unplan
    case recent
    case all
    case list(ItemTag)
    
    var id: String {
        switch self {
        case .today:
            return "today"
        case .week:
            return "week"
        case .unplan:
            return "unplan"
        case .recent:
            return "recent"
        case .all:
            return "all"
        case .list(let tag):
            return tag.title
        }
    }
    
    var displayName: String {
        switch self {
        case .today:
            return "today"
        case .week:
            return "week"
        case .unplan:
            return "unplan"
        case .recent:
            return "recent"
        case .all:
            return "all"
        case .list(let tag):
            return tag.title
        }
    }
    
    var iconName: String {
        switch self {
        case .today:
            return "checklist.unchecked"
        case .week:
            return "calendar"
        case .unplan:
            return "star"
        case .recent:
            return "clock.fill"
        case .all:
            return "calendar"
        case .list(_):
            return "folder"
        }
    }
    
    static var allCases: [ToDoSection] {
        return [.today, .week, .recent, .unplan, .all]
    }
    
}

enum TodoMode {
    case synthesis
    case work
    
    var title: String {
        switch self {
        case .synthesis:
            return "综合模式"
        case .work:
            return "工作模式"
        }
    }
    
    static var allCases: [TodoMode] = [.synthesis, .work]
}
