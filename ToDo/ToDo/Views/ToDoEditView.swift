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
    var selectionChange: ((String) -> ())
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
    
    @State var setFixedEvent: Bool = false
    @State var fixedStartTime: Date = .now
    @State var fixedEndTime: Date = .now
    
    @State var intervals: [LQDateInterval] = []
    
    @State var isEdit: Bool = true
    
    @State var isExpandType: Bool = false
    
    @State var isExpandSubItems: Bool = false
    
    @State var isCollect: Bool = false
    
    @State var isQuick: Bool = false
    
    @State var isArchive: Bool = false
    
    @State var isTempInsert: Bool = false
    
    @State var needReview: Bool = false
    
    @State var finishReview: Bool = false
    
    @State var reviewDate: Date = .now
    
    @State var reviewText: String = ""
    
    @State var isEditingReview: Bool = false
    
    @State var isEditingMark: Bool = false
    
    var taskTimeItems: [TaskTimeItem] {
        modelData.taskTimeItems.filter { item in
            guard let selectItem else { return false }
            return item.eventId == selectItem.id && !item.isPlan
        }.sorted(by: {
            $0.startTime.timeIntervalSince1970 > $1.startTime.timeIntervalSince1970
        })
    }
    
    var taskPlanTimeItems: [TaskTimeItem] {
        modelData.taskTimeItems.filter { item in
            guard let selectItem else { return false }
            return item.eventId == selectItem.id && item.isPlan
        }.sorted(by: {
            $0.startTime.timeIntervalSince1970 > $1.startTime.timeIntervalSince1970
        })
    }
    
    var taskTotalTime: Int {
        taskTimeItems.compactMap { $0.interval}.reduce(0, +)
    }
    
    var fatherItem: EventItem? {
        guard let selectItem, let fatherItem = modelData.itemList.first(where: {
            ($0.id == selectItem.fatherId && selectItem.fatherId.count > 0) || ($0.id == selectItem.projectId && selectItem.projectId.count > 0)
        }) else { return nil }
        return fatherItem
    }
    
    var subItems: [EventItem] {
        guard let selectItem else { return [] }
        return modelData.itemList.filter { event in
            event.projectId == selectItem.id || event.fatherId == selectItem.id
        }.sorted { event1, event2 in
            if event1.isFinish != event2.isFinish {
                return !event1.isFinish
            }
            if let finishTime1 = event1.finishTime, let finishTime2 = event2.finishTime {
                return finishTime1.timeIntervalSince1970 > finishTime2.timeIntervalSince1970
            }
            return event1.createTime?.timeIntervalSince1970 ?? 0 > event2.createTime?.timeIntervalSince1970 ?? 0
        }
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
                    
                    if let fatherItem {
                        HStack {
                            Text("父任务：")
                            Text(fatherItem.title).foregroundStyle(.blue)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectionChange(fatherItem.id)
                        }
                    }
                    
                    if isFinish {
                        HStack {
                            Toggle(isOn: $isFinish) {
                                Text("是否已完成")
                            }
                            Spacer()
                            DatePicker(selection: $finishTime, displayedComponents: [.date, .hourAndMinute]) {
                                
                            }
                        }
                    } else {
                        Toggle(isOn: $isFinish) {
                            Text("是否已完成")
                        }
                    }
                    
                })
                
                Section(header: Text("设置属性"), content: {
                    Toggle(isOn: $isQuick) {
                        Text("设置为快捷事项")
                    }
                    
                    Toggle(isOn: $isCollect) {
                        Text("设置为收藏事项")
                    }
                    
                    Toggle(isOn: $isArchive) {
                        Text("是否归档")
                    }
                    
                    Toggle(isOn: $isTempInsert) {
                        Text("是否临时插入事项")
                    }
                    
                    Toggle(isOn: $needReview) {
                        Text("是否需要复盘")
                    }
            
                    if actionType == .project {
                        HStack {
                            Toggle(isOn: $setFixedEvent) {
                                Text("设置为固定事项")
                            }
                            
                            if setFixedEvent {
                                Spacer()
                                
                                DatePicker("start:", selection: $fixedStartTime, displayedComponents: [.hourAndMinute])
                                Spacer()
                                DatePicker("end:", selection: $fixedEndTime, displayedComponents: [.hourAndMinute])
                            }
                        }
                    }
                    
//                    if actionType == .project {
//                        HStack {
//                            Toggle(isOn: $setFinishTime) {
//                                Text("")
//                            }.labelsHidden()
//                            
//                            DatePicker(selection: $finishTime, displayedComponents: .date) {
//                                Text("设置为完成时间")
//                            }
//                        }
//
//                    }
                    
                })
                
                Section(header: HStack(content: {
                    Text("设置计划")
                    Spacer()
                    
                    if setPlanTime {
                        Button {
                            let item = TaskTimeItem(startTime: .now, endTime: .now, content: "")
                            item.eventId = selectItem?.id ?? ""
                            item.isPlan = true
                            modelData.updateTimeItem(item)
                        } label: {
                            Text("添加计划").font(.system(size: 14))
                        }
                    }
                    
                })) {
                    HStack {
                        Toggle(isOn: $setPlanTime) {
                            Text("")
                        }.labelsHidden()
                        
                        DatePicker(selection: $planTime, displayedComponents: .date) {
                            Text("设置为计划时间")
                        }
                    }
                    
                        ForEach(taskPlanTimeItems) { item in
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
                
                if subItems.count > 0 {
                    Section(header: HStack(content: {
                        Text("子任务(\(subItems.filter { $0.isFinish }.count)/\(subItems.count))")
                        Spacer()
                        Button {
                            isExpandSubItems = !isExpandSubItems
                        } label: {
                            let image = isExpandSubItems ? "chevron.down" : "chevron.right"
                            Image(systemName: image)
                        }
                    })) {
                        if isExpandSubItems {
                            ForEach(subItems, id: \.self.id) { item in
                                HStack {
                                    Label("", systemImage: (item.isFinish ? "checkmark.circle.fill" : "circle"))
                                    Text(item.title).foregroundStyle(.blue)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectionChange(item.id)
                                }
                            }
                        }
                    }
                }
                
                if needReview {
                    Section {
                        VStack {
                            HStack {
                                Toggle(isOn: $finishReview) {
                                    Text("是否完成复盘")
                                }
                                Spacer()
                                if finishReview {
                                    DatePicker(selection: $reviewDate, displayedComponents: [.date, .hourAndMinute]) {
                                        
                                    }
                                }
                            }
                            
                            HStack {
                                if isEditingReview {
                                    TextEditor(text: $reviewText)
                                        .font(.system(size: 14))
                                        .padding(10)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.init(hex: "#e8f6f3"))
                                        .frame(minHeight: 120)
                                        .cornerRadius(8)
                                } else {
                                    MarkdownWebView(reviewText)
                                }
                            }
                            .padding()
                            .background(isEditingReview ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
                            .cornerRadius(10)
                            
                        }
                    } header: {
                        HStack {
                            Text("复盘")
                            Spacer()
                            
                            Button("\(isEditingReview ? "完成" : "编辑")") {
                                self.isEditingReview.toggle()
                                if !self.isEditingReview {
                                    self.saveTask()
                                }
                            }
                        }
                    }

                }
                
                Section {
                    VStack {
                        if isEditingMark {
                            TextEditor(text: $mark)
                                .font(.system(size: 14))
                                .padding(10)
                                .scrollContentBackground(.hidden)
                                .background(Color.init(hex: "#e8f6f3"))
                                .frame(minHeight: 120)
                                .cornerRadius(8)
                        } else {
                            MarkdownWebView(mark)
                        }
                    }
                    .padding()
                    .background(isEditingMark ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
                    .cornerRadius(10)
                } header: {
                    HStack {
                        Text("备注")
                        Spacer()
                        
                        // 新增展开按钮
                        Button {
                            showPreviewWindow()
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .help("在新窗口预览")
                        
                        Button("\(isEditingMark ? "完成" : "编辑")") {
                            self.isEditingMark.toggle()
                            if !self.isEditingMark {
                                self.saveTask()
                            }
                        }
                    }
                }

                
                Section(header:
                    HStack(alignment: .center) {
                        Text("事件记录")
                        Text("\(taskTotalTime.simpleTimeStr)")
                        Spacer()
                        Button {
                            let item = TaskTimeItem(startTime: .now, endTime: .now, content: "")
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
        })
        .onChange(of: setPlanTime, { oldValue, newValue in
            print("set plan time")
            //saveTask()
        })
        .onChange(of: isCollect, { _, _ in
            //saveTask()
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
//                if let finishTime = selectedItem.finishTime {
//                    self.finishTime = finishTime
//                    setFinishTime = true
//                }
                isFinish = selectedItem.isFinish
                finishTime = selectedItem.finishTime ?? .now
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
                isCollect = selectedItem.isCollect
                isQuick = selectedItem.quickEvent
                isExpandType = selectedItem.tag.isEmpty
                isArchive = selectedItem.isArchive
                isTempInsert = selectedItem.isTempInsert
                needReview = selectedItem.needReview
                finishReview = selectedItem.finishReview
                reviewDate = selectedItem.reviewDate ?? .now 
                reviewText = selectedItem.reviewText
                setFixedEvent = selectedItem.isFixedEvent
                fixedStartTime = selectedItem.fixedStartTime ?? .now
                fixedEndTime = selectedItem.fixedEndTime ?? .now
            } else {
                selectedTag = modelData.tagList.first?.title ?? ""
                actionType = EventActionType.task
                isExpandType = true
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
        selectedItem.setPlanTime = setPlanTime
        if setPlanTime {
            selectedItem.planTime = planTime
        } else {
            selectedItem.planTime = nil
        }
        
        selectedItem.isCollect = isCollect
        selectedItem.finishTime = finishTime
        selectedItem.importance = importantTag
        selectedItem.intervals = intervals
        selectedItem.eventType = eventType
        selectedItem.isFinish = isFinish
        selectedItem.rewardId = rewardItem?.id ?? ""
        selectedItem.actionType = actionType
        selectedItem.isArchive = isArchive
        selectedItem.isTempInsert = isTempInsert
        selectedItem.needReview = needReview
        selectedItem.reviewDate = reviewDate
        selectedItem.reviewText = reviewText
        selectedItem.finishReview = finishReview
        selectedItem.isFixedEvent = setFixedEvent
        selectedItem.fixedStartTime = fixedStartTime
        selectedItem.fixedEndTime = fixedEndTime
        selectedItem.quickEvent = isQuick
        modelData.updateItem(selectedItem)
        updateEvent()
    }

    // 添加环境变量
    @Environment(\.openWindow) private var openWindow

    // 修改按钮响应方法
    private func showPreviewWindow() {
        guard let selectItem else { return }
        openWindow(id: "markdown-preview", value: selectItem)
    }
    
}

