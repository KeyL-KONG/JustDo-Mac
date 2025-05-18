//
//  PlanItemEditView.swift
//  ToDo
//
//  Created by LQ on 2025/5/17.
//

import SwiftUI

struct PlanItemEditView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State var selectedItem: PlanTimeItem?
    
    @State var content: String = ""
    @State var selectedTag: String = "工作"
    @State var startTime: Date = .now
    @State var endTime: Date = .now
    @State var planTime: String = ""
    
    var body: some View {
        VStack {
            List {
                Section {
                    TextField("输入计划标题", text: $content)
                    
                    Picker("选择标签", selection: $selectedTag) {
                        ForEach(modelData.tagList.map({$0.title}), id: \.self) { title in
                            if let tag = modelData.tagList.first(where: { $0.title == title}) {
                                Text(tag.title).tag(tag)
                            }
                        }
                    }
                    
                    DatePicker("计划开始时间", selection: $startTime)
                    DatePicker("计划结束时间", selection: $endTime)
                    HStack {
                        Text("设置计划时长")
                        Spacer()
                        TextField("", text: $planTime).frame(maxWidth: 60)
                            .border(.gray, width: 1)
                            .multilineTextAlignment(.trailing)
                        Text("min")
                    }
                }
            }
        }
        .toolbar(content: {
            Spacer()
            Button("保存") {
                updatePlanItem()
            }.foregroundColor(.blue)
        })
        .onAppear {
            if let selectedItem {
                self.content = selectedItem.content
                self.startTime = selectedItem.startTime
                self.endTime = selectedItem.endTime
                self.selectedTag = modelData.tagList.first(where: { $0.id == selectedItem.tagId
                })?.title ?? "工作"
                self.planTime = selectedItem.timeInterval.stringValue ?? "0"
            }
        }
    }
}

extension PlanItemEditView {
    
    func updatePlanItem() {
        let item = selectedItem ?? PlanTimeItem()
        item.content = content
        item.startTime = startTime
        item.endTime = endTime
        item.tagId = modelData.tagList.first(where: { $0.title == selectedTag })?.id ?? ""
        item.timeInterval = Int(planTime) ?? 0
        modelData.updatePlanTimeItem(item)
    }
    
}
