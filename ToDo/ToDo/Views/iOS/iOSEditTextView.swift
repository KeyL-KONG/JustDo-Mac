//
//  iOSEditTextView.swift
//  ToDo
//
//  Created by LQ on 2025/7/27.
//

import SwiftUI

struct iOSEditTextView: View {
    
    @Binding var text: String
    @FocusState private var isFocused: Bool
    var disappearCallback: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .font(.system(size: 14))
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(Color.init(hex: "#e8f6f3"))
                .frame(minHeight: 150)
                .cornerRadius(8)
                .focused($isFocused)
        }
        .onAppear {
            // 视图出现时自动设置焦点，触发键盘弹出
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
        .onDisappear {
            disappearCallback?()
        }
    }
}
