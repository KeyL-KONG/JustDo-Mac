//
//  PlanView.swift
//  ToDo
//
//  Created by LQ on 2025/5/12.
//

import SwiftUI

struct PlanView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State var mostImportranceItems: [EventItem] = []
    @State var planTimeItems: [PlanTimeItem] = []
    @Binding var selectItemID: String
    
    @State var tagTotalTimes: [String: Int] = [:]
    @State var sortedTagList: [ItemTag] = []
    @State var totalTimeMins: Int = 0
    @State var tagExpandState: [String: Bool] = [:]
    @State var tagItemList: [String: [EventItem]] = [:]
    @State var eventTotalTime = [String: Int]()
    
    @State var summaryItems: [SummaryItem] = []
    
    @State var readItems: [ReadModel] = []
    
    @State var currentDate: Date = .now
    
    var body: some View {
        ScrollView(showsIndicators: true) { // 添加垂直滚动容器
            VStack(spacing: 0) {
                if mostImportranceItems.count > 0 {
                    mostImportanceHeaderView()
                    mostImportanceView()
                }
                
                planHeaderView()
                planItemsView()
                
                summaryTimeHeaderView()
                summaryTagTimeItems()
                
                summaryItemHeaderView()
                summaryItemsView()
                
                readItemHeaderView()
                readItemListView()
                
                Spacer()
            }
        }
        .onChange(of: currentDate) { _, _ in
            updateData()
        }
        .onAppear {
            currentDate = modelData.planCacheTime ?? .now 
            updateData()
        }
        .onDisappear {
            modelData.planCacheTime = currentDate
        }
        .onReceive(modelData.$itemList) { _ in
            updateMostImportanceItems()
        }
        .onReceive(modelData.$planTimeItems, perform: { _ in
            updatePlanItems()
        })
        .onReceive(modelData.$updateItemIndex) { _ in
            updateMostImportanceItems()
        }
        .toolbar {
            HStack {
                Button {
                    currentDate = currentDate.previousWeekDate
                } label: {
                    Label("left", systemImage: "arrowshape.left.fill")
                }
                
                Text(currentDate.simpleWeek)
                
                Button {
                    currentDate = currentDate.nextWeekDate
                } label: {
                    Label("rigth", systemImage: "arrowshape.right.fill")
                }
                
                Spacer()
            }
        }
    }
    
    func updateData() {
        updateMostImportanceItems()
        updatePlanTimeInterval()
        updatePlanItems()
        updateTagSummaryTime()
        updateSummaryItems()
        updateReadItems()
    }
}

// MARK: read view
extension PlanView {
    
