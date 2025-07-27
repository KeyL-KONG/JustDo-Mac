//
//  iOSEditTextView.swift
//  ToDo
//
//  Created by LQ on 2025/7/27.
//

import SwiftUI

struct iOSEditTextView: View {
    
    @Binding var text: String
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .font(.system(size: 14))
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(Color.init(hex: "#e8f6f3"))
                .frame(minHeight: 150)
                .cornerRadius(8)
        }
    }
}
