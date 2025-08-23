//
//  TimerDisplayView.swift
//  ToDo
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct TimerDisplayView: View {
    @ObservedObject var timerModel: TimerModel
    @EnvironmentObject var modelData: ModelData
    
    // 注意：showTimelineView需要通过binding传递进来
    @Binding var showTimelineView: Bool
    
    var body: some View {
        HStack {
            let tagColor = timingTagColor()
            
            if timerModel.title.count > 0 {
                Text(timerModel.title).foregroundStyle(tagColor)
                Spacer()
            }
            
            Spacer()
            
            Text(timerModel.timeSeconds.secondAndMinTimeStr).bold().foregroundStyle(tagColor)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: {
            let timeItem = TaskTimeItem(startTime: timerModel.startTime ?? .now, endTime: .now, content: "")
            timeItem.eventId = timerModel.timingItem?.id ?? ""
            MainView.selectedTimeItem = timeItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showTimelineView.toggle()
            }
            if let timingItem = timerModel.timingItem {
                timingItem.isPlay = false
                modelData.updateItem(timingItem)
            }
            timerModel.stopTimer()
        })
        .padding(.horizontal, 25)
        .frame(height: 60)
        .offset(y: -55)
        .background {
            ZStack {
                Rectangle()
                    .frame(height: 60)
                    .cornerRadius(10)
                    .foregroundStyle(Color.init(hex: "fdfefe"))
                    .offset(y: -55)
            }
            .padding(.horizontal, 15)
            .shadow(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5)
            .shadow(color: .primary.opacity(0.06), radius: 5, x: -5, y: -5)
        }
    }
    
    func timingTagColor() -> Color {
        let tagHexColor = modelData.tagList.first { $0.id == (timerModel.timingItem?.tag ?? "")
        }?.hexColor
        var tagColor: Color = .black
        if let tagHexColor  {
            tagColor = Color.init(hex: tagHexColor)
        }
        return tagColor
    }
}

// 预览代码
struct TimerDisplayView_Previews: PreviewProvider {
    @StateObject static var timerModel = TimerModel()
    @State static var showTimelineView = false
    
    static var previews: some View {
        TimerDisplayView(timerModel: timerModel, showTimelineView: $showTimelineView)
    }
}
