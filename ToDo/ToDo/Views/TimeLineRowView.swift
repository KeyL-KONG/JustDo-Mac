import SwiftUI

struct TimeLineRowView: View {
    var item: TaskTimeItem
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack {
                Text(timeFormatter.string(from: item.startTime))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(timeFormatter.string(from: item.endTime))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Text(item.content)
                .font(.system(size: 14))
                .padding(.vertical, 4)
                
            Spacer()
        }
        .padding(.horizontal)
        .background(Color(.systemBlue))
    }
}
