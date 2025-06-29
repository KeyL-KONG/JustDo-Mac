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
    
    @State var showTimelineView: Bool = false
    private static var selectedTimeItem: TaskTimeItem? = nil
    
    var body: some View {
        TabView(selection: $selection) {
            iOSTaskView(timerModel: timerModel)
                .environmentObject(modelData)
                .tag(Tab.task)
                .tabItem {
                    Label("任务", systemImage: "star")
                }
            iOSProjectView(timerModel: timerModel)
                .environmentObject(modelData)
                .tag(Tab.project)
                .tabItem {
                    Label("项目", systemImage: "folder.fill")
                }
        }
        .onAppear(perform: {
            
        })
        .sheet(isPresented: $showTimelineView, content: {
            if let item = Self.selectedTimeItem {
                EditTimeLineRowView(showSheetView: $showTimelineView, item: item)
                    .environmentObject(modelData)
                    .presentationDetents([.height(450)])
            }
        })
        .overlay(alignment: .bottom, content: {
            if timerModel.isTiming {
                HStack {
                    let tagColor = timingTagColor()
                    
                    if timerModel.title.count > 0 {
                        Text(timerModel.title).foregroundStyle(tagColor)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Text(timerModel.timeSeconds.secondAndMinTimeStr).bold().foregroundStyle(tagColor)
                }
                .contentShape(Rectangle())
                .onTapGesture(perform: {
                    let timeItem = TaskTimeItem(startTime: timerModel.startTime ?? .now, endTime: .now, content: "")
                    timeItem.eventId = timerModel.timingItem?.id ?? ""
                    Self.selectedTimeItem = timeItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.showTimelineView.toggle()
                    }
                    timerModel.stopTimer()
                })
                .padding(.horizontal, 25)
                .frame(height: 60)
                .offset(y: -55)
                .background {
                    ZStack {
                        Rectangle()
                            .frame(height: 60)
                            .cornerRadius(10)
                            .foregroundStyle(Color.init(hex: "fdfefe"))
                            .offset(y: -55)
                    }
                    .padding(.horizontal, 15)
                    .shadow(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5)
                    .shadow(color: .primary.opacity(0.06), radius: 5, x: -5, y: -5)
                }
            }
            
        })
    }
}

extension MainView {
    
    func timingTagColor() -> Color {
        let tagHexColor = modelData.tagList.first { $0.id == (timerModel.timingItem?.tag ?? "")
        }?.hexColor
        var tagColor: Color = .black
        if let tagHexColor  {
            tagColor = Color.init(hex: tagHexColor)
        }
        return tagColor
    }
    
}

#endif
