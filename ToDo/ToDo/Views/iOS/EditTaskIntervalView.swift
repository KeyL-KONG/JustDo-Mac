//
//  EditTaskIntervalView.swift
//  JustDo
//
//  Created by LQ on 2024/12/14.
//

import SwiftUI

struct EditTaskIntervalView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Binding var showSheetView: Bool
    @State var item: RewardTimeItem?
    @State var startTime: Date = .now
    @State var endTime: Date = .now
    @State var timeChange: () -> ()
    
    var body: some View {
        NavigationView {
            VStack {
#if os(iOS)
                Text("")
                    .navigationBarTitle(Text("编辑时间"), displayMode: .inline)
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
                    Section {
                        let components: DatePickerComponents = (item?.type ?? .interval) == .fixedTime ? [.date, .hourAndMinute] : [.date, .hourAndMinute]
                        DatePicker(selection: $startTime, displayedComponents: components) {
                            Text("开始时间")
                        }
                        DatePicker(selection: $endTime, displayedComponents: components) {
                            Text("结束时间")
                        }
                    }
                }
            }
        }.onAppear {
            if let item = self.item {
                startTime = item.interval.start
                endTime = item.interval.end
            }
        }
    }
}

extension EditTaskIntervalView {
    
    func saveTimeInterval() {
        guard let item = self.item else { return }
        
        switch item.type {
        case .interval:
            guard let reward = modelData.rewardList.filter({ $0.id == item.id }).first else {
                return
            }
            guard let intervalIndex = reward.intervals.firstIndex(where: { $0.start == item.interval.start && $0.end == item.interval.end
            }) else {
                return
            }
            reward.intervals[intervalIndex] = LQDateInterval(start: startTime, end: endTime)
            modelData.updateRewardModel(reward)
        case .task:
            guard let event = modelData.itemList.filter({ $0.id == item.id }).first else {
                return
            }
            guard let intervalIndex = event.intervals.firstIndex(where: { $0.start == item.interval.start && $0.end == item.interval.end
            }) else {
                return
            }
            event.intervals[intervalIndex] = LQDateInterval(start: startTime, end: endTime)
            modelData.updateItem(event)
        case .fixedTime:
            guard let reward = modelData.rewardList.filter({ $0.id == item.id }).first else {
                return
            }
            guard let intervalIndex = reward.fixTimes.firstIndex(where: { $0.start == item.interval.start && $0.end == item.interval.end
            }) else {
                return
            }
            reward.fixTimes[intervalIndex] = LQDateInterval(start: startTime, end: endTime)
            modelData.updateRewardModel(reward)
        }
        self.timeChange()
    }
}

#Preview {
    EditTaskIntervalView(showSheetView: .constant(true), startTime: .now, endTime: .now, timeChange: {
        
    }).environmentObject(ModelData())
}
