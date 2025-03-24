//
//  DayView.swift
//  ToDo
//
//  Created by LQ on 2025/3/23.
//

import SwiftUI

struct DayView: View {
    let date: Date
    @Binding var selectDate: Date?
    
    var body: some View {
        VStack(spacing: 12) {
            Text(Calendar.dayNumber(from: date))
                .background {
                    if date == selectDate {
                        Circle()
                            .foregroundStyle(.blue)
                            .opacity(0.3)
                            .frame(width: 40, height: 40)
                    } else if Calendar.current.isDateInToday(date) {
                        Circle()
                            .foregroundStyle(.secondary)
                            .opacity(0.3)
                            .frame(width: 40, height: 40)
                    }
                }
        }
        .foregroundStyle(selectDate == date ? .blue : .black)
        .font(.system(.body, design: .rounded, weight: .medium))
        .onTapGesture {
            withAnimation(.easeInOut) {
                selectDate = date
            }
        }
    }
}

extension Calendar {
    
    static func dayNumber(from date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return String(format: "%02d", day)
    }
    
}


#Preview {
    DayView(date: .now, selectDate: .constant(nil))
}
