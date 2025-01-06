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
                        .onSubmit {
                            addSummaryItem(content: newItemText)
                            if !newItemText.isEmpty {
                                newItemText = ""
                            }
                        }
                    
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
                    addSummaryItem(content: newItemText)
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
    
    func addSummaryItem(content: String) {
        guard content.count > 0 else { return }
        let summaryItem = SummaryItem()
        summaryItem.content = content
        modelData.updateSummaryItem(summaryItem)
    }
}
