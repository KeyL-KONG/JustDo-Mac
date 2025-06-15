import SwiftUI

struct TimeLineRowView: View {
    @EnvironmentObject var modelData: ModelData
    @Binding var selectItemID: String
    @State var item: TaskTimeItem
    @Binding var isEditing: Bool
    @State var onlyStarTime: Bool = false
    @State var setRepeat: Bool = false
    @State var itemContent: String = ""
    @State var showEventConvertWindow: Bool = false
    
    private static let noneStateText = "无"
    @State var selectProjectStateTitle: String = Self.noneStateText
    var eventItem: EventItem? {
        return modelData.itemList.first { $0.id == item.eventId }
    }
    
    var projectStatesTitleList: [String] {
        return [Self.noneStateText] + modelData.noteTagList.filter { tag in
            guard let eventItem = self.eventItem, tag.projectId.count > 0 else { return false }
            return eventItem.id == tag.projectId || eventItem.fatherId == tag.projectId || eventItem.projectId == tag.projectId
        }.compactMap { $0.content }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        VStack {
            if item.isPlan {
                HStack {
                    Toggle(isOn: $setRepeat) {
                        Text("设置每日重复计划时间")
                    }
                    Spacer()
                }
            }
            HStack(alignment: .center) {
                if isEditing {
                    if onlyStarTime {
                        DatePicker("", selection: $item.startTime, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                    } else {
                        HStack {
                            DatePicker("", selection: $item.startTime, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                            Text("-")
                            DatePicker("", selection: $item.endTime, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                        }.frame(maxWidth: 300)
                    }
                    
                    if item.state != .none {
                        if item.state == .good {
                            Text("✅")
                        } else if item.state == .bad {
                            Text("❌").font(.system(size: 11))
                        }
                        Spacer()
                    }
                    
                    Spacer()
                    
                    if projectStatesTitleList.count > 1 {
                        Picker("设置状态", selection: $selectProjectStateTitle) {
                            ForEach(projectStatesTitleList, id: \.self) { state in
                                Text(state).tag(state)
                            }
                        }.frame(maxWidth: 150)
                    }
                    
                    Button("转换为子任务") {
                        guard let event = modelData.itemList.first(where: { $0.id == item.eventId
                        }) else { return }
                        let newEvent = EventItem()
                        newEvent.title = "新建事项"
                        newEvent.actionType = .task
                        newEvent.mark = item.content
                        newEvent.tag = event.tag
                        newEvent.fatherId = event.id
                        newEvent.setPlanTime = true
                        newEvent.planTime = item.startTime
                        newEvent.isFinish = true
                        modelData.updateItem(newEvent) {
                            item.eventId = newEvent.id
                            modelData.updateTimeItem(item)
                            selectItemID = newEvent.id
                        }
                    }
                    
                    Button("完成") {
                        isEditing = false
                        updateItem()
                    }.foregroundStyle(.blue)
                } else {
                    Text(item.startTime.simpleDateStr)
                    if !onlyStarTime {
                        Text("-")
                        Text(item.endTime.simpleDateStr)
                        if item.interval > 0 {
                            Text("(\(item.interval.simpleTimeStr))")
                        }
                    }
                    
                    if item.state != .none {
                        if item.state == .good {
                            Text("✅")
                        } else if item.state == .bad {
                            Text("❌").font(.system(size: 11))
                        }
                    }
                    
                    if selectProjectStateTitle != Self.noneStateText {
                        tagView(title: selectProjectStateTitle, color: .blue)
                    }
                    
                    Spacer()
                    Button("编辑") {
                        isEditing = true
                    }.foregroundStyle(.blue)
                }
            }
            
            
            if isEditing {
                TextEditor(text: $itemContent)
                    .font(.system(size: 14))
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(Color.init(hex: "#e8f6f3"))
                    .frame(minHeight: 120)
                    .cornerRadius(8)
            } else if itemContent.count > 0 {
                MarkdownWebView(itemContent, itemId: item.id)
            }
            
        }
        .padding()
        .background(isEditing ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
        .cornerRadius(10)
        .onChange(of: setRepeat, { oldValue, newValue in
            updateItem()
        })
        .onAppear {
            itemContent = item.content
            setRepeat = item.isRepeat
            selectProjectStateTitle = modelData.noteTagList.first(where: {  $0.id == item.stateTagId && item.stateTagId.count > 0 })?.content ?? Self.noneStateText
        }
        .sheet(isPresented: $showEventConvertWindow) {
            EventConvertWindowView(showWindow: $showEventConvertWindow, item: item).environmentObject(modelData)
        }
    }
    
    func updateItem() {
        item.isRepeat = setRepeat
        item.content = itemContent
        if let tag = modelData.noteTagList.first(where: { $0.content == selectProjectStateTitle
        }), selectProjectStateTitle != Self.noneStateText {
            item.stateTagId = tag.id
        }
        modelData.updateTimeItem(item)
    }
    
    func tagView(title: String, color: Color, size: CGFloat = 12, verPadding: CGFloat = 10, horPadding: CGFloat = 5) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: size))
            .padding(.horizontal, verPadding)
            .padding(.vertical, horPadding)
            .background(color)
            .clipShape(Capsule())
    }
    
}
