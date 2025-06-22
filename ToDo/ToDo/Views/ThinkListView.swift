//
//  ThinkListView.swift
//  ToDo
//
//  Created by LQ on 2025/6/2.
//

import SwiftUI

struct ThinkListView: View {
    
    @Binding var selectItemID: String
    @EnvironmentObject var modelData: ModelData
    
    @State var thinkList: [SummaryItem] = []
    
    var body: some View {
        VStack {
            List(selection: $selectItemID) {
                ForEach(thinkList, id: \.self.id) { think in
                    thinkItemView(think).id(think.id)
                        .contextMenu {
                            Button {
                                modelData.deleteSummaryItem(think)
                            } label: {
                                Text("删除").foregroundStyle(.red)
                            }
                        }
                }
            }
        }
        .onChange(of: modelData.updateSummaryItemIndex, { oldValue, newValue in
            updateThinkList()
        })
        .onAppear {
            updateThinkList()
            if !self.thinkList.contains(where: { $0.id == selectItemID }) {
                self.selectItemID = thinkList.first?.id ?? selectItemID
            }
        }
        .toolbar {
            Button {
                let item = SummaryItem()
                item.content = "新想法"
                modelData.updateSummaryItem(item)
            } label: {
                Text("添加想法")
            }
        }
    }
    
    func thinkItemView(_ item: SummaryItem) -> some View {
        HStack {
            Text(item.simpleTitle)
            Spacer()
            if item.tags.count > 0 {
                ForEach(item.tags, id: \.self) { tagId in
                    if let noteTag = modelData.noteTagList.first(where: {
                        $0.id == tagId
                    }) {
                        tagView(title: noteTag.content, color: .blue)
                    }
                }
            }
            if let updateTime = item.updateAt {
                Text(updateTime.simpleDateStr).foregroundStyle(.gray)
            }
        }
        .padding(.vertical, 5)
    }
}

extension ThinkListView {
    
    func updateThinkList() {
        self.thinkList = modelData.summaryItemList.filter { !$0.isSummary}.sorted(by: { ($0.updateAt?.timeIntervalSince1970 ?? 0) > ($1.updateAt?.timeIntervalSince1970 ?? 0)
        })
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 10))
            .padding(EdgeInsets.init(top: 2, leading: 2, bottom: 2, trailing: 2))
            .background(color)
            .clipShape(Capsule())
    }
}
