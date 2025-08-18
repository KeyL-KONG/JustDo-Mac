//
//  iOSNoteView.swift
//  ToDo
//
//  Created by LQ on 2025/8/17.
//

import SwiftUI

struct iOSNoteView: View {
    @EnvironmentObject var modelData: ModelData
    
    
    @State private var selectionIndex = 0
    let tabs = ["笔记", "复习"]
    
    var body: some View {
        iOSScrollTabViewWithGesture(tabs: tabs, selection: $selectionIndex) {
            if selectionIndex == 0 {
                iOSNoteListView()
                    .environmentObject(modelData)
            } else {
                iOSReviewNoteView()
                    .environmentObject(modelData)
            }
        }
    }
    
}
