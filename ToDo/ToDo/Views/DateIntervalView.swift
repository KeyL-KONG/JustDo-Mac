//
//  DateIntervalView.swift
//  ToDo
//
//  Created by LQ on 2024/8/10.
//

import SwiftUI

struct DateIntervalView: View {
    
    @State var interval: LQDateInterval
    var index: Int
    var intervalChange: (LQDateInterval) -> Void
    
    var body: some View {
        
        HStack {
            DatePicker("", selection: $interval.start, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .onChange(of: interval.start) { newValue in
                    intervalChange(LQDateInterval(start: newValue, end: interval.end))
                    print(newValue)
                }
               
            Spacer(minLength: 10)
            
            DatePicker("", selection: $interval.end, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .onChange(of: interval.end) { newValue in
                    intervalChange(LQDateInterval(start: interval.start, end: newValue))
                    print(newValue)
                }
            
            Spacer(minLength: 10)
            
            Text(interval.interval.simpleTimeStr)
        }
    }
    
}
