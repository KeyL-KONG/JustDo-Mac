//
//  ProgressBar.swift
//  ToDo
//
//  Created by LQ on 2025/5/17.
//

import SwiftUI

struct ProgressBar: View {
    
    @State var percent: CGFloat
    @State var progressColor: Color
    @State var showBgView: Bool = true
    @State var maxWidth: CGFloat = 200
    
    var progressValue: CGFloat {
        max(min(percent * maxWidth, maxWidth), 50)
    }
    
    var percentValue: Int {
        Int(percent * 100)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if showBgView {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .frame(width: maxWidth, height: 20)
                    .foregroundStyle(Color.black.opacity(0.1))
            }
        
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(width: progressValue, height: 20)
                .foregroundStyle(progressColor)
            
            Text("\(percentValue)%").foregroundStyle(.white).offset(x: 10).multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    ProgressBar(percent: 0.1, progressColor: .blue)
}
