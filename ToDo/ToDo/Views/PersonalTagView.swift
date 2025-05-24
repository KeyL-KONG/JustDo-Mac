//
//  PersonalTagView.swift
//  ToDo
//
//  Created by LQ on 2025/5/24.
//

import SwiftUI

struct PersonalTagView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @Binding var selectItemID: String
    @State var personalTagList: [PersonalTag] = []
    @State var tagExpandState: [String: Bool] = [:]
    
    var body: some View {
        VStack {
            ForEach(personalTagList, id: \.self.id) { tag in
                tagView(tag: tag).tag(tag.id)
            }
            Spacer()
        }
        .padding()
        .onReceive(modelData.$personalTagList, perform: { _ in
            updateTagList()
        })
        .onAppear {
            updateTagList()
            if let firstTag = personalTagList.first {
                selectItemID = firstTag.id
            }
        }
        .toolbar {
            Button {
                addNewTag()
            } label: {
                Label("Add New Tag", systemImage: "plus")
            }
        }
    }
    
    func addNewTag() {
        let tag = PersonalTag()
        tag.tag = "新建品格"
        modelData.updatePersonalTag(tag)
    }
    
    func tagView(tag: PersonalTag) -> some View {
        let isExpand = expandState(with: tag)
        return VStack {
            let items = eventList(with: tag)
            let totalValue = items.compactMap { $0.num }.reduce(0, +)
            HStack {
                let title = totalValue != 0 ? "\(tag.tag) (\(totalValue.symbolStr))" : tag.tag
                Text(title).font(.system(size: 15)).bold()
                Spacer()
                Image(systemName: isExpand ? "chevron.down" : "chevron.right").frame(width: 20)
                    .onTapGesture {
                        updateExpandState(with: tag)
                    }
            }
            .padding(5)
            .contentShape(Rectangle())
            .onTapGesture {
                self.selectItemID = tag.id
            }
            .background {
                if tag.id == selectItemID {
                    ZStack {
                        Rectangle()
                            .fill(Color.blue.opacity(0.5))
                            .cornerRadius(5)
                    }
                }
            }
            
            if isExpand, items.count > 0 {
                ForEach(items, id: \.self.item.id) { item in
                    HStack {
                        Text(item.item.title).font(.system(size: 12))
                        Spacer()
                        
                        let color = item.num > 0 ? item.tag.goodColor : item.tag.badColor
                        let title = "\(item.tag.tag) \(item.num.symbolStr)"
                        tagView(title: title, color: color)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selectItemID = item.item.id
                    }
                    .background {
                        if item.item.id == selectItemID {
                            ZStack {
                                Rectangle()
                                    .fill(Color.blue.opacity(0.5))
                                    .cornerRadius(5)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    struct PersonalEventItem {
        let item: EventItem
        let tag: PersonalTag
        let num: Int
    }
    
    func updateTagList() {
        self.personalTagList = modelData.personalTagList
    }
    
    func eventList(with tag: PersonalTag) -> [PersonalEventItem] {
        let eventList = modelData.itemList
        return tag.goodEvents.compactMap { (key, value) in
            guard let event = eventList.first(where: { $0.id == key }) else {
                return nil
            }
            return PersonalEventItem.init(item: event, tag: tag, num: value)
        } + tag.badEvents.compactMap { (key, value) in
            guard let event = eventList.first(where: { $0.id == key }) else {
                return nil
            }
            return PersonalEventItem.init(item: event, tag: tag, num: value)
        }.sorted(by: {  $0.num > $1.num
        })
    }
    
    func expandState(with tag: PersonalTag) -> Bool {
        return tagExpandState[tag.id] ?? false
    }
    
    func updateExpandState(with tag: PersonalTag) {
        if let expand = tagExpandState[tag.id] {
            tagExpandState[tag.id] = !expand
        } else {
            tagExpandState[tag.id] = false
        }
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 8))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(color)
            .clipShape(Capsule())
    }
}
