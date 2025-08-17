//
//  iOSReadItemView.swift
//  ToDo
//
//  Created by LQ on 2025/8/16.
//

import SwiftUI

struct iOSReadItemView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    var item: ReadModel
    @State var showBottomView: Bool = false
    @State var showMark: Bool = true
    @State var tags: [String] = []
    
    var title: String {
        if item.title.count == 0 {
            return "无标题"
        } else {
            return item.title.truncated(limit: 30)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .lineLimit(1)
                .truncationMode(.tail)
            if showBottomView {
                HStack {
                    if tags.count > 0 {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                tagView(title: tag, color: .blue)
                            }
                        }
                    }
                    
                    if item.rate > 0 {
                        RatingView(maxRating: 5, rating: .constant(item.rate), size: 12, spacing: 2.5)
                    }
                    
                    if item.readTimes > 0 {
                        Text("已读\(item.readTimes)次").font(.system(size: 12)).foregroundStyle(.gray)
                    }
                    Spacer()
                }
            }
            if showMark, item.note.count > 0 {
                Text(item.note).font(.system(size: 10)).foregroundStyle(.gray).padding(.top, 5)
            }
        }
        .contextMenu(menuItems: {
            
            Button(role: .destructive) {
                item.finishTimes.append(.now)
                modelData.updateReadModel(item)
            } label: {
                Text("已读").foregroundStyle(.blue)
            }

            Button(role: .destructive) {
                modelData.deleteReadModel(item)
            } label: {
                Text("删除").foregroundColor(.red)
            }
        })
        .onAppear {
            showBottomView = item.tag.count > 0 || item.readTimes > 0 || item.rate > 0
            tags = item.tags.compactMap { tag in modelData.readTagList.first {  $0.id == tag
            }?.type }
        }
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 12))
            .padding(EdgeInsets.init(top: 2, leading: 5, bottom: 2, trailing: 5))
            .background(color)
            .clipShape(Capsule())
    }
    
}

#Preview(body: {
    let model = ReadModel()
    model.title = "测试标题测试标题测试标题测试标题测试标题测试标题测试标题测试标题测试标题"
    model.tag = "iOS"
    model.intervals = [LQDateInterval(start: .now, end: .now)]
    model.rate = 3.0
    return iOSReadItemView(item: model)
})
