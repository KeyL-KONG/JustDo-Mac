import SwiftUI

struct TimeLineRowView: View {
    @EnvironmentObject var modelData: ModelData
    
    @State var item: TaskTimeItem
    @Binding var isEditing: Bool
    @State var onlyStarTime: Bool = false
    @State var setRepeat: Bool = false
    @State var itemContent: String = ""
    
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
                            Text("start:")
                            DatePicker("", selection: $item.startTime, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                        }
                        
                        HStack {
                            Text("end:")
                            DatePicker("", selection: $item.endTime, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                        }
                    }
                    
                    if item.state != .none {
                        if item.state == .good {
                            Text("✅")
                        } else if item.state == .bad {
                            Text("❌").font(.system(size: 11))
                        }
                        Spacer()
                    }
                    
                    Button("完成") {
                        isEditing = false
                        item.content = itemContent
                        modelData.updateTimeItem(item)
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
        }
    }
    
    func updateItem() {
        item.isRepeat = setRepeat
        modelData.updateTimeItem(item)
    }
    
}

#Preview {
    TimeLineRowView(item: TaskTimeItem(startTime: .now, endTime: .now, content: "测试内容"), isEditing: .constant(true))
}
