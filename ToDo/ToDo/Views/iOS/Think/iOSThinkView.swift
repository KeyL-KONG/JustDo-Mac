//
//  Think.swift
//  ToDo
//
//  Created by LQ on 2025/8/21.
//

import SwiftUI

struct iOSThinkView: View {
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel
    
    @State private var selectionIndex = 0
    let tabs = ["想法", "记录"]
    var body: some View {
        ZStack {
            iOSScrollTabViewWithGesture(tabs: tabs, selection: $selectionIndex) {
                if selectionIndex == 0 {
                    iOSReviewView()
                        .environmentObject(modelData)
                } else if selectionIndex == 1 {
                    RecordView()
                        .environmentObject(modelData)
                } 
            }
        }
    }
}
