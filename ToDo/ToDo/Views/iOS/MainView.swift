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
        case summary
        case task
        case todo
        case app
        case setting
        case project
        case habit
        case principle
        case timeline
        case reviewNote
        case read
        case think
    }
    
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel
    @State private var selection: Tab = .read
    @State var selectDate: Date = .now
    
    @State var showTimelineView: Bool = false
    @State var restoreItem: EventItem?
    @State var showRestoreAlert: Bool = false
    static var selectedTimeItem: TaskTimeItem? = nil
    
    var body: some View {
        TabView(selection: $selection) {
            iOSTaskProjectView(timerModel: timerModel)
                .environmentObject(modelData)
                .tag(Tab.task)
                .tabItem {
                    Label("任务", systemImage: "star")
                }
//            iOSProjectView(timerModel: timerModel)
//                .environmentObject(modelData)
//                .tag(Tab.project)
//                .tabItem {
//                    Label("项目", systemImage: "folder.fill")
//                }
            iOSSummaryView()
                .tag(Tab.summary)
                .tabItem {
                    Label("统计", systemImage: "tray.full.fill")
                }
            NavigationView {
                iOSReadView()
                    .environmentObject(modelData)
            }
                .tag(Tab.read)
                .tabItem {
                    Label("阅读", systemImage: "bookmark")
                }
            
            iOSThinkView(timerModel: timerModel)
                .environmentObject(modelData)
                .tag(Tab.think)
                .tabItem {
                    Label("想法", systemImage: "text.rectangle.page")
                }
            
//            iOSTaskTimelineView()
//                .environmentObject(modelData)
//                .tag(Tab.timeline)
//                .tabItem {
//                    Label("时间轴", systemImage: "list.bullet")
//                }
            NavigationView {
                iOSNoteView()
                    .environmentObject(modelData)
            }
            .tag(Tab.reviewNote)
            .tabItem {
                Label("笔记", systemImage: "list.bullet")
            }
            
        }
        .onAppear(perform: {
            checkTaskView()
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if !timerModel.isTiming {
                checkTaskView()
            }
        }
        .sheet(isPresented: $showTimelineView, content: {
            if let item = Self.selectedTimeItem {
                EditTimeLineRowView(showSheetView: $showTimelineView, item: item)
                    .environmentObject(modelData)
                    .presentationDetents([.height(450)])
            }
        })
        .overlay(alignment: .bottom, content: {
            if timerModel.isTiming {
                TimerDisplayView(timerModel: timerModel, showTimelineView: $showTimelineView)
            }
        })
        .alert("", isPresented: $showRestoreAlert) {
            Button("取消") {
                if let restoreItem {
                    restoreItem.isPlay = false
                    modelData.updateItem(restoreItem)
                }
                restoreItem = nil
            }
            Button("记录") {
                guard let restoreItem, let startTime = restoreItem.playTime, restoreItem.isPlay else { return }
                let timeItem = TaskTimeItem(startTime: startTime, endTime: .now, content: "")
                timeItem.eventId = restoreItem.id
                Self.selectedTimeItem = timeItem
                showTimelineView.toggle()
                
                restoreItem.isPlay = false
                modelData.updateItem(restoreItem)
                self.restoreItem = nil
            }
        } message: {
            if let restoreItem {
                Text("<\(restoreItem.title)> 进行中")
            }
            
        }

    }
}

extension MainView {
    
    func checkTaskView() {
        
        func check() {
            guard !timerModel.isTiming else { return }
            guard let task = modelData.itemList.filter({ $0.isPlay && $0.playTime != nil
            }).sorted(by: { first, second in
                return (first.playTime ?? .now) > (second.playTime ?? .now)
            }).first else {
                return
            }
            restoreItem = task
            self.showRestoreAlert.toggle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            check()
        }
    }
    
}

#endif
