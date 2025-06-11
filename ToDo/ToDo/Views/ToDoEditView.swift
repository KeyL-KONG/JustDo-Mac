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
    @State var selectItem: EventItem?
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
    
    @State var setDeadlineTime: Bool = false
    @State var dealineTime: Date = .now
    
    @State var setFinishTime: Bool = false
    @State var finishTime: Date = .now
    
    @State var setFixedEvent: Bool = false
    @State var fixedStartTime: Date = .now
    @State var fixedEndTime: Date = .now
    
    @State var intervals: [LQDateInterval] = []
    
    @State var isEdit: Bool = true
    
    @State var isExpandType: Bool = false
    
    @State var isExpandProperty: Bool = false
    
    @State var isExpandPersonal: Bool = false
    
    @State var isExpandSubItems: Bool = false
    
    @State var isCollect: Bool = false
    
    @State var isQuick: Bool = false
    
    @State var isArchive: Bool = false
    
    @State var isTempInsert: Bool = false
    
    @State var needReview: Bool = false
    
    @State var setKeyEvent: Bool = false
    
    @State var setIsProgress: Bool = false
    
    @State var progressValue: String = "0"
    
    @State var finishReview: Bool = false
    
    @State var reviewDate: Date = .now
    
    @State var reviewText: String = ""
    
    @State var isEditingReview: Bool = false
    
    @State var isEditingStartText: Bool = false
    
    @State var isEditingMark: Bool = false
    
    @State var finishState: String = ""
    
    @State var startText: String = ""
    
    @State var showPersonalAlert: Bool = false
    static var selectPersonalTag: PersonalTag?
    
    @State var showAddNote: Bool = true
    @State var hasNoteItem: Bool = false
    @State var toggleToRefresh: Bool = false
    @State var cursorPosition: Int = 0
    
    var finishStateTitleList: [String] = [FinishState.bad.description, FinishState.normal.description, FinishState.good.description]
    
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
    
    struct EventItemPersonalItem {
        let type: PersonalTagType
        let num: Int
        let tag: PersonalTag
    }
    
    var personalItems: [EventItemPersonalItem] {
        guard let eventId = selectItem?.id else { return [] }
        var items = [EventItemPersonalItem]()
        modelData.personalTagList.forEach { tag in
            if let num = tag.goodEvents[eventId] {
                items.append(.init(type: .good, num: num, tag: tag))
            } else if let num = tag.badEvents[eventId] {
                items.append(.init(type: .bad, num: num, tag: tag))
            }
        }
        return items
    }
    
    var body: some View {
        VStack {
            if toggleToRefresh {
                Text("")
            } else {
                Text("")
            }
            List {
            
                Section(header: HStack {
                    Text("事项类型")
                    Spacer()
                    
                    Button("\(isEditingStartText ? "完成" : "编辑")") {
                        self.isEditingStartText.toggle()
                        if !self.isEditingStartText {
                            self.saveTask()
                        }
                    }
                    
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
                    
                    if startText.count > 0 || isEditingStartText {
                        HStack {
                            if isEditingStartText {
                                TextEditor(text: $startText)
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.init(hex: "#e8f6f3"))
                                    .frame(minHeight: 120)
                                    .cornerRadius(8)
                            } else {
                                MarkdownWebView(startText, itemId: (selectItem?.id ?? ""))
                            }
                        }
                        .padding()
                        .background(isEditingStartText ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
                        .cornerRadius(10)
                    }
                    
                })
                
                if isFinish {
                    Section {
                        Picker("选择完成情况", selection: $finishState) {
                            ForEach(finishStateTitleList, id: \.self) { state in
                                Text(state).tag(state)
                            }
                        }
                        
                        Toggle(isOn: $needReview) {
                            Text("是否需要复盘")
                        }
                        
                        if needReview {
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
                                MarkdownWebView(reviewText, itemId: (selectItem?.id ?? ""))
                            }
                        }
                        .padding()
                        .background(isEditingReview ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
                        .cornerRadius(10)
                    } header: {
                        HStack {
                            Text("复盘事项")
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
                    if personalItems.count > 0, isExpandPersonal {
                        LazyVStack(alignment: .leading) {
                            ForEach(personalItems, id: \.self.tag.id) { item in
                                let color = item.type == .good ? item.tag.goodColor : item.tag.badColor
                                let title = "\(item.tag.tag) \(item.num.symbolStr)"
                                tagView(title: title, color: color)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        Self.selectPersonalTag = item.tag
                                        self.showPersonalAlert.toggle()
                                    }
                            }
                        }
                    }
                } header: {
                    HStack {
                        let title = personalItems.count > 0 ? "设置关联（\(personalItems.count)）" : "设置关联"
                        Text(title)
                        Spacer()
                        
                        Button {
                            Self.selectPersonalTag = nil
                            showPersonalAlert.toggle()
                        } label: {
                            Text("添加关联").font(.system(size: 14))
                        }
                        
                        if personalItems.count > 0 {
                            Button {
                                isExpandPersonal = !isExpandPersonal
                            } label: {
                                let image = isExpandPersonal ? "chevron.down" : "chevron.right"
                                Image(systemName: image)
                            }
                        }
                    }
                }

                
                Section(header: HStack(content: {
                    Text("设置属性")
                    Spacer()
                    Button {
                        isExpandProperty = !isExpandProperty
                    } label: {
                        let image = isExpandProperty ? "chevron.down" : "chevron.right"
                        Image(systemName: image)
                    }
                }), content: {
                    if isExpandProperty {
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
                        
                        Toggle(isOn: $setKeyEvent) {
                            Text("是否设置为关键事项")
                        }
                        
                        HStack {
                            Toggle(isOn: $setIsProgress) {
                                Text("是否设置进度值")
                            }
                            Spacer()
                            if setIsProgress {
                                TextField("", text: $progressValue).frame(maxWidth: 30)
                                    .border(.gray, width: 1)
                                    .multilineTextAlignment(.trailing)
                                Text("%")
                            }
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
                    }
                    
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
                            let title = actionType == .task ? "设置为计划时间" : "设置为开始时间"
                            Text(title)
                        }
                    }
                    
                    if let selectItem, selectItem.actionType != .task, setPlanTime {
                        HStack {
                            Toggle(isOn: $setDeadlineTime) {
                                Text("")
                            }.labelsHidden()
                            
                            DatePicker(selection: $dealineTime, displayedComponents: .date) {
                                Text("设置为截止时间")
                            }
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
                
                Section {
                    let disableMark = !isEditingMark && mark.isEmpty
                    if !disableMark {
                        VStack {
                            if isEditingMark {
                                CustomTextEditor(text: $mark, cursorPosition: $cursorPosition) { pos in
                                    self.cursorPosition = pos
                                }
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.init(hex: "#e8f6f3"))
                                    .frame(minHeight: 120)
                                    .cornerRadius(8)
                            } else if mark.count > 0 {
                                MarkdownWebView(mark, itemId: (selectItem?.id ?? ""))
                            }
                        }
                        .padding()
                        .background(isEditingMark ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
                        .cornerRadius(10)
                    }
                } header: {
                    HStack {
                        Text("备注")
                        if hasNoteItem {
                            tagView(title: "note", color: .blue, size: 8, verPadding: 5, horPadding: 2.5)
                        }
                        Spacer()
                        
                        if mark.count > 0, showAddNote {
                            Button("转为笔记") {
                                let note = NoteModel()
                                note.title = titleText
                                note.content = mark
                                note.convertId = selectItem?.id ?? ""
                                modelData.updateNote(note)
                                showAddNote = false
                                hasNoteItem = true
                            }
                        }
                        
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
        .onChange(of: modelData.updateNoteId, { _, noteId in
            if let selectItem, let note = modelData.noteList.first(where: { $0.id == noteId }), selectItem.id == note.convertId {
                updateEventData()
            }
        })
        .onChange(of: modelData.updateEventId, { _, eventId in
            if let selectItem, selectItem.id == eventId {
                updateEventData()
            }
        })
        .onChange(of: modelData.toggleToRefresh, { oldValue, newValue in
            if let selectItem, let item = modelData.itemList.first(where: { $0.id == selectItem.id
            }) {
                self.intervals = item.intervals.sorted(by: { $0.end.timeIntervalSince1970 >= $1.end.timeIntervalSince1970
                })
            }
        })
        .onChange(of: isFinish, { oldValue, newValue in
        })
        .toolbar(content: {
            Spacer()
            Button("保存") {
                saveTask()
            }.foregroundColor(.blue)
        })
        .sheet(isPresented: $showPersonalAlert, content: {
            if let itemId = selectItem?.id {
                PersonalTagWindowView(isPresented: $showPersonalAlert, itemId: itemId, personalTag: Self.selectPersonalTag)                 .environmentObject(modelData)
            }
        })
        .onAppear {
            print("edit view appear")
            modelData.removeEditStates()
            if let selectedItem = selectItem {
                updateEventData()
            } else {
                selectedTag = modelData.tagList.first?.title ?? ""
                actionType = EventActionType.task
                isExpandType = true
            }
            self.addObservers()
        }
    }
    
    func updateEventData() {
        guard let selectedItem = self.selectItem else { return }
        titleText = selectedItem.title
        if let noteItem = modelData.noteList.first(where: { $0.convertId == selectedItem.id
        }) {
            mark = noteItem.content
            hasNoteItem = true
        } else {
            mark = selectedItem.mark
        }
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
        setDeadlineTime = selectedItem.setDealineTime
        dealineTime = selectedItem.deadlineTime ?? .now
        isCollect = selectedItem.isCollect
        isQuick = selectedItem.quickEvent
        isExpandType = selectedItem.tag.isEmpty
        isArchive = selectedItem.isArchive
        isTempInsert = selectedItem.isTempInsert
        needReview = selectedItem.needReview
        setKeyEvent = selectedItem.isKeyEvent
        finishReview = selectedItem.finishReview
        reviewDate = selectedItem.reviewDate ?? .now
        reviewText = selectedItem.reviewText
        setFixedEvent = selectedItem.isFixedEvent
        fixedStartTime = selectedItem.fixedStartTime ?? .now
        fixedEndTime = selectedItem.fixedEndTime ?? .now
        setIsProgress = selectedItem.setProgress
        progressValue = selectedItem.progressValue.stringValue ?? "0"
        finishState = selectedItem.finishState.description
        showAddNote = !modelData.noteList.contains(where: { $0.convertId == selectedItem.id })
        startText = selectedItem.startText
        
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
        selectedItem.isKeyEvent = setKeyEvent
        selectedItem.reviewDate = reviewDate
        selectedItem.reviewText = reviewText
        selectedItem.finishReview = finishReview
        selectedItem.isFixedEvent = setFixedEvent
        selectedItem.fixedStartTime = fixedStartTime
        selectedItem.fixedEndTime = fixedEndTime
        selectedItem.quickEvent = isQuick
        selectedItem.setProgress = setIsProgress
        selectedItem.progressValue = Int(progressValue) ?? 0
        selectedItem.finishState = FinishState.state(with: finishState)
        selectedItem.startText = startText
        selectedItem.setDealineTime = setDeadlineTime
        selectedItem.deadlineTime = dealineTime
        modelData.updateItem(selectedItem)
        updateEvent()
        
        if let noteItem = modelData.noteList.first(where: { $0.convertId == selectedItem.id
        }) {
            noteItem.title = noteItem.title.isEmpty ? titleText : noteItem.title
            noteItem.content = mark
            modelData.updateNote(noteItem)
        }
    }

    // 添加环境变量
    @Environment(\.openWindow) private var openWindow

    // 修改按钮响应方法
    private func showPreviewWindow() {
        guard let selectItem else { return }
        if let noteItem = modelData.noteList.first(where: { $0.convertId == selectItem.id
        }) {
            openWindow(id: CommonDefine.noteWindow, value: noteItem)
        } else {
            openWindow(id: "markdown-preview", value: selectItem)
        }
    }
    
    func tagView(title: String, color: Color, size: CGFloat = 12, verPadding: CGFloat = 10, horPadding: CGFloat = 5) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: size))
            .padding(.horizontal, verPadding)
            .padding(.vertical, horPadding)
            .background(color)
            .clipShape(Capsule())
    }
    
}

extension ToDoEditView {
    
    private func addObservers() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                checkPasteboardChanged()
                return nil
            }
            return event
        }
    }
    
    private func checkPasteboardChanged() {
        onPasteboardChanged()
    }
    
    private func onPasteboardChanged() {
        print("on pasteboard changed")
        guard let pastedItem = NSPasteboard.general.pasteboardItems?.first, let pasteType = pastedItem.types.first else {
            return
        }
        if let imageData = pastedItem.data(forType: pasteType), let image = NSImage(data: imageData) {
            uploadImage(image: image)
        } else if let _ = pastedItem.data(forType: .string) {
            NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
        }
    }
    
#if os(macOS)
    private func uploadImage(image: NSImage) {
        print("upload image")
        if let data = image.toData() {
            CloudManager.shared.upload(with: data) { url, error in
                if let error = error {
                    print("upload data failed: \(error)")
                } else if let url = url {
                    let insertionText = url.formatImageUrl
                    let currentContent = self.mark
                    print("insert text: \(insertionText), pos: \(self.cursorPosition)")
                    let updateContent = currentContent.insert(insertionText, at: self.cursorPosition)
                    DispatchQueue.main.async {
                        self.mark = updateContent
                        self.toggleToRefresh.toggle()
                    }
                }
            }
        }
    }
#endif
    
}
