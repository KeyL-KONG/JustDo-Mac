//
//  EditTielineTaskView.swift
//  ToDo
//
//  Created by LQ on 2025/5/5.
//

import SwiftUI

struct EditTimeIntervalView: View {
    
    @EnvironmentObject var modelData: ModelData
    @State var startTime: Date
    @State var endTime: Date
    @State var selectTitle: String = ""

    @State var selectedTag: String = ""
    @State var selectReward: String = ""
    @State var setPlanTime: Bool = false
    
    @State var recordContent: String = ""
    @FocusState var focusedField: FocusedField?
    enum FocusedField {
        case record
    }
    
    @State var itemType: EventActionType = .project
    var itemTypeList: [EventActionType] = [.task, .project]
    
    @State var itemList: [EventItem] = []
    @State var sortedTagList: [ItemTag] = []
    
    var itemListTitles: [String] {
        guard let tagId = modelData.tagList.filter({ $0.title == selectedTag }).first?.id else {
            return []
        }
        return itemList.filter { $0.tag == tagId && itemType == $0.actionType }.sorted { event1, event2 in
            if event1.setPlanTime != event2.setPlanTime {
                return event1.setPlanTime ? true : false
            } else if let planTime1 = event1.planTime, let planTime2 = event2.planTime {
                return planTime1.timeIntervalSince1970 > planTime2.timeIntervalSince1970
            }
            return (event1.createTime?.timeIntervalSince1970 ?? 0) > (event2.createTime?.timeIntervalSince1970 ?? 0)
        }.compactMap { $0.title }
    }
    
    var body: some View {
        VStack {
            List {
                Section {
                    if itemType == .task {
                        Text(selectTitle)
                    }
                    Picker("选择标签", selection: $selectedTag) {
                        ForEach(sortedTagList.map({$0.title}), id: \.self) { title in
                            if let tag = modelData.tagList.first(where: { $0.title == title }) {
                                Text(tag.title).tag(tag)
                            }
                        }
                    }
                    
                    Picker("选择类型", selection: $itemType) {
                        ForEach(itemTypeList, id: \.self) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    
                    if itemType == .task {
                        Picker("选择任务事项", selection: $selectTitle) {
                            ForEach(itemListTitles, id: \.self) { title in
                                Text(title).tag(title)
                            }
                        }
                    } else {
                        Picker("选择项目事项", selection: $selectTitle) {
                            ForEach(itemListTitles, id: \.self) { title in
                                Text(title).tag(title)
                            }
                        }
                    }
                }
                
                Section {
                    Toggle("是否设置为计划时间", isOn: $setPlanTime)
                    DatePicker(selection: $startTime, displayedComponents: [.date, .hourAndMinute]) {
                        Text("开始时间")
                    }
                    DatePicker(selection: $endTime, displayedComponents: [.date, .hourAndMinute]) {
                        Text("结束时间")
                    }
                }
                
                Section(header: Text("编辑内容")) {
                    TextEditor(text: $recordContent)
                        .focused($focusedField, equals: .record)
                        .font(.system(size: 15))
                        .frame(minHeight: 100)
                }
            }
        }
        .toolbar(content: {
            Spacer()
            Button("保存") {
                saveTimeInterval()
            }.foregroundColor(.blue)
        })
        .onChange(of: selectedTag, { oldValue, newValue in
            print("selected tag from \(oldValue) to \(newValue)")
            if let firstTitle = itemListTitles.first, oldValue.count > 0 {
                selectTitle = firstTitle
            }
        })
        .onChange(of: selectTitle, { oldValue, newValue in
            print("selected title from \(oldValue) to \(newValue)")
        })
        .onAppear {
            self.itemList = calculateItemsList()
            self.sortedTagList = calculateTagList()
            if let selectedDefaultItem = selectDefaultItem() {
                self.selectTitle = selectedDefaultItem.title
                if let tag = modelData.tagList.first(where: { $0.id == selectedDefaultItem.tag
                }) {
                    self.selectedTag = tag.title
                }
                self.startTime = selectedDefaultItem.fixedStartTime ?? self.startTime
                self.endTime = selectedDefaultItem.fixedEndTime ?? self.endTime
            } else {
                self.selectedTag = self.sortedTagList.first?.title ?? ""
                self.selectTitle = self.selectDefaultItem()?.title ?? ""
            }
            
        }
    }
}

extension EditTimeIntervalView {
    
