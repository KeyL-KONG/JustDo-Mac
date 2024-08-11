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
                //.datePickerStyle(.compact)
                .scaleEffect(0.6)
                .frame(width: 100)
                .onChange(of: interval.start) { newValue in
                    intervalChange(LQDateInterval(start: newValue, end: interval.end))
                    print(newValue)
                }
                Spacer()
            Text("-").font(.system(size: 10))
            Spacer()
            DatePicker("", selection: $interval.end, displayedComponents: [.date, .hourAndMinute])
                //.datePickerStyle(.compact)
                .scaleEffect(0.6)
                .frame(width: 100)
                .onChange(of: interval.end) { newValue in
                    intervalChange(LQDateInterval(start: interval.start, end: newValue))
                    print(newValue)
                }
        }.frame(width: 240)
    }
    
}
