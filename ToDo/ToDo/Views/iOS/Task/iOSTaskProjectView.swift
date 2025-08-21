//
//  iOSTaskProjectView.swift
//  ToDo
//
//  Created by LQ on 2025/8/21.
//

import SwiftUI

struct iOSTaskProjectView: View {
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel
    
    @State private var selectionIndex = 0
    let tabs = ["任务", "固定", "项目"]
    var body: some View {
        ZStack {
            iOSScrollTabViewWithGesture(tabs: tabs, selection: $selectionIndex) {
                if selectionIndex == 0 {
                    iOSTaskView(timerModel: timerModel)
                        .environmentObject(modelData)
                } else if selectionIndex == 1 {
                    iOSProjectView(timerModel: timerModel)
                        .environmentObject(modelData)
                } else {
                    iOSProjectView(timerModel: timerModel, showFixedEventOnly: false)
                        .environmentObject(modelData)
                }
            }
        }
    }
}
