//
//  ToDoItemRowView.swift
//  ToDo
//
//  Created by LQ on 2024/8/10.
//

import SwiftUI

struct ToDoItemRowView: View {
    
    @EnvironmentObject var modelData: ModelData
    //@ObservedObject var timerModel: TimerModel
    @State var item: EventItem
    
    var showImportance: Bool = true
    var showTag: Bool = true
    var showDeadline: Bool = false
    var isVerticalLayout: Bool = false
    
    var tag: ItemTag? {
        modelData.tagList.first { $0.id == item.tag }
    }
    
    var body: some View {
        if isVerticalLayout {
            VStack {
                HStack {
                    Label("", systemImage: (item.isFinish ? "checkmark.circle.fill" : "circle"))
                    Text(item.title).font(.system(size: 12))
                    Spacer()
                }
                
                HStack {
                    if showImportance {
                        tagView(title: item.importance.description, color: item.importance.titleColor)
                    }
                    
                    if let tag, showTag {
                        tagView(title: tag.title, color: tag.titleColor)
                    }
                    
                    if let planTime = item.planTime?.lastTimeOfDay,  showDeadline {
                        Spacer()
                        let days = planTime.daysBetweenDates(date: .now)
                        if planTime > .now {
                            Text("截止\(days)天").foregroundStyle(.red)
                        } else {
                            Text("过期\(days)天").foregroundStyle(.red)
                        }
                    }
                    Spacer()
                }.padding(.leading, 30)
            }
        } else {
            HStack {
                Label("", systemImage: (item.isFinish ? "checkmark.circle.fill" : "circle"))
                Text(item.title)
                
                if let tag, showTag {
                    tagView(title: tag.title, color: tag.titleColor)
                }
                
                if showImportance {
                    tagView(title: item.importance.description, color: item.importance.titleColor)
                }
                
                if let planTime = item.planTime?.lastTimeOfDay,  showDeadline {
                    Spacer()
                    let days = planTime.daysBetweenDates(date: .now)
                    if planTime > .now {
                        Text("截止\(days)天").foregroundStyle(.red)
                    } else {
                        Text("过期\(days)天").foregroundStyle(.red)
                    }
                }
                
                if item.isPlay {
                    Spacer()
                    Text("进行中").foregroundStyle(.blue)
//                    if let timingItem = timerModel.timingItem,  timerModel.isTiming, timerModel.timeSeconds > 0 {
//                        Spacer()
//                        Text(timerModel.timeSeconds.timeStr).foregroundStyle(.blue)
//                    } else {
//                        Spacer()
//                        Text("进行中").foregroundStyle(.blue)
//                    }
                }
                
            }
        }
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 8))
            .padding(EdgeInsets.init(top: 2, leading: 2, bottom: 2, trailing: 2))
            .background(color)
            .clipShape(Capsule())
    }
}
