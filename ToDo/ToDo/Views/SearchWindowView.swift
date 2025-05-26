//
//  SearchWindowView.swift
//  ToDo
//
//  Created by ByteDance on 2025/5/26.
//

import SwiftUI

struct SearchWindowView: View {
    
    enum SearchType {
        case event
        case task
        case read
        case think
        case principle
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
    @Binding var selectionId: String
    @State var searchText: String = ""
    @State var searchItems: [SearchItem] = []
    
    
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
            }
            .padding(.top, 20)
            .padding(.horizontal, 10)
            
            List(selection: $selectionId) {
                ForEach(searchTextItems, id: \.self.id) { item in
                    searchItemView(item: item).tag(item.id)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .onChange(of: selectionId, { oldValue, newValue in
            if selectionId.count > 0 {
                showSearchWindowView = false
            }
        })
        .frame(minWidth: 800, minHeight: 400)
        .cornerRadius(15)
        .onAppear {
            buildSearchItems()
        }
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
            Text(item.time.simpleDateStr)
        }.padding(.vertical, 5)
    }
}

extension SearchWindowView {
    
    func buildSearchItems() {
        let eventList = modelData.itemList
        let taskItems = modelData.taskTimeItems
        let readItems = modelData.readList
        let thinkItems = modelData.summaryItemList
        let principleItems = modelData.principleItems
        
        var searchItems = [SearchItem]()
        searchItems += eventList.compactMap { event in
            return SearchItem(type: .event, id: event.id, content: [event.title, event.mark, event.reviewText], time: event.createTime ?? .now)
        }
        searchItems += taskItems.compactMap({ task in
            return SearchItem(type: .task, id: task.id, content: [task.content], time: task.createTime ?? .now)
        })
        searchItems += readItems.compactMap({ read in
            return SearchItem(type: .read, id: read.id, content: [read.title, read.note], time: read.createTime ?? .now)
        })
        searchItems += thinkItems.compactMap({ item in
            return SearchItem(type: .think, id: item.id, content: [item.content], time: item.createTime ?? .now)
        })
        searchItems += principleItems.compactMap({ principle in
            return SearchItem(type: .principle, id: principle.id, content: [principle.content], time: principle.createTime ?? .now)
        })
        
        // 添加去重逻辑
        var uniqueItems = [String: SearchItem]()
        for item in searchItems {
            uniqueItems[item.id] = item
        }
        self.searchItems = Array(uniqueItems.values).sorted(by: {  $0.time > $1.time })
    }
}
