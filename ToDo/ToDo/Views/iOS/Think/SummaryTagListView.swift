//
//  SummaryTagListView.swift
//  Summary
//
//  Created by LQ on 2024/7/14.
//

import SwiftUI

struct SummaryTagListView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Binding var showEditTagView: Bool
    @State var showingDeleteAlert: Bool = false
    
    var tagList: [SummaryTag] {
        modelData.summaryTagList.sorted {
            return countSummayTag($0) >= countSummayTag($1)
        }
    }
    
    static var selectedTag: SummaryTag? = nil
    private static var deleteTag: SummaryTag? = nil
    
    var body: some View {
            VStack {
                Text("标签管理").font(.system(size: 20)).bold().multilineTextAlignment(.center)
                    .padding(.top, 15)
                
                
                List {
                    ForEach(tagList) { tag in
                        Button {
                            
                        } label: {
                            HStack {
                                Text(tag.content).foregroundColor(.accentColor)
                                Spacer()
                                Text("\(countSummayTag(tag))次").foregroundColor(.gray)
                            }
                        }
                        .swipeActions {
                            Button("Edit") {
                                Self.selectedTag = tag
                                showEditTagView.toggle()
                            }.tint(.green)
                            
                            Button("Delete") {
                                Self.deleteTag = tag
                                showingDeleteAlert.toggle()
                            }.tint(.red)
                        }
                    }
//                    .onDelete { indexSet in
//                        for index in indexSet.makeIterator() {
//                            let tag = tagList[index]
//                            modelData.deleteSummaryTag(tag)
//                        }
//                    }
                    
                }.padding(.top, 0)
            
        }
        .sheet(isPresented: $showEditTagView, content: {
            EditTagView(showSheetView: $showEditTagView, selectedTag: Self.selectedTag)
                .environmentObject(modelData)
                    .presentationDetents([.height(150)])
        })
        .alert(isPresented: $showingDeleteAlert, content: {
            if let deleteTag = Self.deleteTag {
                return Alert(title: Text("是否删除\"\(deleteTag.content)\"标签"), primaryButton: .destructive(Text("取消")), secondaryButton: .default(Text("确定"), action: {
                    modelData.deleteSummaryTag(deleteTag)
                    Self.deleteTag = nil
                }))
            } else {
                return Alert(title: Text("是否删除标签"), primaryButton: .destructive(Text("取消")), secondaryButton: .default(Text("确定"), action: {
    
                }))
            }
        })
    }
    
    func countSummayTag(_ tag: SummaryTag) -> Int {
        return modelData.summaryItemList.filter { item in
            item.tags.contains { $0 == tag.id }
        }.count
    }
    
}

#Preview {
    SummaryTagListView(showEditTagView: .constant(true))
}
