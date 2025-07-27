//
//  EditTaskView+Section.swift
//  JustDo
//
//  Created by LQ on 2024/11/24.
//

import SwiftUI
#if os(iOS)

extension EditTaskView {
    
    var intervalTimeList: [RewardTimeItem] {
        guard let item = self.selectedItem else { return [] }
        return item.rewardTimeList
    }
    
    var taskTimeItems: [TaskTimeItem] {
        modelData.taskTimeItems.filter { item in
            guard let selectItem = selectedItem else { return false }
            return item.eventId == selectItem.id && !item.isPlan
        }.sorted(by: {
            $0.startTime.timeIntervalSince1970 > $1.startTime.timeIntervalSince1970
        })
    }
    
    var taskPlanTimeItems: [TaskTimeItem] {
        modelData.taskTimeItems.filter { item in
            guard let selectItem = selectedItem else { return false }
            return item.eventId == selectItem.id && item.isPlan
        }.sorted(by: {
            $0.startTime.timeIntervalSince1970 > $1.startTime.timeIntervalSince1970
        })
    }
    
    func taskPlanItemViews() -> some View {
        Section(header:
            HStack() {
                let count = taskPlanTimeItems.count
                if count > 0 {
                    Text("设置计划时间(\(count))")
                } else {
                    Text("设置计划时间")
                }
                Spacer()
                Button {
                    let item = TaskTimeItem(startTime: .now, endTime: .now, content: "")
                    item.eventId = selectedItem?.id ?? ""
                    item.isPlan = true
                    modelData.updateTimeItem(item)
                } label: {
                    Text("添加计划时间").font(.system(size: 14))
                }
            
                Button(action: {
                    withAnimation {
                        self.isPlanTimeExpand = !self.isPlanTimeExpand
                    }
                }, label: {
                    Image(systemName: isPlanTimeExpand ? "chevron.up" : "chevron.right")
                })
            }
        ) {
            if isPlanTimeExpand {
                ForEach(taskPlanTimeItems) { item in
                    iOSTimeLineRowView(
                        item: item,
                        isEditing: .constant(true)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Self.selectedTaskItem = item
                        self.showingTimeTaskItemView.toggle()
                    }
                    .swipeActions(content: {
                        Button {
                            modelData.deleteTimeItem(item)
                        } label: {
                            Text("删除")
                        }.tint(.red)
                        
                        Button {
                            Self.selectedTaskItem = item
                            self.showingTimeTaskItemView.toggle()
                        } label: {
                            Text("编辑")
                        }.tint(.green)
                    })
                }
            }
            
        }

    }

    
    var taskTotalTime: Int {
        taskTimeItems.compactMap { $0.interval}.reduce(0, +)
    }
    
    func taskItemViews() -> some View {
        Section(header:
            HStack() {
                Text("事件记录")
                Text("\(taskTotalTime.simpleTimeStr)")
                Spacer()
                Button {
                    let item = TaskTimeItem(startTime: .now, endTime: .now, content: "")
                    item.eventId = selectedItem?.id ?? ""
                    modelData.updateTimeItem(item)
                } label: {
                    let recordCount = taskTimeItems.count
                    if recordCount > 0 {
                        Text("添加记录 (\(recordCount))").font(.system(size: 14))
                    } else {
                        Text("添加第一条记录").font(.system(size: 14))
                    }
                }
            
                Button(action: {
                    withAnimation {
                        self.isTimeExpand = !self.isTimeExpand
                    }
                }, label: {
                    Image(systemName: isTimeExpand ? "chevron.up" : "chevron.right")
                })
            }
        ) {
            if isTimeExpand {
                ForEach(taskTimeItems) { item in
                    iOSTimeLineRowView(
                        item: item,
                        isEditing: .constant(true)
                    )
                    .swipeActions(content: {
                        Button {
                            modelData.deleteTimeItem(item)
                        } label: {
                            Text("删除")
                        }.tint(.red)
                        
                        Button {
                            Self.selectedTaskItem = item
                            self.showingTimeTaskItemView.toggle()
                        } label: {
                            Text("编辑")
                        }.tint(.green)
                    })
                }
            }
            
        }

    }
    
