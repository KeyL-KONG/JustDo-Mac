import SwiftUI

struct HorizontalTagListView: View {
    let tags: [String]
    @Binding var selectedTag: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(tags, id: \.self) { tag in
                    SingleTagView(title: tag, isSelected: selectedTag == tag) {
                        if selectedTag == tag {
                            selectedTag = nil
                        } else {
                            selectedTag = tag
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 40)
    }
}

struct SingleTagView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.blue.opacity(0.2))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HorizontalTagListView_Previews: PreviewProvider {
    @State static var selectedTag: String? = "工作"
    
    static var previews: some View {
        HorizontalTagListView(
            tags: ["工作", "学习", "生活", "娱乐", "运动"],
            selectedTag: $selectedTag
        )
    }
}
