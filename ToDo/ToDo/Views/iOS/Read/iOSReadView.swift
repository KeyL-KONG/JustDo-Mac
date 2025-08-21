//
//  iOSReadView.swift
//  ToDo
//
//  Created by LQ on 2025/8/18.
//
#if os(iOS)
import SwiftUI

struct iOSReadView: View {
    @EnvironmentObject var modelData: ModelData
    
    
    @State private var selectionIndex = 0
    let tabs = ["整理", "列表"]
    
    var body: some View {
        iOSScrollTabViewWithGesture(tabs: tabs, selection: $selectionIndex) {
            if selectionIndex == 0 {
                iOSReadReviewView()
                    .environmentObject(modelData)
            } else {
                iOSReadTimeView()
                    .environmentObject(modelData)
            }
        }
    }
}
#endif