    // MARK: time interval
    func timeIntervalView() -> some View {
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
            
                Button(action: {
                    withAnimation {
                        self.isTimeExpand = !self.isTimeExpand
                    }
                }, label: {
                    Image(systemName: isTimeExpand ? "chevron.up" : "chevron.right")
                })
            }
        , content: {
            if isTimeExpand {
                ForEach(intervalTimeList.indices, id: \.self) { index in
                    let item = intervalTimeList[index]
                    RewardTimeItemView(index: index, item: item)
                        .onTapGesture {
                            Self.selectedTimeIntervalItem = item
                            self.showingTimeIntervalView.toggle() 
                        }
                }
                .onDelete { indexSet in
                    intervals.remove(atOffsets: indexSet)
                }
                .id(UUID())
            }
        })
    }
    
    
    func markView() -> some View {
        Section(header: HStack(content: {
            Text("备注")
            Spacer()
            Button {
                self.isEditMark = !self.isEditMark
                if self.isEditMark {
                    focusedField = .mark
                    self.isMarkExpand = true
                }
            } label: {
                Text("\(isEditMark ? "预览" : "编辑")").font(.system(size: 14))
            }

            Button(action: {
                withAnimation {
                    self.isMarkExpand = !self.isMarkExpand
                }
            }, label: {
                Image(systemName: isMarkExpand ? "chevron.up" : "chevron.right")
            })
        })) {
            if isMarkExpand {
                if isEditMark {
                    TextEditor(text: $mark)
                        .font(.system(size: 12))
                        .padding(5)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 80)
                        .cornerRadius(8)
                        .background(Color.init(hex: "f8f9f9"))
                } else {
                    MarkdownWebView(mark)
                        .padding(5)
                        .background(Color.init(hex: "d4e6f1"))
                }
            }
        }
    }
    
    func contentView() -> some View {
        Section(header: HStack(content: {
            Text("内容")
            Spacer()
            Button(action: {
                withAnimation {
                    self.isDetailExpand = !self.isDetailExpand
                }
            }, label: {
                Image(systemName: isDetailExpand ? "chevron.up" : "chevron.right")
            })
        })) {
            
            TextField("标题", text: $title, axis: .vertical)
                .focused($focusedField, equals: .title)
                .lineLimit(4)
            
            Picker("选择标签", selection: $selectedTag) {
                ForEach(modelData.tagList.map({$0.title}), id: \.self) { title in
                    if let tag = modelData.tagList.first(where: { $0.title == title}) {
                        Text(tag.title).tag(tag)
                    }
                }
            }
            
            if eventType == .num {
                Toggle(isOn: $isFinish) {
                    Text("是否已完成")
                }
            }
            
            if isFinish {
                DatePicker(selection: $finishTime, displayedComponents: .date) {
                    Text("完成时间")
                }
            }
            
            HStack(content: {
                DatePicker(selection: $planTime, displayedComponents: .date) {
                    Text("计划时间")
                }
                
                Spacer()
                
                Toggle(isOn: $setPlanTime) {
                    Text("")
                }
            })
            
        }
    }
    
    func detailView() -> some View {
        Section(header: HStack(content: {
            Text("详情")
            Spacer()
            Button(action: {
                withAnimation {
                    self.isDetailExpand = !self.isDetailExpand
                }
            }, label: {
                Image(systemName: isDetailExpand ? "chevron.up" : "chevron.right")
            })
        })) {
            if isDetailExpand {
                
                Picker("选择类型", selection: $actionType) {
                    ForEach(actionList, id: \.self) { type in
                        Text(type.title).tag(type)
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
                
                if isFinish {
                    Toggle("是否需要复盘", isOn: $needReview)
                }
                
                Toggle(isOn: $isArchive) {
                    Text("是否归档")
                }
                
                if actionType == .project {
                    Toggle(isOn: $setFixedEvent) {
                        Text("设置为固定事项")
                    }
                }
    
            }
        }
    }
    
}

extension EditTaskView {
    
    func fixedView() -> some View {
        Section {
            DatePicker("开始时间:", selection: $fixedStartTime, displayedComponents: [.hourAndMinute])
            
            DatePicker("结束时间:", selection: $fixedEndTime, displayedComponents: [.hourAndMinute])
            
            HStack {
                ForEach(fixedWeekDays.indices, id: \.self) { index in
                    VStack(alignment: .center) {
                        Text(index.weekDayStr)
                        Toggle("", isOn: Binding(get: {
                            fixedWeekDays[index]
                        }, set: { value in
                            fixedWeekDays[index] = value
                        }))
                    }.frame(minWidth: 30)
                }
            }
        } header: {
            Text("固定事项")
        }

    }
    
    func reviewView() -> some View {
        Section {
            Toggle(isOn: $finishReview) {
                Text("是否已复盘")
            }
            if finishReview {
                DatePicker("完成复盘时间", selection: $reviewDate, displayedComponents: [.date])
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
                } else if reviewText.count > 0 {
                    MarkdownWebView(reviewText, itemId: selectedItem?.id ?? "")
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
    
}

enum TaskReviewState: String {
    case none = "无"
    case wait = "待复盘"
    case finish = "已复盘"
    
    static var list: [TaskReviewState] = [.none, .wait, .finish]
}

#endif
