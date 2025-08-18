//
//  iOSReadListView.swift
//  ToDo
//
//  Created by LQ on 2025/8/16.
//
#if os(iOS)

import SwiftUI

struct iOSReadListView: View {
    @EnvironmentObject var modelData: ModelData
    var selectDate: Date
    var timeTab: TimeTab
    
    @State private var showingSheet = false
    static var selectedReadItem: ReadModel?
    static var pastedURL: String = ""
    
    @State var readDict: [(key: String, value: [ReadModel])] = []
    
    var body: some View {
        
        ZStack {
            itemListView()
        }.overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                Self.selectedReadItem = nil
                showingSheet.toggle()
            }, label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
            })
            .padding(15)
        })
        .sheet(isPresented: $showingSheet) {
            if let selectedReadItem = Self.selectedReadItem {
                iOSReadEditView(readItem: selectedReadItem, showSheetView: $showingSheet)
                    .environmentObject(modelData)
            } else {
                iOSReadEditView(showSheetView: $showingSheet)
                    .environmentObject(modelData)
            }
        }
        .onChange(of: selectDate, { oldValue, newValue in
            updateReadList()
        })
        .onChange(of: modelData.updateDataIndex, { oldValue, newValue in
            updateReadList()
        })
        .onChange(of: modelData.updateReadItemIndex, { oldValue, newValue in
            updateReadList()
        })
        .onAppear {
            updateReadList()
            checkPasteContent()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            checkPasteContent()
        }
    }
}

extension iOSReadListView {
    
    func updateReadList() {
        let readItems = modelData.readList.filter { read in
            guard let createTime = read.createTime else { return false }
            return createTime.isSameTime(timeTab: timeTab, date: selectDate)
        }
        print("update readlist: \(readItems.count)")
        self.readDict = Dictionary(grouping: readItems) { model in
            return model.createTime!.dateString
        }.sorted { entry1, entry2 in
            return entry1.value.first?.createTime?.timeIntervalSince1970 ?? 0 >= entry2.value.first?.createTime?.timeIntervalSince1970 ?? 0
        }
    }
    
    private func checkPasteContent() {
        guard let content = UIPasteboard.general.string, let url = content.extractURL else { return }
        print("paste content: \(url)")
        UIPasteboard.general.string = nil
        Self.pastedURL = url
        Self.selectedReadItem = nil
        showingSheet.toggle()
    }
    
}

extension iOSReadListView {
    func itemListView() -> some View {
        List {
            ForEach(readDict, id: \.key) { key, items in
                Section {
                    ForEach(items) { item in
                        NavigationLink {
                            iOSReadItemDetailView(item: item) {
                                Self.selectedReadItem = item
                                showingSheet.toggle()
                            }.environmentObject(modelData)
                            .navigationBarTitle(Text(""), displayMode: .inline)
                        } label: {
                            iOSReadItemView(item: item, showTime: true)
                                .environmentObject(modelData)
                                .frame(height: item.itemRowHeight)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        modelData.deleteReadModel(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                } header: {
                    Text(key)
                }

            }
        }
        .listStyle(.insetGrouped)
    }
}

#endif
