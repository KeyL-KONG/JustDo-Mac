//
//  iOSSummaryTaskView.swift
//  ToDo
//
//  Created by LQ on 2025/7/6.
//

import SwiftUI

struct iOSSummaryTaskView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Binding var timeTab: TimeTab
    @Binding var currentDate: Date
    @Binding var selectItemID: String
    @Binding var showingEditItem: Bool
    
    @State var tagTotalTimes: [String: Int] = [:]
    @State var sortedTagList: [ItemTag] = []
    @State var tagExpandState: [String: Bool] = [:]
    @State var tagItemList: [String: [EventItem]] = [:]
    @State var eventTotalTime = [String: Int]()
    
    var currentSummaryItem: SummaryItem? {
        modelData.summaryItemList.first { item in
            guard let summaryTime = item.summaryDate else { return false }
            return summaryTime.isSameTime(timeTab: timeTab, date: currentDate) && item.timeTab == timeTab
        }
    }
    
    var body: some View {
        summaryTagTimeItems()
            .onChange(of: currentDate, { oldValue, newValue in
                updateTagSummaryTime()
            })
            .onChange(of: timeTab, { oldValue, newValue in
                updateTagSummaryTime()
            })
            .onAppear {
                updateTagSummaryTime()
            }
    }
}

extension iOSSummaryTaskView {
    
    var cacheKey: String {
        return self.timeTab.rawValue + "_" + self.currentDate.simpleDayMonthAndYear
    }
    
    func updateTagSummaryTime() {
        print("update tag time items")
        let cacheKey = self.cacheKey
        self.tagTotalTimes = modelData.cacheTodayTagTotalTimes[cacheKey] ?? [:]
        self.eventTotalTime = modelData.cacheTodayEventTotalTimes[cacheKey] ?? [:]
        self.tagItemList = modelData.cacheTodayTagItemList[cacheKey] ?? [:]
        self.sortedTagList = modelData.cacheTodayTagList[cacheKey] ?? []
        
        let tagList = modelData.tagList
        let timeItems = modelData.taskTimeItems
        let itemList = modelData.itemList
        
        var totalTimes = 0
        var tagEventList = [String: [EventItem]]()
        var eventTotalTime = [String: Int]()
        var tagTotalTimes = [String: Int]()
        
        DispatchQueue.global().async {
            tagList.forEach { tag in
                var eventList: [EventItem] = []
                let filteredItems = timeItems.filter { time in
                    guard let event = itemList.first(where: { $0.id == time.eventId }) else {
                        return false
                    }
                    let result = event.tag == tag.id && time.endTime.isSameTime(timeTab: timeTab, date: currentDate)
                    if result && !eventList.contains(event) {
                        eventList.append(event)
                    }
                    if result {
                        var totalTime = eventTotalTime[event.id] ?? 0
                        totalTime += time.interval
                        eventTotalTime[event.id] = totalTime
                    }
                    return result
                }
                let totalInterval = filteredItems.compactMap { Int($0.interval / 60) }.reduce(0, +)
                tagTotalTimes[tag.id] = totalInterval
                totalTimes += totalInterval
                tagEventList[tag.id] = eventList.sorted { first, second in
                    if let firstTime = eventTotalTime[first.id], let secondTime = eventTotalTime[second.id] {
                        return firstTime > secondTime
                    }
                    return false
                }
            }
            
            DispatchQueue.main.async {
                self.tagTotalTimes = tagTotalTimes
                self.eventTotalTime = eventTotalTime
                self.tagItemList = tagEventList
                self.sortedTagList = tagList.filter({ tag in
                    (tagTotalTimes[tag.id] ?? 0) > 0
                }).sorted(by: { first, second in
                    guard let firstTime = tagTotalTimes[first.id], let secondTime = tagTotalTimes[second.id] else {
                        return false
                    }
                    return firstTime > secondTime
                })

                self.modelData.cacheTodayTagTotalTimes[cacheKey] = self.tagTotalTimes
                self.modelData.cacheTodayEventTotalTimes[cacheKey] = self.eventTotalTime
                self.modelData.cacheTodayTagItemList[cacheKey] = self.tagItemList
                self.modelData.cacheTodayTagList[cacheKey] = self.sortedTagList
            }
        }
    }
}

