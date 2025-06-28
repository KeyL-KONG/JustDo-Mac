//
//  ReadListView.swift
//  ToDo
//
//  Created by LQ on 2025/6/2.
//

import SwiftUI
#if os(macOS)
struct ReadListView: View {
    
    @Binding var selectItemID: String
    @EnvironmentObject var modelData: ModelData
    
    @State var readlist: [ReadModel] = []
    
    var body: some View {
        VStack {
            List(selection: $selectItemID) {
                ForEach(readlist, id: \.self.id) { item in
                    readItemView(item).id(item.id)
                        .contextMenu {
                            Button {
                                modelData.deleteReadModel(item)
                            } label: {
                                Text("删除").foregroundStyle(.red)
                            }
                        }
                }
            }
        }
        .onChange(of: modelData.updateReadItemIndex, { oldValue, newValue in
            updateReadList()
        })
        .onAppear {
            updateReadList()
            if !self.readlist.contains(where: { $0.id == selectItemID }) {
                self.selectItemID = readlist.first?.id ?? selectItemID
            }
        }
    }
    
    func readItemView(_ item: ReadModel) -> some View {
        HStack {
            Text(item.title)
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

extension ReadListView {
    
    func updateReadList() {
        self.readlist = modelData.readList.sorted(by: { ($0.updateAt?.timeIntervalSince1970 ?? 0) > ($1.updateAt?.timeIntervalSince1970 ?? 0)
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
#endif
