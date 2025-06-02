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
    case plan
    case calendar
    case project
    case unplan
    case recent
    case all
    case principle
    case personalTag
    case note
    case think
    case list(ItemTag)
    
    var id: String {
        switch self {
        case .today:
            return "today"
        case .plan:
            return "plan"
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
        case .principle:
            return "principle"
        case .personalTag:
            return "personal"
        case .note:
            return "note"
        case .think:
            return "think"
        case .list(let tag):
            return tag.title
        }
    }
    
    var displayName: String {
        switch self {
        case .today:
            return "today"
        case .plan:
            return "plan"
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
        case .principle:
            return "principle"
        case .personalTag:
            return "personal"
        case .note:
            return "note"
        case .think:
            return "think"
        case .list(let tag):
            return tag.title
        }
    }
    
    var iconName: String {
        switch self {
        case .today:
            return "checklist.unchecked"
        case .plan:
            return "square.and.pencil"
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
        case .principle:
            return "warninglight.fill"
        case .personalTag:
            return "calendar.and.person"
        case .note:
            return "note"
        case .think:
            return "lightbulb.max"
        case .list(_):
            return "folder"
        }
    }
    
    static var allCases: [ToDoSection] {
        return [.today, .note, .project, .plan, .calendar, .think, .personalTag, .principle,  .unplan, .all]
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

enum EventDisplayMode {
    case task
    case timeline
    
    var title: String {
        switch self {
        case .task:
            return "任务视图"
        case .timeline:
            return "时间视图"
        }
    }
    
    static var allCases: [EventDisplayMode] = [.task, .timeline]
}

enum TodoMode {
    case synthesis
    case work
    
    var title: String {
        switch self {
        case .synthesis:
            return "all"
        case .work:
            return "work"
        }
    }
    
    static var allCases: [TodoMode] = [.synthesis, .work]
}

enum TaskFinishState: String {
    case all
    case unfinish
    case finish
    
    static var allCases: [TaskFinishState] = [.all, .unfinish, .finish]
}
