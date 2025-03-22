import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var modelData: ModelData
    @State var newItemText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 底部输入框
            HStack(alignment: .top) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 3)
                    .frame(height: 80)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $newItemText)
                        .font(.system(size: 14))
                        .onChange(of: newItemText) { newValue in
                            if newValue.contains("\n") {
                                newItemText = newValue.replacingOccurrences(of: "\n", with: "")
                                addSummaryItem()
                            }
                        }
                        .onSubmit {
                            addSummaryItem()
                        }
                        .background(
                            Button(action: addSummaryItem) {}
                                .frame(width: 0, height: 0)
                                .opacity(0)
                                .keyboardShortcut(.return)
                        )
                    
                    if newItemText.isEmpty {
                        Text("在这里快速添加新的感想")
                            .foregroundColor(Color(.placeholderTextColor))
                            .padding(.top, 1)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: 20)
                .padding(.top, 5)
                
                Button {
                    addSummaryItem()
                } label: {
                    Image(systemName: "return")
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
                .buttonStyle(BorderlessButtonStyle())
                
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 300, height: 100)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
    }
    
    func addSummaryItem() {
        guard !newItemText.isEmpty else { return }
        let summaryItem = SummaryItem()
        summaryItem.content = newItemText
        modelData.updateSummaryItem(summaryItem)
        newItemText = ""
        dismiss()
    }
}


struct TaskSaveView: View {
    
    @State var timerModel: TimerModel
    @State var taskContent: String = ""
    @State var eventContent: String = ""
    @EnvironmentObject var modelData: ModelData
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case title
        case event
    }
    
    var body: some View {
        VStack(spacing: 5) {
            if timerModel.isTiming {
                TextField("填写任务描述", text: $taskContent)
                    .focused($focusedField, equals: .title)
                    .onSubmit {
                        addTaskTimeItem()
                    }
                    .background(
                        Button(action: addTaskTimeItem) {}
                            .frame(width: 0, height: 0)
                            .opacity(0)
                            .keyboardShortcut(.return)
                    )
                    .padding()
            }
            
            TextField("添加任务", text: $taskContent)
                .focused($focusedField, equals: .event)
                .onSubmit {
                    addTaskTimeItem()
                }
                .background(
                    Button(action: addTaskTimeItem) {}
                        .frame(width: 0, height: 0)
                        .opacity(0)
                        .keyboardShortcut(.return)
                )
                .padding()
            
            Spacer()
            
        }
        .onAppear {
            if timerModel.isTiming {
                self.focusedField = .title
            } else {
                self.focusedField = .event
            }
        }
    }
    
    func addTaskTimeItem() {
        if let item = timerModel.timingItem, let playTime = item.playTime {
            timerModel.stopTimer()
            
            let taskItem = TaskTimeItem(startTime: playTime, endTime: .now, content: taskContent)
            taskItem.eventId = item.id
            modelData.updateTimeItem(taskItem)
            
            item.isPlay = false
            modelData.updateItem(item)
        }
        taskContent = ""
        dismiss()
    }
    
    func addEventItem() {
        var event = EventItem()
        event.title = eventContent
        modelData.updateItem(event)
        
        eventContent = ""
        dismiss()
    }
    
}
