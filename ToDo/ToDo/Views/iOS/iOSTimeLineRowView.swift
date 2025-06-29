import SwiftUI
#if os(iOS)

struct iOSTimeLineRowView: View {
    @EnvironmentObject var modelData: ModelData
    
    @State var item: TaskTimeItem
    @Binding var isEditing: Bool
    @State var onlyStarTime: Bool = false
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        if item.content.count > 0 {
            VStack(spacing: 5) {
                HStack {
                    DatePicker("", selection: $item.startTime, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact).scaleEffect(0.6)
                        .disabled(true)
                    Text("-")
                    DatePicker("", selection: $item.endTime, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact).scaleEffect(0.6)
                        .disabled(true)
                }
                
                MarkdownWebView(item.content)
                    .padding(.horizontal, 40)
            }
        } else {
            HStack {
                DatePicker("", selection: $item.startTime, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact).scaleEffect(0.6)
                    .disabled(true)
                Text("-")
                DatePicker("", selection: $item.endTime, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact).scaleEffect(0.6)
                    .disabled(true)
            }
        }
    }
    
}


struct EditTimeLineRowView: View {
    
    @Binding var showSheetView: Bool
    @State var item: TaskTimeItem
    @State var startTime: Date = .now
    @State var endTime: Date = .now
    @State var setIsPlan: Bool = false
    @State var recordContent: String = ""
    @EnvironmentObject var modelData: ModelData
    
    var title: String {
        if item.content.count > 0 {
            return item.content
        }
        return modelData.itemList.first { $0.id == item.eventId }?.title ?? ""
    }
    
    @FocusState var focusedField: FocusedField?
    enum FocusedField {
        case record
    }
    
    var navigationTitle: String {
        item.isPlan ? "编辑计划" : "编辑记录"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("")
                    .navigationBarTitle(Text(navigationTitle), displayMode: .inline)
                    .navigationBarItems(leading: HStack(content: {
                        Button(action: {
                            self.showSheetView = false
                        }, label: {
                            Text("取消").bold()
                        })
                        
                        Button(action: {
                            modelData.deleteTimeItem(item)
                            self.showSheetView = false
                        }, label: {
                            Text("删除").bold().foregroundStyle(.red)
                        })
                    }), trailing: Button(action: {
                        self.showSheetView = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.saveItem()
                        }
                    }, label: {
                        Text("保存").bold()
                    }))
                
                List {
                    Section {
                        if title.count > 0 {
                            Text(title)
                        }
                        let components: DatePickerComponents = [.date, .hourAndMinute]
                        DatePicker(selection: $startTime, displayedComponents: components) {
                            Text("开始时间")
                        }
                        DatePicker(selection: $endTime, displayedComponents: components) {
                            Text("结束时间")
                        }
                        Toggle("设置为计划时间", isOn: $setIsPlan)
                    }
                    
                    Section {
                        TextEditor(text: $recordContent)
                            .focused($focusedField, equals: .record)
                            .font(.system(size: 15))
                            .frame(minHeight: 100)
                    }
                }
            }
        }.onAppear {
            startTime = item.startTime
            endTime = item.endTime
            recordContent = item.content
            setIsPlan = item.isPlan
            focusedField = .record
        }
    }
    
    func saveItem() {
        item.startTime = startTime
        item.endTime = endTime
        item.content = recordContent
        item.isPlan = setIsPlan
        modelData.updateTimeItem(item)
    }
}

#endif
