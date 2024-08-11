//
//  ToDoEditView.swift
//  ToDo
//
//  Created by LQ on 2024/8/10.
//

import SwiftUI
import LeanCloud

struct ToDoEditView: View {
    
    @EnvironmentObject var modelData: ModelData
    var selectItem: EventItem?
    var updateEvent: (() -> ())
    
    @State var titleText: String = ""
    @State var selectedTag: String = ""
    
    @State var importantTag: ImportanceTag = .mid
    @State var importanceList: [ImportanceTag] = [.mid, .low, .high]
    
    @State var eventType: EventValueType = .num
    @State var eventTypeList: [EventValueType] = [.num, .time, .count]
    
    @State var selectReward: String = ""
    var rewardListTitle: [String] {
        let tagId = modelData.tagList.filter{ $0.title == selectedTag }.first?.id ?? ""
        return ["无"] + modelData.rewardList.filter { $0.tag == tagId }.compactMap { $0.title }
    }
    
    @State var isFinish: Bool = false
    @State var planTime = Date.now
    
    @State var mark: String = ""
    @State public var setPlanTime: Bool = false
    
    @State var intervals: [LQDateInterval] = []
    
    var body: some View {
        VStack {
            List {
                Section {
                    TextField("任务标题", text: $titleText)
                    
                    Picker("选择标签", selection: $selectedTag) {
                        ForEach(modelData.tagList.map({$0.title}), id: \.self) { title in
                            if let tag = modelData.tagList.first(where: { $0.title == title}) {
                                Text(tag.title).tag(tag)
                            }
                        }
                    }
                    
                    Picker("选择优先级", selection: $importantTag) {
                        ForEach(importanceList, id: \.self) { tag in
                            Text(tag.description).tag(tag)
                        }
                    }
                    
                    Picker("选择事项类型", selection: $eventType) {
                        ForEach(eventTypeList, id: \.self) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    
                    Picker("选择积分事项", selection: $selectReward) {
                        ForEach(rewardListTitle, id: \.self) { rewardTitle in
                            Text(rewardTitle).tag(rewardTitle)
                        }
                    }
                    
                    Toggle(isOn: $isFinish) {
                        Text("是否已完成")
                    }
                    
                }
                
                Section(header: Text("设置时间"), content: {
                    
                    DatePicker(selection: $planTime, displayedComponents: .date) {
                        Text("Date")
                    }
                    
                    Toggle(isOn: $setPlanTime) {
                        Text("设置为计划时间")
                    }
    
                })
                
                Section(header: Text("备注")) {
                    TextEditor(text: $mark)
                        .padding(5)
                        .scrollContentBackground(.hidden)
                        .background(Color.init(hex: "#D6EAF8"))
                        .frame(minHeight: 50)
                        .cornerRadius(8)
                }
                
                if intervals.count > 0 {
                    Section(header:
                        HStack(alignment: .center) {
                            Text("统计时间")
                            Spacer()
                            Button {
                                let interval = LQDateInterval(start: .now, end: .now)
                                self.intervals = [interval] + intervals
                                print("add time interval")
                            } label: {
                                Text("添加时间").font(.system(size: 14))
                            }
                        }
                    , content: {
                        ForEach(intervals.indices, id: \.self) { index in
                            let interval = intervals[index]
                            DateIntervalView(interval: interval, index: index) { change in
                                intervals[index] = change
                            }
                        }
                        .onDelete { indexSet in
                            intervals.remove(atOffsets: indexSet)
                        }
                        .id(UUID())
                    })
                }
                
            }
        }
        .toolbar(content: {
            Spacer()
            Button("保存") {
                saveTask()
            }.foregroundColor(.blue)
        })
        .onAppear {
            if let selectedItem = selectItem {
                titleText = selectedItem.title
                mark = selectedItem.mark
                selectedTag = modelData.tagList.filter({ $0.id == selectedItem.tag}).first?.title ?? ""
                importantTag = selectedItem.importance
                intervals = selectedItem.intervals.sorted(by: { $0.start.timeIntervalSince1970 >= $1.start.timeIntervalSince1970
                })
                eventType = selectedItem.eventType
                if let planTime = selectedItem.planTime {
                    self.planTime = planTime
                    setPlanTime = true
                }
                isFinish = selectedItem.isFinish
                selectReward = modelData.rewardList.filter({ $0.id == selectedItem.rewardId }).first?.title ?? "无"
            } else {
                selectedTag = modelData.tagList.first?.title ?? ""
            }
        }
    }
    
    
    func saveTask() {
        guard let selectedItem = selectItem else {
            return
        }
        let rewardItem = modelData.rewardList.filter { $0.title == selectReward }.first
        let tag = modelData.tagList.filter({ $0.title == selectedTag}).first?.id ?? ""
        
        selectedItem.title = titleText
        selectedItem.tag = tag
        selectedItem.mark = mark
        if setPlanTime {
            selectedItem.planTime = planTime
        }
        selectedItem.importance = importantTag
        selectedItem.intervals = intervals
        selectedItem.eventType = eventType
        selectedItem.isFinish = isFinish
        selectedItem.rewardId = rewardItem?.id ?? ""
        modelData.updateItem(selectedItem)
        updateEvent()
    }
    
}
