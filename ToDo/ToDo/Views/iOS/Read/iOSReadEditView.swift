//
//  iOSReadEditView.swift
//  ToDo
//
//  Created by LQ on 2025/8/16.
//
#if os(iOS)

import SwiftUI
import Foundation

struct iOSReadEditView: View {
    
    enum FocusedField {
        case url
        case title
        case content
        case tag
    }
    
    @EnvironmentObject var modelData: ModelData
    @State public var readItem: ReadModel? = nil
    
    @Binding var showSheetView: Bool
    @State var urlText: String = ""
    @State var titleText: String = ""
    @State var contentText: String = ""
    @FocusState private var focusedField: FocusedField?
    @State var readTag: String = ""
    @State var presentAlert = false
    @State private var newReadTag = ""
    
    @State var intervals: [LQDateInterval] = []
    @State var isTimeExpand: Bool = false
    @State var rating: Double = 0.0
    @State var tags: [String] = []
    @State var selectTags: [String] = []
    @State var tagText: String = ""
    
    @State var showingTimeTaskItemView: Bool = false
    static var selectedTaskItem: TaskTimeItem? = nil
    
    var taskTimeItems: [TaskTimeItem] {
        guard let readItem else { return [] }
        return modelData.taskTimeItems.filter { item in
            return item.eventId == readItem.id
        }.sorted(by: {
            $0.startTime.timeIntervalSince1970 > $1.startTime.timeIntervalSince1970
        })
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                #if os(iOS)
                Text("")
                    .navigationBarTitle(Text("创建阅读事项"), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        self.showSheetView = false
                    }, label: {
                        Text("取消").bold()
                    }), trailing: Button(action: {
                        saveReadItem()
                        self.showSheetView = false
                    }, label: {
                        Text("保存").bold()
                    }))
                #endif
                
                List {
                    Section {
                        TextField("URL", text: $urlText, axis: .vertical)
                            .focused($focusedField, equals: .url)
                        
                        TextField("标题", text: $titleText, axis: .vertical)
                            .focused($focusedField, equals: .title)
                        
                        if titleText.isEmpty {
                            Button("获取标题") {
                                fetchTitle(url: urlText)
                            }
                        }
                        
                        RatingView(maxRating: 5, rating: $rating).previewLayout(.sizeThatFits)
                    }
                    
                    Section {
                        
                        ZStack {
                            TextField("标签", text: $tagText, axis: .vertical)
                                .focused($focusedField, equals: .tag)
                                .onChange(of: tagText) { oldValue, newValue in
                                    if tags.contains(where: { $0 == newValue }), !selectTags.contains(newValue) {
                                        selectTags.append(newValue)
                                    }
                                }
                        }.overlay(alignment: .bottomTrailing) {
                            if tagText.count > 0 && !tags.contains(tagText) {
                                Spacer()
                                Button {
                                    addReadTag(tag: tagText)
                                    tagText = ""
                                } label: {
                                    Text("添加").foregroundStyle(.blue)
                                }

                            }
                        }
                        
                        MultiSelectTagListView(tags: tags, selectedTags: $selectTags)
                            .padding(.init(top: -15, leading: -20, bottom: -15, trailing: -20))
                        
                        
                        
                    }
                    
                    Section {
                        
                        TextField("备注", text: $contentText, axis: .vertical)
                            .focused($focusedField, equals: .content)
                    }
                    
                    timeIntervalView()
                }
#if os(iOS)
                .listStyle(.insetGrouped)
