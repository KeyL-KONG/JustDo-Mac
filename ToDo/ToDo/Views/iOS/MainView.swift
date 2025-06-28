//
//  MainView.swift
//  ToDo
//
//  Created by LQ on 2025/6/28.
//

import SwiftUI

#if os(iOS)
struct MainView: View {
    
    enum Tab {
        case reward
        case task
        case todo
        case app
        case setting
        case project
        case habit
        case principle
    }
    
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel
    @State private var selection: Tab = .task
    @State var selectDate: Date = .now
    
    var body: some View {
        TabView(selection: $selection) {
//            PlanView(timerModel: timerModel, selectItemID: .constant(""), timeTab: .day, currentDate: $selectDate, selectionMode: .constant(.synthesis))
//                .environmentObject(modelData)
//                .tag(Tab.task)
//                .tabItem {
//                    Label("任务", systemImage: "star")
//                }
            
            iOSTaskView(timerModel: timerModel)
                .environmentObject(modelData)
                .tag(Tab.task)
                .tabItem {
                    Label("任务", systemImage: "star")
                }
        }
        
    }
}

#endif
