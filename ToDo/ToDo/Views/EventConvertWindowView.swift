//
//  EventConvertWindowView.swift
//  ToDo
//
//  Created by ByteDance on 2025/6/13.
//

import SwiftUI

struct EventConvertWindowView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Binding var showWindow: Bool
    @State var item: TaskTimeItem
    
    @State var titleText: String = ""
    @State var actionType: EventActionType = .task
    @State var actionList: [EventActionType] = [.task, .project, .tag]
    @State var selectedTag: String = ""
    
    @State var selectEvent: String = ""
    var eventListTitle: [String] {
        return ["无"] + modelData.itemList.filter { event in
            if event.actionType != actionType { return false }
            
            if let tag = modelData.tagList.first(where: { $0.id == event.tag
            }), tag.title != selectedTag {
                return false
            }
            return true
        }.compactMap { $0.title }
    }
    
    @State var markText: String = ""
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("设置转换事件").bold()
            }
            
            TextField("输入标题", text: $titleText)
            
            Picker("选择类型", selection: $actionType) {
                ForEach(actionList, id: \.self) { type in
                    Text(type.title).tag(type)
                }
            }
            
            Picker("选择标签", selection: $selectedTag) {
                ForEach(modelData.tagList.sorted(by: { first, second in
                    let eventList = modelData.itemList
                    return eventList.filter { $0.tag == first.id }.count > eventList.filter { $0.tag == second.id}.count
                }).map({$0.title}), id: \.self) { title in
                    if let tag = modelData.tagList.first(where: { $0.title == title}) {
                        Text(tag.title).tag(tag)
                    }
                }
            }
            
            Picker("选择事件", selection: $selectEvent) {
                ForEach(eventListTitle, id: \.self) { fatherTitle in
                    Text(fatherTitle).tag(fatherTitle)
                }
            }
            
            TextEditor(text: $markText)
                .scrollContentBackground(.hidden)
                .background(Color.init(hex: "#e8f6f3"))
                .frame(minHeight: 50)
                .cornerRadius(5)
            
            HStack(spacing: 50) {
                Button {
                    showWindow = false
                } label: {
                    Text("取消").foregroundStyle(.red)
                }
                
                Button {
                    showWindow = false
                } label: {
                    Text("确定").foregroundStyle(.blue)
                }
            }
        }
        .padding()
        .onAppear {
            markText = item.content
            if let event = modelData.itemList.first(where: { $0.id == item.eventId
            }) {
                
            }
        }
    }
}