extension iOSSummaryTaskView {
    
    var summaryTagTotalTime: Int {
        tagTotalTimes.values.reduce(0, +)
    }
    
    func summaryTimeHeaderView() -> some View {
        HStack {
            Text("统计时间").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "48c9b0"))
            
            if summaryTagTotalTime > 0 {
                let percent = Int((Double(summaryTagTotalTime) / Double(timeTab.totalTimeMins)) * 100)
                Text("\(percent)%").foregroundStyle(Color.init(hex: "48c9b0"))
            }
            Spacer()
            
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func summaryTagTimeItems() -> some View {
        List {
            ForEach(sortedTagList, id: \.self) { tag in
                Section {
                    summaryTagItemListView(tag: tag)
                } header: {
                    HStack {
                        Text(tag.title).foregroundStyle(tag.titleColor).bold().font(.system(size: 14))
                        
                        Spacer()
                        if let time = tagTotalTimes[tag.id], time > 0 {
                            Text((time * 60).simpleTimeStr).foregroundStyle(tag.titleColor).font(.system(size: 14))
                        }
                    }
                    
                }
            }
        }
        
    }
    
    func summaryTagEditView(item: SummaryItem, tagContent: String, tag: ItemTag) -> some View {
        let key = cacheKey + tag.id
        let isEdit = modelData.isEditing(id: key, def: tagContent.isEmpty)
        return HStack {
            ZStack {
                if isEdit {
                    TextEditor(text: Binding(get: {
                        item.summaryTags[tag.id] ?? ""
                    }, set: { value in
                        item.summaryTags[tag.id] = value
                    }))
                        .font(.system(size: 12))
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.hidden)
                        .frame(minHeight: 80)
                        .tag(key)
                } else {
                    MarkdownWebView(item.summaryTags[tag.id] ?? "")
                        .frame(minHeight: 50)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                let title = isEdit ? "保存" : "编辑"
                Button(title) {
                    if isEdit {
                        modelData.updateSummaryItem(item)
                    }
                    modelData.markEdit(id: key, edit: !isEdit)
                }
            }
                
        }
        .padding()
        .background(tag.titleColor.opacity(0.3))
        .cornerRadius(8)
    }
    
    func summaryTagItemListView(tag: ItemTag) -> some View {
        return VStack {
            if let items = tagItemList[tag.id], items.count > 0 {
                ForEach(items, id: \.self) { item in
                    summaryItemView(item: item, tagColor: tag.titleColor)
                }
            }
        }
    }
    
    func summaryItemView(item: EventItem, tagColor: Color) -> some View {
        HStack {
            Text(item.title).font(.system(size: 12))
            Spacer()
            if timeTab == .day {
                let tagItems = modelData.taskTimeItems.filter { $0.eventId == item.id && $0.stateTagId.count > 0 && $0.startTime.isSameTime(timeTab: timeTab, date: currentDate)}.compactMap { item in
                    modelData.noteTagList.first(where: { $0.id == item.stateTagId })
                }
                if tagItems.count > 0 {
                    ForEach(tagItems, id: \.self.id) { tag in
                        tagView(title: tag.content, color: .blue)
                    }
                }
            }
            if let totalTime = eventTotalTime[item.id] {
                Text(totalTime.simpleTimeStr).font(.system(size: 12)).foregroundStyle(tagColor)
            }
        }
        .contentShape(Rectangle())
//        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background {
            ZStack {
                let bgColor = item.id == selectItemID ? tagColor.opacity(0.5) : tagColor.opacity(0.2)
                Rectangle()
                    .fill(bgColor)
                    .cornerRadius(10)
                    .padding(.horizontal, -10)
            }
        }
        .onTapGesture {
            selectItemID = item.id
            self.showingEditItem.toggle()
        }
    }
    
    func expandState(with tag: ItemTag) -> Bool {
        return tagExpandState[tag.id] ?? false
    }
    
    func updateExpandState(with tag: ItemTag, state: Bool? = nil) {
        if let expand = tagExpandState[tag.id] {
            tagExpandState[tag.id] = state ?? !expand
        } else {
            tagExpandState[tag.id] = state ?? false
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