#endif
            }
        }
        .sheet(isPresented: $showingTimeTaskItemView) {
            if let selectedItem = Self.selectedTaskItem {
                EditTimeLineRowView(showSheetView: $showingTimeTaskItemView, item: selectedItem)
                    .environmentObject(modelData)
                    .presentationDetents([.height(450)])
            }
        }
        .onAppear {
            if let readItem = readItem {
                urlText = readItem.url
                titleText = readItem.title
                contentText = readItem.note
                //focusedField = .content
                intervals = readItem.intervals.sorted(by: { $0.start.timeIntervalSince1970 >= $1.start.timeIntervalSince1970 })
                isTimeExpand = readItem.intervals.count > 0
                rating = readItem.rate
                self.selectTags = modelData.readTagList.filter({ tag in
                    readItem.tags.contains(tag.id)
                }).compactMap { $0.type }
            } else {
                if iOSReadListView.pastedURL.count > 0 {
                    urlText = iOSReadListView.pastedURL
                    focusedField = .title
                    iOSReadListView.pastedURL = ""
                    fetchTitle(url: urlText)
                } else {
                    focusedField = .url
                }
                readTag = ReadTag.createTag.type
            }
            self.tags = modelData.readTagList.compactMap { $0.type }
            
        }
        .onDisappear {
            if let _ = readItem {
                saveReadItem()
            }
        }
        
    }
    
    func addReadTag(tag: String) {
        self.selectTags.append(tag)
        if modelData.readTagList.contains(where: { $0.type == tag }) {
            return
        }
        let model = ReadTag()
        model.type = tag
        modelData.updateReadTag(model)
    }
    
    private func saveReadItem() {
        let readItem = readItem ?? ReadModel()
        readItem.url = urlText
        readItem.title = titleText
        readItem.note = contentText
        if readTag != ReadTag.createTag.type {
            readItem.tag = readTag
        }
        readItem.rate = rating
        readItem.intervals = intervals
        readItem.tags = selectTags.compactMap { title in
            modelData.readTagList.first { $0.type == title }?.id
        }
        modelData.updateReadModel(readItem)
    }
    
    func fetchTitle(url: String) {
        if url.contains("douyin") {
            WebTitleFetcher.shared.fetchDouyinTitleFromWeb(url: url) { title, error in
                if let title, self.titleText.isEmpty {
                    self.titleText = title
                } else if let error {
                    print("fetch douyin title error: \(error)")
                }
            }
        } else {
            WebTitleFetcher.shared.fetchTitle(from: url) { result in
                switch result {
                case .success(let title):
                    if self.titleText.isEmpty {
                        self.titleText = title
                    }
                case .failure(let failure):
                    print("fetch title error: \(failure)")
                }
            }
        }
    }
    
    
    var taskTotalTime: Int {
        taskTimeItems.compactMap { $0.interval}.reduce(0, +)
    }
    
    // MARK: time interval
    func timeIntervalView() -> some View {
        Section(header:
            HStack() {
                Text("阅读记录")
                Text("\(taskTotalTime.simpleTimeStr)")
                Spacer()
                Button {
                    let item = TaskTimeItem(startTime: .now, endTime: .now, content: "")
                    item.eventId = readItem?.id ?? ""
                    modelData.updateTimeItem(item)
                } label: {
                    let recordCount = taskTimeItems.count
                    if recordCount > 0 {
                        Text("添加记录 (\(recordCount))").font(.system(size: 14))
                    } else {
                        Text("添加第一条记录").font(.system(size: 14))
                    }
                }
            
                Button(action: {
                    withAnimation {
                        self.isTimeExpand = !self.isTimeExpand
                    }
                }, label: {
                    Image(systemName: isTimeExpand ? "chevron.up" : "chevron.right")
                })
            }
        ) {
            if isTimeExpand {
                ForEach(taskTimeItems) { item in
                    iOSTimeLineRowView(
                        item: item,
                        isEditing: .constant(true)
                    )
                    .swipeActions(content: {
                        Button {
                            modelData.deleteTimeItem(item)
                        } label: {
                            Text("删除")
                        }.tint(.red)
                        
                        Button {
                            Self.selectedTaskItem = item
                            self.showingTimeTaskItemView.toggle()
                        } label: {
                            Text("编辑")
                        }.tint(.green)
                    })
                }
            }
            
        }
    }
    
}

struct EditReadItemViewPreview: PreviewProvider {
    
    static var previews: some View {
        iOSReadEditView(showSheetView: .constant(true))
    }
    
}

#endif
