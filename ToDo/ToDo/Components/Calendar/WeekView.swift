//
//  WeekView.swift
//  ToDo
//
//  Created by LQ on 2025/3/23.
//

import SwiftUI

enum WeekOrderType {
    case previous
    case current
    case next
}

struct Week: Identifiable, Equatable {
    let order: WeekOrderType
    let days: [Date]
    
    var id: String {
        // 组合周类型和首末日期生成唯一标识
        let orderStr: String = {
            switch order {
            case .previous: return "prev"
            case .current: return "curr"
            case .next: return "next"
            }
        }()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        guard let firstDay = days.first, 
              let lastDay = days.last else {
            return "\(orderStr)_invalid"
        }
        
        return "\(orderStr)_\(dateFormatter.string(from: firstDay))_\(dateFormatter.string(from: lastDay))"
    }
}

struct WeekView: View {
    let week: Week
    let dragProgress: CGFloat
    let hideDifferentMonth: Bool
    
    @Binding var selectDate: Date?
    
    init(week: Week, selectDate: Binding<Date?>,  dragProgress: CGFloat, hideDifferentMonth: Bool = false) {
        self.week = week
        self.dragProgress = dragProgress
        self.hideDifferentMonth = hideDifferentMonth
        _selectDate = selectDate
    }
    
    var body: some View {
        HStack(spacing: .zero) {
            ForEach(week.days, id: \.self) { date in
                DayView(date: date, selectDate: $selectDate)
                    .opacity(isDayVisible(for: date) ? 1 : (1-dragProgress))
                    .frame(maxWidth: .infinity)
                if week.days.last != date {
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func isDayVisible(for date: Date) -> Bool {
        guard hideDifferentMonth else { return true }
        switch week.order {
        case .previous, .current:
            guard let last = week.days.last else { return true }
            return Calendar.isSameMonth(date, last)
        case .next:
            guard let first = week.days.first else { return true }
            return Calendar.isSameMonth(date, first)
        }
    }
}

extension Calendar {
    static func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, equalTo: date2, toGranularity: .month)
    }
}
