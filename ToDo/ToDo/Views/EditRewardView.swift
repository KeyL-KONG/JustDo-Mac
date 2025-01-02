//
//  EditRewardView.swift
//  JustDo
//
//  Created by LQ on 2024/4/5.
//

import SwiftUI

struct EditRewardView: View {
    
    let expandCount = 3
    
    enum FocusedField {
        case title
        case reward
        case mark
    }
    
    @EnvironmentObject var modelData: ModelData
    @State var title: String = ""
    @State var mark: String = ""
    @State var selectedTag: String = ""
    @State var eventType: EventValueType = .num
    @State var rewardType: RewardType = .good
    @State var rewardValue: String = ""
    @FocusState private var focusedField: FocusedField?
    @State var rewardTypeList: [RewardType] = [.good, .bad]
    @State var eventTypeList: [EventValueType] = [.num, .time, .count]
    
    @State public var selectedItem: RewardModel? = nil
    @State var isFinish: Bool = false
    
    @State public var fatherId: String? = nil
    
    @State var intervals: [LQDateInterval] = []
    @State var showTimeIntervals = false
    @State var showEventList = false
    
    @State var showIntervalView: Bool = false
    private static var selectTimeItem: RewardTimeItem?
    
    @State var fixedTimeTypeList: [RewardFixTimeType] = [.everyday, .onlyWeek, .onlyWeekend]
    @State var selectedFixTimeType: RewardFixTimeType = .everyday
    @State var fixedTimeIntervals: [LQDateInterval] = []
    
    @State var showingSubRewardView: Bool = false
    private static var selectedSubTask: RewardModel?
    var rewardEventList: [EventItem] {
        guard let selectedItem = self.selectedItem else {
            return []
        }
        return modelData.itemList.filter { $0.rewardId == selectedItem.id }
    }
    
    var rewardTimeList: [RewardTimeItem] {
        guard let selectedItem else {
            return []
        }
        return selectedItem.rewardTimeList
    }
    
    var subGoalList: [RewardModel] {
        guard let selectedItem = self.selectedItem else {
            return []
        }
        return modelData.rewardList.filter { $0.fatherId == selectedItem.id }
    }
    
    var navigationTitle: String {
        if fatherId != nil {
            return self.selectedItem == nil ? "创建子目标" : "编辑子目标"
        }
        return self.selectedItem == nil ? "创建积分" : "编辑积分"
    }
    