    func selectDefaultItem() -> EventItem? {
        return modelData.itemList.filter { $0.actionType == .project && $0.isFixedEvent }.sorted { first, second in
            if let firstStartTime = first.fixedStartTime, let secondStartTime = second.fixedStartTime {
                return abs(self.startTime.currentDayTimeInterval - firstStartTime.currentDayTimeInterval) < abs(self.startTime.currentDayTimeInterval - secondStartTime.currentDayTimeInterval)
            }
            return true
        }.first
    }
    
    func saveTimeInterval() {
        guard let item = itemList.filter({ $0.title == selectTitle }).first else {
            return
        }
        
        let timeItem = TaskTimeItem(startTime: startTime, endTime: endTime, content: recordContent)
        timeItem.eventId = item.id
        timeItem.isPlan = setPlanTime
        modelData.updateTimeItem(timeItem)
    }
    
    
    func calculateItemsList() -> [EventItem] {
        return modelData.itemList
//        return modelData.itemList.sorted { event1, event2 in
//            if itemType == .project {
//                if event1.isFixedEvent != event2.isFixedEvent {
//                    return event1.isFixedEvent ? true : false
//                } else if event1.isFixedEvent, event2.isFixedEvent {
//                    if let startTime1 = event1.fixedStartTime, let endTime1 = event1.fixedEndTime, let startTime2 = event2.fixedStartTime, let endTime2 = event2.fixedEndTime {
//                        let timeInterval = startTime.getSecondsSinceStartOfDay()
//                        if startTime1.getSecondsSinceStartOfDay() >= timeInterval, timeInterval <= endTime1.getSecondsSinceStartOfDay() {
//                            return true
//                        } else if startTime2.getSecondsSinceStartOfDay() >= timeInterval, timeInterval <= endTime2.getSecondsSinceStartOfDay() {
//                            return false
//                        } else {
//                            return abs(startTime1.getSecondsSinceStartOfDay() - timeInterval) <= abs(startTime2.getSecondsSinceStartOfDay() - timeInterval)
//                        }
//                    }
//                }
//                
//            }
//            
//            func recentTimeItem(event: EventItem) -> TaskTimeItem? {
//                return modelData.taskTimeItems.filter {  $0.eventId == event.id
//                }.sorted { item1, item2 in
//                    return abs(item1.startTime.timeIntervalSince(startTime)) <= abs(item2.startTime.timeIntervalSince(startTime))
//                }.first
//            }
//            
//            var time1 = recentTimeItem(event: event1)?.endTime
//            var time2 = recentTimeItem(event: event2)?.endTime
//            if let planTime = event1.planTime, let time = time1, abs(planTime.timeIntervalSince(startTime)) < abs(time.timeIntervalSince(startTime)) {
//                time1 = planTime
//            }
//            
//            if let planTime = event2.planTime, let time = time2, abs(planTime.timeIntervalSince(startTime)) < abs(time.timeIntervalSince(startTime)) {
//                time2 = planTime
//            }
//            
//            if let time1 = time1, let time2 = time2 {
//                return abs(time1.timeIntervalSince(startTime)) <= abs(time2.timeIntervalSince(startTime))
//            } else if time1 != nil {
//                return true
//            } else if time2 != nil {
//                return false
//            } else {
//                return true
//            }
//        }
    }
    
    func calculateTagList() -> [ItemTag] {
        modelData.tagList.sorted { tag1, tag2 in
            if let tag = itemList.first?.tag, (tag1.id == tag || tag2.id == tag) {
                return tag1.id == tag ? true : false
            }
            return tag1.priority >= tag2.priority
        }
    }
    
}
