//
//  iOSEditTimeIntervalView.swift
//  JustDo
//
//  Created by LQ on 2024/4/20.
//

import SwiftUI

struct iOSEditTimeIntervalView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Binding var showSheetView: Bool
    @State var startTime: Date
    @State var endTime: Date
    @State var selectTitle: String = ""
    
    var lastTimeItem: TimelineItem?
    var selectedTimeItem: TimelineItem?
    @State var originalInterval: LQDateInterval?
    @State var originalTitle: String?

    @State var selectedTag: String = ""
    @State var selectReward: String = ""
    
    @State var itemType: TaskType = .reward
    var itemTypeList: [TaskType] = [.reward, .task]
    
    
    var itemList: [any BasicTaskProtocol] {
        return itemType == .reward ? modelData.rewardList : modelData.itemList.filter({ event in
            guard let planTime = event.planTime else { return false }
            return planTime.isInThisWeek
        })
    }
    
    var itemListTitles: [String] {
        guard let tagId = modelData.tagList.filter({ $0.title == selectedTag }).first?.id else {
            return []
        }
        return itemList.filter { $0.tag == tagId }.compactMap { $0.title }
    }
    
    var body: some View {
        NavigationView {
            VStack {
#if os(iOS)
                Text("")
                    .navigationBarTitle(Text("记录时间"), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        self.showSheetView = false
                    }, label: {
                        Text("取消").bold()
                    }), trailing: Button(action: {
                        self.saveTimeInterval()
                        self.showSheetView = false
                    }, label: {
                        Text("保存").bold()
                    }))
#endif
            
                List {
//                    Section {
//                        if itemType == .task {
//                            Text(selectTitle)
//                        }
//                        
//                        Picker("选择标签", selection: $selectedTag) {
//                            ForEach(modelData.tagList.map({$0.title}), id: \.self) { title in
//                                if let tag = modelData.tagList.first(where: { $0.title == title }) {
//                                    Text(tag.title).tag(tag)
//                                }
//                            }
//                        }
//                        
//                        Picker("选择类型", selection: $itemType) {
//                            ForEach(itemTypeList, id: \.self) { type in
//                                Text(type.title).tag(type)
//                            }
//                        }
//                        
//                        if itemType == .reward {
//                            Picker("选择积分事项", selection: $selectTitle) {
//                                ForEach(itemListTitles, id: \.self) { rewardTitle in
//                                    Text(rewardTitle).tag(rewardTitle)
//                                }
//                            }
//                        } else {
//                            Picker("选择任务事项", selection: $selectTitle) {
//                                ForEach(itemListTitles, id: \.self) { title in
//                                    Text(title).tag(title)
//                                }
//                            }
//                        }
//                    }
                    
                    Section {
                        DatePicker(selection: $startTime, displayedComponents: [.date, .hourAndMinute]) {
                            Text("开始时间")
                        }
                        DatePicker(selection: $endTime, displayedComponents: [.date, .hourAndMinute]) {
                            Text("结束时间")
                        }
                    }
                }
            }

        }
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
            if let selectedTimeItem {
                originalTitle = selectedTimeItem.event.title
                originalInterval = selectedTimeItem.interval
                selectedTag = modelData.tagList.filter({ $0.id == selectedTimeItem.event.tag}).first?.title ?? ""
                selectTitle = selectedTimeItem.event.title
            }
            else if let lastTimeItem {
                selectedTag = modelData.tagList.filter { $0.id == lastTimeItem.event.tag }.first?.title ?? ""
                selectTitle = lastTimeItem.event.title
                startTime = startTime.startTimeOfDay.addingTimeInterval(lastTimeItem.interval.start.timeIntervalsFromStartOfDay)
                endTime = startTime.addingTimeInterval(lastTimeItem.interval.end.timeIntervalSince1970 - lastTimeItem.interval.start.timeIntervalSince1970)
            }
            else {
                selectedTag = modelData.tagList.first?.title ?? ""
                selectTitle = itemListTitles.first ?? ""
            }
        }
    }
}

extension iOSEditTimeIntervalView {
    
    func saveTimeInterval() {
        guard var item = itemList.filter({ $0.title == selectTitle }).first else {
            return
        }
        
        if let originalTitle, let originalInterval, originalTitle != selectTitle {
            if var deleteItem = itemList.filter({ $0.title == originalTitle }).first, let deleteIntervalIndex = deleteItem.intervals.firstIndex(where: { $0.id == originalInterval.id }) {
                deleteItem.intervals.remove(at: deleteIntervalIndex)
                updateItem(deleteItem)
            }
        }
        
        if let originalInterval, let index = item.intervals.firstIndex(where: { $0.id == originalInterval.id }) {
            item.intervals[index] = LQDateInterval(start: startTime, end: endTime)
        } else {
            item.intervals.append(LQDateInterval(start: startTime, end: endTime))
        }
        
        updateItem(item)
    }
    
    func updateItem(_ item: any BasicTaskProtocol) {
        if let reward = item as? RewardModel {
            modelData.updateRewardModel(reward)
        } else if let event = item as? EventItem {
            modelData.updateItem(event)
        } else {
            fatalError("error type")
        }
    }
    
}