    var body: some View {
            
            VStack {
                List {
                    Section {
                        TextField("标题", text: $title, axis: .vertical)
                        
                        Picker("选择标签", selection: $selectedTag) {
                            ForEach(modelData.tagList.compactMap({$0.title}), id: \.self) { title in
                                if let tag = modelData.tagList.filter({ $0.title == title}).first {
                                    Text(tag.title).tag(tag)
                                }
                            }
                        }
                        
                        Picker("选择事项类型", selection: $eventType) {
                            ForEach(eventTypeList, id: \.self) { type in
                                Text(type.description).tag(type)
                            }
                        }
                        
                        if eventType == .num {
                            Toggle(isOn: $isFinish) {
                                Text("是否已完成")
                            }
                        }
                        
                        TextField("备注", text: $mark, axis: .vertical)
                    }
                    
                    Section(header: Text("设置积分")) {
                            
                        Picker("选择积分类型", selection: $rewardType) {
                            ForEach(rewardTypeList, id: \.self) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        
                        if eventType == .num {
                            TextField("积分数值", text: $rewardValue, axis: .vertical)
                                .textContentType(.flightNumber)
                        } else if eventType == .time {
                            TextField("积分/分钟", text: $rewardValue, axis: .vertical)
                                .textContentType(.flightNumber)
                        } else if eventType == .count {
                            TextField("积分/次", text: $rewardValue, axis: .vertical)
                                .textContentType(.flightNumber)
                        }
                            
                        
                    }
    
                    
                    Section(header:
                        HStack(alignment: .center) {
                            Text("子目标 (\(subGoalList.count))")
                            Spacer()
                            Button {
                                EditRewardView.selectedSubTask = nil
                                showingSubRewardView = true
                                print("add sub task")
                            } label: {
                                Text("添加子目标").font(.system(size: 14))
                            }
                            if subGoalList.count > expandCount {
                                Button {
                                    showEventList = !showEventList
                                } label: {
                                    Text(showEventList ? "隐藏" : "展开").font(.system(size: 14))
                                }
                            }
                        }
                    , content: {
                        let num = showEventList ? subGoalList.count : expandCount
                        ForEach(subGoalList.prefix(num), id: \.self) { event in
                            HStack {
                                Text(event.title)
                                Spacer()
                                let totalTime = event.totalTime(with: .all)
                                if totalTime > 0 {
                                    Text(event.totalTime(with: .all).simpleTimeStr).foregroundColor(.gray)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Self.selectedSubTask = event
                                showingSubRewardView = true
                            }
                        }
                        .onDelete(perform: { indexSet in
                            for index in indexSet.makeIterator() {
                                let reward = subGoalList[index]
                                modelData.deleteRewardModel(reward)
                            }
                        })
                        .id(UUID())
                    })
                    
                    fixedTimeInterval()
                    
                    Section(header:
                        HStack(alignment: .center) {
                            Text("统计时间 (\(rewardTimeList.count))")
                            Spacer()
                            Button {
                                let interval = LQDateInterval(start: .now, end: .now)
                                self.intervals = [interval] + intervals
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
                
            
        }.onAppear {
            if let selectedItem = selectedItem {
                title = selectedItem.title
                mark = selectedItem.mark
                selectedTag = modelData.tagList.filter({ $0.id == selectedItem.tag}).first?.title ?? ""
                intervals = selectedItem.intervals.sorted(by: { $0.start.timeIntervalSince1970 >= $1.start.timeIntervalSince1970
                })
                rewardType = selectedItem.rewardType
                eventType = selectedItem.eventType
                rewardValue = selectedItem.rewardValue > 0 ? String(selectedItem.rewardValue) : ""
                isFinish = selectedItem.isFinish
                fatherId = selectedItem.fatherId
                selectedFixTimeType = selectedItem.fixTimeType
                fixedTimeIntervals = selectedItem.fixTimes
            } else if let fatherId = self.fatherId, let fatherItem = modelData.rewardList.filter({ $0.id == fatherId }).first {
                selectedTag = modelData.tagList.filter({ $0.id == fatherItem.tag}).first?.title ?? ""
                rewardType = fatherItem.rewardType
                eventType = fatherItem.eventType
                rewardValue = fatherItem.rewardValue > 0 ? String(fatherItem.rewardValue) : ""
            }
            else {
                focusedField = .title
            }
        }
        .toolbar(content: {
            Spacer()
            Button("保存") {
                saveTask()
            }.foregroundColor(.blue)
        })
    }
    
    func saveTask() {
        let tag = modelData.tagList.filter({ $0.title == selectedTag}).first?.id ?? ""
        if let selectedItem = selectedItem {
            selectedItem.title = title
            selectedItem.tag = tag
            selectedItem.mark = mark
            selectedItem.intervals = intervals
            selectedItem.rewardType = rewardType
            selectedItem.eventType = eventType
            selectedItem.rewardValue = Int(rewardValue) ?? 0
            selectedItem.isFinish = isFinish
            selectedItem.fatherId = fatherId ?? ""
            selectedItem.fixTimeType = selectedFixTimeType
            selectedItem.fixTimes = fixedTimeIntervals
            modelData.updateRewardModel(selectedItem)
        } else {
            let item = RewardModel(id: UUID().uuidString, title: title, mark: mark, tag: tag, eventType: eventType, isFinish: isFinish, rewardType: rewardType, rewardValue: Int(rewardValue) ?? 0, intervals: intervals)
            item.fatherId = fatherId ?? ""
            modelData.saveRewardModel(item)
        }
    }
    
}

extension EditRewardView {
    
    var fixedTimeList: [RewardTimeItem] {
        guard let selectedItem else { return  [] }
        return selectedItem.fixedTimeList
    }
    
    func fixedTimeInterval() -> some View {
        Section(header: HStack(alignment: .center, content: {
            Text("周期时间")
            Spacer()
            Button {
                let interval = LQDateInterval(start: .now, end: .now)
                self.fixedTimeIntervals = [interval] + self.fixedTimeIntervals
                if let selectedItem {
                    selectedItem.fixTimes = fixedTimeIntervals
                    modelData.updateRewardModel(selectedItem)
                }
            } label: {
                Text("添加时间").font(.system(size: 14))
            }
        })) {
            Picker("选择周期", selection: $selectedFixTimeType) {
                ForEach(fixedTimeTypeList, id: \.self) { type in
                    Text(type.title).tag(type)
                }
            }
            
            ForEach(fixedTimeList.indices, id: \.self) { index in
                let item = fixedTimeList[index]
                RewardTimeItemView(index: index, item: item)
                    .onTapGesture {
                        Self.selectTimeItem = item
                        self.showIntervalView.toggle()
                    }
            }
            .onDelete { indexSet in
                fixedTimeIntervals.remove(atOffsets: indexSet)
                if let selectedItem {
                    selectedItem.fixTimes = fixedTimeIntervals
                    modelData.updateRewardModel(selectedItem)
                }
            }
            .id(UUID())
        }
    }
    
}


struct RewardTimeItemView: View {
    
    @State var index: Int
    @State var item: RewardTimeItem
    
    var body: some View {
        HStack {
//            if item.type == .interval {
//                Text(item.title).font(.system(size: 14))
//                Spacer()
//            }
            
            if item.type == .fixedTime {
                Text(item.interval.start.simpleTimeStr).font(.system(size: 14)).foregroundStyle(.gray)
                Text("-").font(.system(size: 14))
                Text(item.interval.end.simpleTimeStr).font(.system(size: 14)).foregroundStyle(.gray)
                
                Spacer()
                Text(item.interval.interval.simpleTimeStr).font(.system(size: 14))
            } else {
                Text(item.interval.start.simpleDateStr).font(.system(size: 12)).foregroundStyle(.gray)
                Text("-").font(.system(size: 12))
                Text(item.interval.end.simpleDateStr).font(.system(size: 12)).foregroundStyle(.gray)
                
                Spacer()
                Text(item.interval.interval.simpleTimeStr).font(.system(size: 14))
            }
    
        }
    }
}


#Preview(body: {
    RewardTimeItemView(index: 0, item: RewardTimeItem(interval: LQDateInterval(start: .now.yesterday, end: .now), title: "工作", type: .interval, id: ""))
})
