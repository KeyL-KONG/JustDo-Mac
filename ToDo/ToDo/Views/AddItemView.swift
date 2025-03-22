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
