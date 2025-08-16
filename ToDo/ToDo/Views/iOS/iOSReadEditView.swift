//
//  iOSReadEditView.swift
//  ToDo
//
//  Created by LQ on 2025/8/16.
//

import SwiftUI
import Foundation

struct iOSReadEditView: View {
    
    enum FocusedField {
        case url
        case title
        case content
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
                    }
                    
                    Section {
                        RatingView(maxRating: 5, rating: $rating).previewLayout(.sizeThatFits)
                        
//                        Picker("标签", selection: $readTag) {
//                            ForEach(modelData.tagList, id: \.self.type) { type in
//                                Text(type.type).tag(type)
//                            }
//                        }.onChange(of: readTag) { newValue in
//                            if newValue == ReadTag.createTag.type {
//                                presentAlert = true
//                            }
//                        }.alert("添加标签", isPresented: $presentAlert) {
//                            TextField("标签类型", text: $newReadTag)
//                            Button("取消") {
//                                
//                            }
//                            Button("确认") {
//                               
//                            }
//                        }
                        
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
        .onAppear {
            if let readItem = readItem {
                urlText = readItem.url
                titleText = readItem.title
                contentText = readItem.note
                //focusedField = .content
                intervals = readItem.intervals.sorted(by: { $0.start.timeIntervalSince1970 >= $1.start.timeIntervalSince1970 })
                isTimeExpand = readItem.intervals.count > 0
                rating = readItem.rate
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
        }
        .onDisappear {
            if let _ = readItem {
                saveReadItem()
            }
        }
        
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
    
    
    // MARK: time interval
    func timeIntervalView() -> some View {
        Section(header:
            HStack(alignment: .center) {
                Text("统计时间")
                Spacer()
                Button {
                    let interval = LQDateInterval(start: .now, end: .now)
                    self.intervals = [interval] + intervals
                    print("add time interval")
                } label: {
                    Text("添加时间").font(.system(size: 14))
                }
            
                Button(action: {
                    withAnimation {
                        self.isTimeExpand = !self.isTimeExpand
                    }
                }, label: {
                    Image(systemName: isTimeExpand ? "chevron.up" : "chevron.right")
                })
            }
        , content: {
            if isTimeExpand {
                ForEach(intervals.indices, id: \.self) { index in
                    let interval = intervals[index]
                    DateIntervalView(interval: interval, index: index) { change in
                        intervals[index] = change
                    }
                }
                .onDelete { indexSet in
                    intervals.remove(atOffsets: indexSet)
                }
                .id(UUID())
            }
        })
    }
    
}

struct EditReadItemViewPreview: PreviewProvider {
    
    static var previews: some View {
        iOSReadEditView(showSheetView: .constant(true))
    }
    
}
