//
//  iOSThinkListView.swift
//  ToDo
//
//  Created by LQ on 2025/8/23.
//

import SwiftUI

struct iOSThinkListView: View {
    @EnvironmentObject var modelData: ModelData
    @State var summaryText: String = ""
    @State var inputHeight: CGFloat = 0.0
    @State var noteItems: [NoteItem] = []
    @State var showDeleteAlert: Bool = false
    static var deleteItem: NoteItem?
    
    var body: some View {
        VStack {
            List {
                ForEach(noteItems, id: \.self.id) { item in
                    Section {
                        itemView(item)
                            .swipeActions {
                                Button {
                                    Self.deleteItem = item
                                    self.showDeleteAlert.toggle()
                                } label: {
                                    Text("删除").foregroundStyle(.red)
                                }.tint(.red)
                            }
                    }.padding(.vertical, 15)
                        .background(alignment: .bottomTrailing) {
                            HStack {
                                Spacer()
                                let timeStr = item.createTime!.simpleDateStr
                                Text(timeStr).font(.system(size: 12)).foregroundColor(.secondary)
                            }
                        }
                }
            }
            
            Spacer()
            
            HStack(spacing: 8, content: {
#if os(iOS)
                ResizableTF(txt: $summaryText, height: $inputHeight).frame(height: self.inputHeight < 150 ? self.inputHeight : 150)
                    .padding(.horizontal)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                #endif
                
                Button(action: {
                    saveNoteItem()
                    endEdit()
                }, label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(10)
                })
            })
            .padding(.horizontal)
            .padding(.vertical)
        }
        .alert("删除想法", isPresented: $showDeleteAlert, actions: {
            Button {
                showDeleteAlert = false
            } label: {
                Text("取消").foregroundStyle(.gray)
            }.tint(.gray)
            
            Button {
                if let deleteItem = Self.deleteItem {
                    modelData.deleteNoteItem(deleteItem)
                    Self.deleteItem = nil
                }
            } label: {
                Text("删除").foregroundStyle(.red)
            }.tint(.red)

        }, message: {
            let title = (Self.deleteItem?.content ?? "").truncated(limit: 15)
            Text("是否删除 <\(title)>")
        })
        .onChange(of: modelData.updateNoteItemIndex, { oldValue, newValue in
            self.updateItems()
        })
        .onAppear {
            self.updateItems()
        }
    }
}

extension iOSThinkListView {
    
    func itemView(_ item: NoteItem) -> some View {
        VStack {
            Text(item.content).font(.system(size: 16)).foregroundColor(.black).multilineTextAlignment(.leading)
                .contentShape(Rectangle())
        }
    }
    
    func saveNoteItem() {
        let noteItem = NoteItem()
        noteItem.content = summaryText
        modelData.updateNoteItem(noteItem)
    }
    
    func updateItems() {
        self.noteItems = modelData.noteItemList.sorted(by: { ($0.createTime?.timeIntervalSince1970 ?? 0) > ($1.createTime?.timeIntervalSince1970 ?? 0)
        })
    }
    
    func endEdit() {
#if os(iOS)
        UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
        #endif
    }
    
}
