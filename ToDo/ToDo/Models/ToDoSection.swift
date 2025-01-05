//
//  ToDoSection.swift
//  ToDo
//
//  Created by LQ on 2024/8/10.
//

import Foundation

enum ToDoSection: Identifiable, CaseIterable, Hashable {
    case today
    case review
    case summary
    case calendar
    case project
    case unplan
    case recent
    case all
    case list(ItemTag)
    
    var id: String {
        switch self {
        case .today:
            return "today"
        case .calendar:
            return "calendar"
        case .review:
            return "review"
        case .summary:
            return "summary"
        case .project:
            return "project"
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
        case .project:
            return "project"
        case .review:
            return "review"
        case .summary:
            return "summary"
        case .calendar:
            return "calendar"
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
        case .calendar:
            return "calendar"
        case .review:
            return "tray.full.fill"
        case .summary:
            return "square.and.pencil.circle.fill"
        case .project:
            return "paperplane.circle.fill"
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
        return [.today, .calendar, .review, .project, .unplan, .all]
    }
    
}

enum CalendarMode {
    case week
    case month
    
    var title: String {
        switch self {
        case .week:
            return "周视图"
        case .month:
            return "月视图"
        }
    }
    
    static var allCases: [CalendarMode] = [.week, .month]
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
