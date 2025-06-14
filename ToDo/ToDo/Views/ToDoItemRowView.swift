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
    @State var item: any BasicTaskProtocol
    
    var date: Date
    var selection: ToDoSection
    var showImportance: Bool = true
    var showTag: Bool = true
    var showDeadline: Bool = false
    var showMark: Bool = false
    var isVerticalLayout: Bool = false
    var showItemCount: Bool = false
    var showIsFinish: Bool = false
    
    var tag: ItemTag? {
        modelData.tagList.first { $0.id == item.tag }
    }
    
    var totalTime: Int {
        let taskTimeItems = modelData.taskTimeItems.filter { !$0.isPlan }
        if let item = self.item as? EventItem {
            if selection == .today || selection == .calendar {
                return item.itemTotalTime(with: modelData.itemList, taskItems: taskTimeItems, taskId: item.id, date: date)
            }
            return item.itemTotalTime(with: modelData.itemList, taskItems: taskTimeItems, taskId: item.id)
        } else if let reward = self.item as? RewardModel {
            return reward.totalTime(with: .day, intervals: reward.intervals, selectDate: date)
        } else {
            return 0
        }
    }
    
    var body: some View {
        if isVerticalLayout {
            VStack {
                if showIsFinish {
                    HStack {
                        if !item.isFinish {
                            Label("", systemImage: "circle")
                        }
                        Text(item.title).font(.system(size: 12))
                        Spacer()
                    }
                } else {
                    HStack {
                        Text(item.title).font(.system(size: 12))
                        Spacer()
                    }
                }
                
                HStack {
                    if let item = self.item as? EventItem, showImportance {
                        tagView(title: item.importance.simpleDescription, color: item.importance.titleColor)
                    }
                    
                    if let tag, showTag {
                        tagView(title: tag.title, color: tag.titleColor)
                    }
                    
                    if let item = self.item as? EventItem, item.needReview, !item.finishReview {
                        tagView(title: "待复盘", color: Color.init(hex: "e74c3c"))
                    }
                    if let item = self.item as? EventItem, item.isFinish, item.finishState != .normal {
                        tagView(title: item.finishState.description, color: Color.init(hex: item.finishState.titleColor))
                    }
                    else if let item = self.item as? EventItem, item.isTempInsert {
                        tagView(title: "临时", color: Color.init(hex: "f5b041"))
                    }
                    
                    if let item = self.item as? EventItem, let planTime = item.planTime?.lastTimeOfDay,  showDeadline {
                        Spacer()
                        let days = planTime.daysBetweenDates(date: .now)
                        if planTime > .now {
                            Text("截止\(days)天").foregroundStyle(.red)
                        } else {
                            Text("过期\(days)天").foregroundStyle(.red)
                        }
                    }
                    
                    if totalTime > 0 {
                        Text(totalTime.simpleTimeStr).foregroundStyle(Color.init(hex: "b3b6b7")).font(.system(size: 10))
                    }
                    
                    Spacer()
                }
                
//                if showMark, item.mark.count > 0 {
//                    HStack {
//                        Text(item.mark).font(.system(size: 10)).foregroundColor(Color.init(hex: "95a5a6"))
//                    }.padding(.leading, 30)
//                }
            }
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        LinearGradient(
                            colors: [Color.init(hex: "ebdef0"), Color.init(hex: "e8daef")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 4
                    )
            )
        }
        else {
            HStack {
                if item.isCollect {
                    Label("", systemImage: "star.fill")
                } else {
                    if item.planTime != nil && item.setPlanTime {
                        Label("", systemImage: (item.isFinish ? "checkmark.square.fill" : "square"))
                    } else {
                        if item.actionType == .task {
                            Label("", systemImage: "circle").tint(.accentColor)
                        } else {
                            Label("", systemImage: "star.square").tint(.accentColor)
                        }
                        
                    }
                }
                
                Text(item.title)
                
                if let item = self.item as? EventItem, let tag = modelData.noteTagList.first(where: { $0.id == item.projectStateId && item.projectStateId.count > 0
                }), item.setProjectState {
                    tagView(title: tag.content, color: .blue)
                }
                
                if let tag, showTag {
                    tagView(title: tag.title, color: tag.titleColor)
                }
                
                if let item = self.item as? EventItem, showImportance {
                    tagView(title: item.importance.description, color: item.importance.titleColor)
                }
                if let item = self.item as? EventItem, item.needReview, !item.finishReview {
                    tagView(title: "待复盘", color: Color.init(hex: "e74c3c"))
                }
                if let item = self.item as? EventItem, item.isFinish, item.finishState != .normal {
                    tagView(title: item.finishState.description, color: Color.init(hex: item.finishState.titleColor))
                }
                else if let item = self.item as? EventItem, item.isTempInsert {
                    tagView(title: "临时", color: Color.init(hex: "e59866"))
                }
                
                if showItemCount {
                    let totalCount = modelData.itemList.filter { ($0.fatherId.count > 0 && $0.fatherId == item.id) || ($0.projectId.count > 0 && $0.projectId == item.id)}.count
                    let finishCount = modelData.itemList.filter { ($0.fatherId.count > 0 && $0.fatherId == item.id) || ($0.projectId.count > 0 && $0.projectId == item.id) && $0.isFinish }.count
                    if totalCount > 0 {
                        Text(" \(finishCount)/\(totalCount)").foregroundStyle(Color.init(hex: "b3b6b7"))
                    }
                }
                
                if let item = self.item as? EventItem, let planTime = item.planTime?.lastTimeOfDay,  showDeadline {
                    Spacer()
                    let days = planTime.daysBetweenDates(date: .now)
                    if planTime > .now {
                        Text("截止\(days)天").foregroundStyle(.red)
                    } else {
                        Text("过期\(days)天").foregroundStyle(.red)
                    }
                }
                else if let item = self.item as? EventItem, item.isPlay {
                    Spacer()
                    Text("进行中").foregroundStyle(.blue)
                } else if totalTime > 0 {
                    Spacer()
                    Text(totalTime.simpleTimeStr).foregroundStyle(Color.init(hex: "b3b6b7"))
                } else {
                    Spacer()
                }
                
            }
        }
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 8))
            .padding(EdgeInsets.init(top: 2, leading: 4, bottom: 2, trailing: 4))
            .background(color)
            .clipShape(Capsule())
    }
}
