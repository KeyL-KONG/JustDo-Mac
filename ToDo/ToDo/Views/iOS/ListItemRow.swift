//
//  ListItemRow.swift
//  JustDo
//
//  Created by ByteDance on 2023/7/8.
//

import SwiftUI

struct ListItemRow: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State private var timeElapsed: Int = 0
    
    @State var timer: Timer?
    
    @State var item: EventItem
    @State var displayMode: DisplayMode = .task
    @State var timeMode: TimeTab = .day
    @State var selectDate: Date?
    var finishEvent: ((Bool) -> Void)?
    var clickEvent: () -> Void
    var longPress: () -> Void
    
    var tag: ItemTag? {
        modelData.tagList.first { $0.id == item.tag }
    }
    
    var body: some View {
        HStack {
            Button {
            } label: {
                if !item.setPlanTime {
                    Label("Toggle Finish", systemImage: "star.square")
                        .labelStyle(.iconOnly)
                } else {
                    Label("Toggle Finish", systemImage: item.isFinish ? "checkmark.square.fill" : "square")
                        .labelStyle(.iconOnly)
                }
            }
            .onTapGesture {
                guard item.setPlanTime else { return }
                item.isFinish = !item.isFinish
                if item.isFinish {
                    if item.isPlay {
                        item.isPlay = false
                    }
                    stopTimer()
                }
                modelData.updateItem(item)
                self.finishEvent?(item.isFinish)
            }
            
            Text(item.title).font(.system(size: 13)).foregroundStyle((item.isFinish ? Color.gray : Color.black)).onTapGesture {
                clickEvent()
            }
            
            if let tag, displayMode != .task {
                tagView(title: tag.title, color: tag.titleColor)
            }
            
            tagView(title: item.importance.description, color: item.importance.titleColor)
            
            Spacer()
            
            if timeElapsed > 0{
                Text(timeElapsed.simpleTimeStr).font(.footnote).foregroundStyle(.gray)
            } else if let planTime = item.planTime, item.importance == .high, !planTime.isToday {
                let days = planTime.daysBetween(Date.now)
                Text("截止\(days)天").foregroundStyle(.red).font(.system(size: 12))
            }
            
        }
        .contentShape(Rectangle())
        .onTapGesture {
            clickEvent()
        }
        .onAppear {
            if let selectDate {
                timeElapsed = item.itemTotalTime(with: modelData.itemList, taskItems: modelData.taskTimeItems.filter {!$0.isPlan}, taskId: item.id, date: selectDate)
            }
        }
        
    }
    
    var timeButton: some View {
        Button {
            
        } label: {
            Label("Time", systemImage: item.isPlay ? "pause.fill" : "play.fill")
                .labelStyle(.iconOnly)
        }
        .onTapGesture {
            item.isPlay = !item.isPlay
            modelData.updateItem(item)
            if item.isPlay {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    
    
    
    var itemTag: some View {
        Text(item.importance.description)
            .foregroundColor(.white)
            .font(.system(size: 8))
            .padding(EdgeInsets.init(top: 2, leading: 4, bottom: 2, trailing: 4))
            .background(item.importance.titleColor)
            .clipShape(Capsule())
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 8))
            .padding(EdgeInsets.init(top: 2, leading: 2, bottom: 2, trailing: 2))
            .background(color)
            .clipShape(Capsule())
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            timeElapsed += 1
        })
        
        let dateInterval = LQDateInterval(start: .now, end: .now)
        item.intervals.append(dateInterval)
        modelData.updateItem(item)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        refreshLastTimeInterval()
    }
    
    func refreshLastTimeInterval() {
        guard item.intervals.count > 0 else { return }
        let last = item.intervals.removeLast()
        let dateInterval = LQDateInterval(start: last.start, end: .now)
        item.intervals.append(dateInterval)
        modelData.updateItem(item)
    }
    
}

