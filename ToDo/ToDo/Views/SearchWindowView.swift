//
//  SearchWindowView.swift
//  ToDo
//
//  Created by ByteDance on 2025/5/26.
//

import SwiftUI

struct SearchWindowView: View {
    
    enum SearchType: String {
        case all
        case event
        case task
        case read
        case think
        case principle
        case note
        
        static let types: [SearchType] = [.all, .note, .event, .read, .think, .principle, .task]
        
        var section: ToDoSection {
            switch self {
            case .all:
                return .all
            case .event:
                return .all
            case .task:
                return .all
            case .read:
                return .all
            case .think:
                return .all
            case .principle:
                return .principle
            case .note:
                return .note
            }
        }
        
        var titleColor: Color {
            switch self {
            case .all:
                return .blue
            case .event:
                return Color.init(hex: "85c1e9")
            case .task:
                return Color.init(hex: "2ecc71")
            case .read:
                return Color.init(hex: "#884ea0")
            case .think:
                return Color.init(hex: "bb8fce")
            case .principle:
                return Color.init(hex: "dc7633")
            case .note:
                return Color.init(hex: "117a65")
            }
        }
    }
    
    struct SearchItem {
        let type: SearchType
        let id: String
        let content: [String]
        let time: Date
        
        var displayText: String {
            var text = ""
            content.forEach { str in
                text += "\(str) "
            }
            return text
        }
        
        func containsText(_ text: String) -> Bool {
            let lowerText = text.lowercased()
            for str in content {
                if str.lowercased().contains(lowerText) {
                    return true
                }
            }
            return false
        }
    }
    
    @EnvironmentObject var modelData: ModelData
    
    @Binding var showSearchWindowView: Bool
    @Binding var section: ToDoSection
    @Binding var selectionId: String
    @State var searchText: String = ""
    @State var searchItems: [SearchItem] = []
    @State var searchType: String = ""
    var searchTypeList: [SearchType] {
        SearchType.types
    }
    
    var currentSearchType: SearchType {
        return SearchType(rawValue: searchType) ?? .all
    }
    
    var searchTextItems: [SearchItem] {
        if searchText.isEmpty { return [] }
        return self.searchItems.filter { $0.containsText(self.searchText) }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass").font(.title2)
                
                TextField("搜索", text: $searchText)
                    .font(.title2)
                    .textFieldStyle(.plain)
                
                Spacer()
                if searchText.count > 0 {
                    Picker("", selection: $searchType) {
                        ForEach(searchTypeList, id: \.self) { type in
                            Text(type.rawValue).tag(type.rawValue)
                        }
                    }.frame(width: 90)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 10)
            
            List {
                ForEach(searchTextItems, id: \.self.id) { item in
                    searchItemView(item: item).tag(item.id)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            print("search select id: \(item.id)")
                            selectionId = item.id
                            updateSection(selectionId: item.id)
                            showSearchWindowView = false
                        }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .onChange(of: searchType, { oldValue, newValue in
            if oldValue.count > 0, newValue.count > 0 {
                buildSearchItems()
            }
        })
        .frame(minWidth: 800, minHeight: 400)
        .cornerRadius(15)
        .onAppear {
            self.searchType = SearchType.all.rawValue
            buildSearchItems()
        }
    }
    
    func updateSection(selectionId: String) {
        guard let item = searchItems.first(where: { $0.id == selectionId }) else {
            return
        }
        self.section = item.type.section
    }
    
    func searchItemView(item: SearchItem) -> some View {
        HStack {
            let fullText = item.displayText
            let lowerText = fullText.lowercased()
            let searchLower = searchText.lowercased()
            
            if let range = lowerText.range(of: searchLower) {
                let start = fullText.index(range.lowerBound, offsetBy: -20, limitedBy: fullText.startIndex) ?? fullText.startIndex
                let end = fullText.index(range.upperBound, offsetBy: 20, limitedBy: fullText.endIndex) ?? fullText.endIndex
                
                let prefix = String(fullText[start..<range.lowerBound])
                let match = String(fullText[range])
                let suffix = String(fullText[range.upperBound..<end])
                
                Text(prefix)
                    .font(.system(size: 14)) +
                Text(match)
                    .bold()
                    .foregroundColor(.red)
                    .font(.system(size: 14)) +
                Text(suffix)
                    .font(.system(size: 14))
            } else {
                Text(fullText)
                    .font(.system(size: 14))
            }
            Spacer()
            
            tagView(title: item.type.rawValue, color: item.type.titleColor)
            
            Text(item.time.simpleDateStr).frame(width: 80)
        }.padding(.vertical, 5)
            .padding(.horizontal, 10)
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

extension SearchWindowView {
    
    func buildSearchItems() {
        let eventList = modelData.itemList
        let taskItems = modelData.taskTimeItems
        let readItems = modelData.readList
        let thinkItems = modelData.summaryItemList
        let principleItems = modelData.principleItems
        let noteItems = modelData.noteList
        
        var searchItems = [SearchItem]()
        
        if currentSearchType == .all || currentSearchType == .event {
            searchItems += eventList.compactMap { event in
                return SearchItem(type: .event, id: event.id, content: [event.title, event.mark, event.reviewText], time: event.updateAt ?? .now)
            }
        }
        
        if currentSearchType == .all || currentSearchType == .note {
            searchItems += noteItems.compactMap({ note in
                return SearchItem(type: .note, id: note.id, content: [note.title, note.content], time: note.updateAt ?? .now)
            })
        }
        
        if currentSearchType == .all || currentSearchType == .task {
            searchItems += taskItems.compactMap({ task in
                return SearchItem(type: .task, id: task.id, content: [task.content], time: task.updateAt ?? .now)
            })
        }
        
        if currentSearchType == .all || currentSearchType == .read {
            searchItems += readItems.compactMap({ read in
                return SearchItem(type: .read, id: read.id, content: [read.title, read.note], time: read.updateAt ?? .now)
            })
        }
        
        if currentSearchType == .all || currentSearchType == .think {
            searchItems += thinkItems.compactMap({ item in
                return SearchItem(type: .think, id: item.id, content: [item.content], time: item.updateAt ?? .now)
            })
        }
        
        if currentSearchType == .all || currentSearchType == .principle {
            searchItems += principleItems.compactMap({ principle in
                return SearchItem(type: .principle, id: principle.id, content: [principle.content], time: principle.updateAt ?? .now)
            })
        }
        
        // 添加去重逻辑
        var uniqueItems = [String: SearchItem]()
        for item in searchItems {
            uniqueItems[item.id] = item
        }
        self.searchItems = Array(uniqueItems.values).sorted(by: {  $0.time > $1.time })
    }
}
