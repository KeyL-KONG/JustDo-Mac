import SwiftUI

struct TimeLineRowView: View {
    @EnvironmentObject var modelData: ModelData
    
    @State var item: TaskTimeItem
    @Binding var isEditing: Bool
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                if isEditing {
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
                    
                    Button("完成") {
                        isEditing = false
                        modelData.updateTimeItem(item)
                    }.foregroundStyle(.blue)
                } else {
                    Text(item.startTime.simpleDateStr)
                    Text("-")
                    Text(item.endTime.simpleDateStr)
                    if item.interval > 0 {
                        Text("(\(item.interval.simpleTimeStr))")
                    }
                    
                    Spacer()
                    Button("编辑") {
                        isEditing = true
                    }.foregroundStyle(.blue)
                }
            }
            
            
            if isEditing {
                TextEditor(text: $item.content)
                    .font(.system(size: 14))
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(Color.init(hex: "#e8f6f3"))
                    .frame(minHeight: 120)
                    .cornerRadius(8)
            } else {
                MarkdownWebView(item.content)
            }
            
        }
        .padding()
        .background(isEditing ? Color.init(hex: "f8f9f9") : Color.init(hex: "d4e6f1"))
        .cornerRadius(10)
    }
    
}

#Preview {
    TimeLineRowView(item: TaskTimeItem(startTime: .now, endTime: .now, content: "测试内容"), isEditing: .constant(true))
}