    func readItemHeaderView() -> some View {
        HStack {
            Text("本周阅读").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "dc7633"))
            Spacer()
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func readItemListView() -> some View {
        VStack(alignment: .leading) {
            ForEach(readItems, id: \.self) { item in
                readItemView(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "dc7633").opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func readItemView(item: ReadModel) -> some View {
        return HStack {
            let title = item.title.count > 0 ? item.title : "无标题"
            Text(title)
            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .onTapGesture {
            if let url = URL(string: "readlist://\(item.id)") {
                NSWorkspace.shared.open(url)
            }
            
        }
    }
    
    func updateReadItems() {
        readItems = modelData.readList.filter { item in
            guard let createTime = item.createTime else {
                return false
            }
            return createTime.isInSameWeek(as: currentDate)
        }
    }
    
}

// MARK: Summary Think View
extension PlanView {
    
    func summaryItemHeaderView() -> some View {
        HStack {
            Text("本周思考").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "f5b041"))
            Spacer()
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func summaryItemsView() -> some View {
        VStack(alignment: .leading) {
            ForEach(summaryItems, id: \.self) { item in
                summaryItemView(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "f5b041").opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func summaryItemView(item: SummaryItem) -> some View {
        HStack {
            Text(item.content)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.selectItemID = item.id
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            if item.id == selectItemID {
                ZStack {
                    Rectangle()
                        .fill(Color.init(hex: "f5b041"))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    func updateSummaryItems() {
        summaryItems = modelData.summaryItemList.filter({ item in
            guard let createTime = item.createTime else {
                return false
            }
            return currentDate.isInSameWeek(as: createTime)
        }).sorted(by: { ($0.createTime?.timeIntervalSince1970 ?? 0) > ($1.createTime?.timeIntervalSince1970 ?? 0)
        })
    }
    
}

// MARK: Summary Time View
extension PlanView {
    
    func summaryTimeHeaderView() -> some View {
        HStack {
            Text("统计时间").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "48c9b0"))
            Spacer()
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func summaryTagTimeItems() -> some View {
        VStack(alignment: .leading) {
            ForEach(sortedTagList, id: \.self) { item in
                summaryTagItemView(tag: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "48c9b0").opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func summaryTagItemView(tag: ItemTag) -> some View {
        let isExpand = expandState(with: tag)
        return VStack(spacing: isExpand ? 10 : 0) {
            HStack {
                Text(tag.title).foregroundStyle(tag.titleColor).bold()
                Spacer()
                if let time = tagTotalTimes[tag.id], totalTimeMins > 0 {
                    ProgressBar(percent: (CGFloat(time) / CGFloat(totalTimeMins)), progressColor: tag.titleColor, showBgView: false, maxWidth: 400)
                    Text((time * 60).simpleTimeStr).foregroundStyle(tag.titleColor).frame(width: 60)
                }
                
                Image(systemName: isExpand ? "chevron.down" : "chevron.right").foregroundStyle(tag.titleColor).frame(width: 20)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                updateExpandState(with: tag)
            }
            
            summaryTagItemListView(tag: tag)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(isExpand ? 1 : 0)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .frame(maxHeight: (isExpand ? .none : 25), alignment: .top)
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
            Text(item.title)
            Spacer()
            if let totalTime = eventTotalTime[item.id] {
                Text(totalTime.simpleTimeStr).foregroundStyle(tagColor)
            }
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background {
            ZStack {
                let bgColor = item.id == selectItemID ? tagColor.opacity(0.5) : tagColor.opacity(0.2)
                Rectangle()
                    .fill(bgColor)
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
            }
        }
        .onTapGesture {
            selectItemID = item.id
        }
    }
    
    func expandState(with tag: ItemTag) -> Bool {
        return tagExpandState[tag.id] ?? false
    }
    
    func updateExpandState(with tag: ItemTag) {
        if let expand = tagExpandState[tag.id] {
            tagExpandState[tag.id] = !expand
        } else {
            tagExpandState[tag.id] = false
        }
    }
    
    func updateTagSummaryTime() {
        let tagList = modelData.tagList
        let timeItems = modelData.taskTimeItems
        let itemList = modelData.itemList
        var totalTimes = 0
        var tagEventList = [String: [EventItem]]()
        var eventTotalTime = [String: Int]()
        
        tagList.forEach { tag in
            var eventList: [EventItem] = []
            let filteredItems = timeItems.filter { time in
                guard let event = itemList.first(where: { $0.id == time.eventId }) else {
                    return false
                }
                let result = event.tag == tag.id && time.startTime.isInSameWeek(as: currentDate)
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
        self.eventTotalTime = eventTotalTime
        self.tagItemList = tagEventList
        self.totalTimeMins = totalTimes
        self.sortedTagList = tagList.filter({ tag in
            (tagTotalTimes[tag.id] ?? 0) > 0
        }).sorted(by: { first, second in
            guard let firstTime = tagTotalTimes[first.id], let secondTime = tagTotalTimes[second.id] else {
                return false
            }
            return firstTime > secondTime
        })
    }
    
}

// MARK: plan view
extension PlanView {
    
    func planHeaderView() -> some View {
        HStack {
            Text("目标时间").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "2874a6"))
            Spacer()
            Text("+").bold().font(.system(size: 25)).foregroundStyle(Color.init(hex: "2874a6"))
                .onTapGesture {
                    self.selectItemID = ToDoListView.newPlanTimeItemId
                }
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func planItemsView() -> some View {
        VStack(alignment: .leading) {
            ForEach(planTimeItems, id: \.self) { item in
                planItemView(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "2874a6").opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
        
    }
    
    func planItemView(item: PlanTimeItem) -> some View {
        HStack {
            Text(item.content)
            Spacer()
            ProgressBar(percent: item.percentValue, progressColor: planItemTagColor(item: item))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.selectItemID = item.id
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            if item.id == selectItemID {
                ZStack {
                    Rectangle()
                        .fill(Color.init(hex: "a9cce3"))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    func planItemTagColor(item: PlanTimeItem) -> Color {
        guard let tag = modelData.tagList.first(where: { $0.id == item.tagId
        }) else {
            return .blue
        }
        return tag.titleColor
    }
    
    func updatePlanItems() {
        self.planTimeItems = modelData.planTimeItems.filter({ item in
            item.startTime.isInSameWeek(as: currentDate)
        })
    }
    
    func updatePlanTimeInterval() {
        let timeItems = modelData.taskTimeItems
        let itemList = modelData.itemList
        modelData.planTimeItems.forEach { item in
            let totalInterval = timeItems.filter { time in
                guard let event = itemList.first(where: { $0.id == time.eventId }) else {
                    return false
                }
                return event.tag == item.tagId && time.startTime >= item.startTime && time.startTime <= item.endTime
            }.compactMap { Int($0.interval / 60) }.reduce(0, +)
            if totalInterval != item.totalInterval {
                item.totalInterval = totalInterval
                modelData.updatePlanTimeItem(item, shouldAdd: false)
            }
        }
        modelData.asyncUpdateCache(type: .planItem)
    }
    
}

// MARK: importance view
extension PlanView {
    
    func mostImportanceHeaderView() -> some View {
        HStack {
            Text("关键事项").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "e74c3c"))
            Spacer()
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func mostImportanceView() -> some View {
        VStack(alignment: .leading) {
            ForEach(mostImportranceItems, id: \.self) { item in
                mostImportanceItemView(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "fadbd8").opacity(0.6))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func mostImportanceItemView(item: EventItem) -> some View {
        HStack(alignment: .center) {
            Toggle("", isOn: .constant(item.isFinish))
            
            Text(item.title)
            Spacer()
                
            
            if let tag = modelData.tagList.first(where: {  $0.id == item.tag }) {
                tagView(title: tag.title, color: tag.titleColor)
            }
            Text("\(item.progressValue)%")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.selectItemID = item.id
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            if item.id == selectItemID {
                ZStack {
                    Rectangle()
                        .fill(Color.init(hex: "a9cce3"))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    func updateMostImportanceItems() {
        mostImportranceItems = Array(modelData.itemList.filter({ event in
            guard let planTime = event.planTime else {
                return false
            }
            return planTime.isInSameWeek(as: currentDate) && event.isKeyEvent
        }).sorted(by: {
            ($0.createTime?.timeIntervalSince1970 ?? 0) >= ($1.createTime?.timeIntervalSince1970 ?? 0)
        }).prefix(3))
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 8))
            .padding(EdgeInsets.init(top: 2, leading: 2, bottom: 2, trailing: 2))
            .background(color)
            .clipShape(Capsule())
    }
    
}

