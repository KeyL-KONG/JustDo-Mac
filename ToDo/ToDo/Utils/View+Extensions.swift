//
//  View+Extensions.swift
//  JustDo
//
//  Created by LQ on 2024/3/29.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    /// Checking Two dates are same
    func isSameDate(_ date: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: date2)
    }
    
}
