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
    @State var actionType: EventActionType = .task
    @State var actionList: [EventActionType] = [.task, .project, .tag]
    
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
    
    @State var selectProject: String = "" {
        didSet {
            print("select project: \(selectProject)")
        }
    }
    var projectListTitle: [String] {
        let tagId = modelData.tagList.filter{ $0.title == selectedTag }.first?.id ?? ""
        return ["无"] + modelData.itemList.filter { $0.tag == tagId && $0.actionType == .project}.compactMap { $0.title }
    }
    
    @State var selectFather: String = "无"
    var fatherListTitle: [String] {
        guard selectProject.count > 1, let selectItem = self.selectItem, let projectItem = modelData.itemList.first(where: { $0.title == selectProject && $0.actionType == .project }) else { return [] }
        return ["无"] + modelData.itemList.filter { $0.projectId == projectItem.id && $0.id != selectItem.id }.sorted(by: { first, second in
            return first.childrenIds.count > second.childrenIds.count
        }).compactMap { return $0.childrenIds.count > 0 ? "\($0.title) (\($0.childrenIds.count))" : "\($0.title)" }
    }
    
    @State var isFinish: Bool = false
    @State var planTime = Date.now
    
    @State var mark: String = ""
    @State public var setPlanTime: Bool = false
    
    @State var setFinishTime: Bool = false
    @State var finishTime: Date = .now
    
    @State var intervals: [LQDateInterval] = []
    
    @State var isEdit: Bool = true
    
    @State var isExpandType: Bool = false
    
    var taskTimeItems: [TaskTimeItem] {
        modelData.taskTimeItems.filter { item in
            guard let selectItem else { return false }
            return item.eventId == selectItem.id
        }.sorted(by: {
            $0.startTime.timeIntervalSince1970 > $1.startTime.timeIntervalSince1970
        })
    }
    
    var taskTotalTime: Int {
        taskTimeItems.compactMap { $0.interval}.reduce(0, +)
    }
    
    var body: some View {
        VStack {
            List {
                
                Section(header: HStack {
                    Text("事项类型")
                    Spacer()
                    Button {
                        isExpandType = !isExpandType
                    } label: {
                        let image = isExpandType ? "chevron.down" : "chevron.right"
                        Image(systemName: image)
                    }
                }, content: {
                    TextField("任务标题", text: $titleText)
                    
                    if isExpandType {
                        Picker("选择类型", selection: $actionType) {
                            ForEach(actionList, id: \.self) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        
                        Picker("选择标签", selection: $selectedTag) {
                            ForEach(modelData.tagList.sorted(by: { first, second in
                                let eventList = modelData.itemList
                                return eventList.filter { $0.tag == first.id }.count > eventList.filter { $0.tag == second.id}.count
                            }).map({$0.title}), id: \.self) { title in
                                if let tag = modelData.tagList.first(where: { $0.title == title}) {
                                    Text(tag.title).tag(tag)
                                }
                            }
                        }
                        
                        if projectListTitle.count > 1 {
                            Picker("选择项目", selection: $selectProject) {
                                ForEach(projectListTitle, id: \.self) { projectTitle in
                                    Text(projectTitle).tag(projectTitle)
                                }
                            }
                        }
                        
                        if fatherListTitle.count > 1 {
                            Picker("选择父任务", selection: $selectFather) {
                                ForEach(fatherListTitle, id: \.self) { fatherTitle in
                                    Text(fatherTitle).tag(fatherTitle)
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
                    }
                    
                    
                    Toggle(isOn: $isFinish) {
                        Text("是否已完成")
                    }
                })
                
                Section(header: Text("设置时间"), content: {
                    HStack {
                        Toggle(isOn: $setPlanTime) {
                            Text("")
                        }.labelsHidden()
                        
                        DatePicker(selection: $planTime, displayedComponents: .date) {
                            Text("\(actionType == .task ? "设置为计划时间" : "设置为开始时间")")
                        }
                    }
                    
                    if actionType == .project {
                        HStack {
                            Toggle(isOn: $setFinishTime) {
                                Text("")
                            }.labelsHidden()
                            
                            DatePicker(selection: $finishTime, displayedComponents: .date) {
                                Text("设置为完成时间")
                            }
                        }

                    }
                    
                })
                
                Section(header:
                    HStack(alignment: .center) {
                        Text("事件记录")
                        Text("\(taskTotalTime.simpleTimeStr)")
                        Spacer()
                        Button {
                            let item = TaskTimeItem(startTime: .now, endTime: .now, content: "新记录")
                            item.eventId = selectItem?.id ?? ""
                            modelData.updateTimeItem(item)
                        } label: {
                            Text("添加记录").font(.system(size: 14))
                        }
                    }
                ) {
                    ForEach(taskTimeItems) { item in
                        TimeLineRowView(
                            item: item,
                            isEditing: Binding(
                                get: { return modelData.isEditing(id: item.id) },
                                set: { value in
                                    modelData.markEdit(id: item.id, edit: value)
                                }
                            )
                        )
                        .contextMenu {
                            Button(role: .destructive) {
                                // 添加删除确认弹窗
                                modelData.deleteTimeItem(item)
                            } label: {
                                Text("删除").foregroundColor(.red)
                            }
                
                        }
                    }
                }
//                
//                //if intervals.count > 0 {
//                    Section(header:
//                        HStack(alignment: .center) {
//                            Text("统计时间")
//                            Spacer()
//                            Button {
//                                let interval = LQDateInterval(start: .now, end: .now)
//                                self.intervals = [interval] + intervals
//                                print("add time interval")
//                            } label: {
//                                Text("添加时间").font(.system(size: 14))
//                            }
//                        }
//                    , content: {
//                        ForEach(intervals.indices, id: \.self) { index in
//                            let interval = intervals[index]
//                            DateIntervalView(interval: interval, index: index) { change in
//                                intervals[index] = change
//                            }
//                            .contextMenu {
//                                Button {
//                                    self.intervals.remove(at: index)
//                                    self.saveTask()
//                                } label: {
//                                    Text("删除").foregroundStyle(.red)
//                                }
//                            }
//                        }
//                        .id(UUID())
//                    })
//                //}
                
            }
        }
        .onChange(of: modelData.toggleToRefresh, { oldValue, newValue in
            if let selectItem, let item = modelData.itemList.first(where: { $0.id == selectItem.id
            }) {
                self.intervals = item.intervals.sorted(by: { $0.end.timeIntervalSince1970 >= $1.end.timeIntervalSince1970
                })
            }
        })
        .onChange(of: isFinish, { oldValue, newValue in
            saveTask()
        })
        .toolbar(content: {
            Spacer()
            Button("保存") {
                saveTask()
            }.foregroundColor(.blue)
        })
        .onAppear {
            print("edit view appear")
            modelData.removeEditStates()
            if let selectedItem = selectItem {
                titleText = selectedItem.title
                mark = selectedItem.mark
                selectedTag = modelData.tagList.filter({ $0.id == selectedItem.tag}).first?.title ?? ""
                importantTag = selectedItem.importance
                intervals = selectedItem.intervals.sorted(by: { $0.end.timeIntervalSince1970 >= $1.end.timeIntervalSince1970
                })
                eventType = selectedItem.eventType
                if let planTime = selectedItem.planTime {
                    self.planTime = planTime
                    setPlanTime = true
                }
                if let finishTime = selectedItem.finishTime {
                    self.finishTime = finishTime
                    setFinishTime = true
                }
                isFinish = selectedItem.isFinish
                selectReward = modelData.rewardList.filter({ $0.id == selectedItem.rewardId }).first?.title ?? "无"
                selectProject = modelData.itemList.filter { $0.id == selectedItem.projectId}.first?.title ?? "无"
                if let fatherItem = modelData.itemList.filter({ $0.id == selectedItem.fatherId}).first {
                    selectFather = fatherItem.childrenIds.count > 0 ? "\(fatherItem.title) (\(fatherItem.childrenIds.count))" : "\(fatherItem.title)"
                } else {
                    selectFather = "无"
                }
                actionType = selectedItem.actionType
                if selectedItem.mark.count > 0 {
                    self.isEdit = false
                }
            } else {
                selectedTag = modelData.tagList.first?.title ?? ""
                actionType = EventActionType.task
            }
        }
    }
    
    
    func saveTask() {
        guard let selectedItem = selectItem else {
            return
        }
        let rewardItem = modelData.rewardList.filter { $0.title == selectReward }.first
        let tag = modelData.tagList.filter({ $0.title == selectedTag}).first?.id ?? ""
        
        if let projectItem = modelData.itemList.filter({ $0.title == selectProject}).first {
            selectedItem.projectId = projectItem.id
            if !projectItem.childrenIds.contains(selectedItem.id) {
                projectItem.childrenIds.append(selectedItem.id)
            }
            modelData.updateItem(projectItem)
        }
        
        let selectFatherTitle = selectFather.replacingOccurrences(of: " \\(\\d+\\)", with: "", options: .regularExpression)
        if let fatherItem = modelData.itemList.filter({ $0.title == selectFatherTitle }).first {
            selectedItem.fatherId = fatherItem.id
            fatherItem.childrenIds.append(selectedItem.id)
            modelData.updateItem(fatherItem)
        }
        
        selectedItem.title = titleText
        selectedItem.tag = tag
        selectedItem.mark = mark
        if setPlanTime {
            selectedItem.planTime = planTime
        } else {
            //selectedItem.disablePlanTime = true
            selectedItem.planTime = nil
        }
        if setFinishTime {
            selectedItem.finishTime = finishTime
        }
        selectedItem.importance = importantTag
        selectedItem.intervals = intervals
        selectedItem.eventType = eventType
        selectedItem.isFinish = isFinish
        selectedItem.rewardId = rewardItem?.id ?? ""
        selectedItem.actionType = actionType
        modelData.updateItem(selectedItem)
        updateEvent()
    }
    
}
