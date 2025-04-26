//
//  ToDoItemListView+Principle.swift
//  ToDo
//
//  Created by LQ on 2025/4/13.
//

import SwiftUI

extension TodoItemListView {
    
    enum PrincipleDisplayMode {
        case week
        case list
        
        var title: String {
            switch self {
            case .week:
                return "周打卡"
            case .list:
                return "列表"
            }
        }
        
        static var allCases: [PrincipleDisplayMode] = [.week, .list]
    }
    
    var principleItems: [PrincipleModel] {
        modelData.principleItems
    }
    
    var ungroupPrincipleItems: [PrincipleModel] {
        modelData.principleItems.filter { $0.tag.isEmpty }
    }
    
    func principleView() -> some View {
        if principleDisplayMode == .list {
            return principleListView()
        } else {
            return principleWeekView()
        }
    }
    
//    var principleWeekDates: [WeekDay] {
//        currentDate.weekDays
//    }
    
    func principleWeekView() -> some View {
        VStack {
            Grid(verticalSpacing: 10) {
                GridRow {
                    Text("原则").bold()
                    ForEach(weekDates, id: \.self) { date in
                        Text(date.simpleDayAndWeekStr)
                            .background {
                                if date.isToday {
                                    Circle()
                                        .fill(.cyan)
                                        .frame(width: 5, height: 5)
                                        .vSpacing(.bottom)
                                        .offset(y: 5)
                                }
                            }
                    }
                }
                Divider()
                
                ForEach(principleItems, id: \.self.id) { item in
                    GridRow {
                        let titleColor = principleTag(item: item)?.titleColor ?? .black
                        Text(item.content).bold().foregroundStyle(titleColor)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectItemID = item.id
                            }
                        ForEach(weekDates, id:\.self) { date in
                            principleWeekItemView(item: item, date: date)
                                .contentShape(Rectangle())
                                .onTapGesture(perform: {
                                    self.selectItemID = item.id
                                })
                                .contextMenu {
                                    Button {
                                        updateTaskItem(item: item, state: .good, date: date)
                                    } label: {
                                        Text("完成").foregroundStyle(.green)
                                        
                                    }
                                    
                                    Button {
                                        updateTaskItem(item: item, state: .bad, date: date)
                                    } label: {
                                        Text("未完成").foregroundStyle(.red)
                                    }
                                    
                                    Button {
                                        updateTaskItem(item: item, state: .none, date: date)
                                    } label: {
                                        Text("重置").foregroundStyle(.gray)
                                    }
                                }
                        }
                    }
                    Divider()
                }
            }
            Spacer()
        }.padding()
    }
    
    func principleTag(item: PrincipleModel) -> ItemTag? {
        return modelData.tagList.first(where: { $0.id == item.tag })
    }
    
    func principleWeekItemView(item: PrincipleModel, date: Date) -> some View {
        HStack(alignment: .center) {
            if let taskItem = principleTaskItem(item: item, date: date) {
                if taskItem.state == .good {
                    Text("✅").font(.system(size: 12))
                } else if taskItem.state == .bad {
                    Text("❌").font(.system(size: 11))
                } else {
                    Image(systemName: "square").font(.system(size: 16)).bold()
                }
            } else {
                Image(systemName: "square").font(.system(size: 16)).bold()
            }
        }
    }
    
    func principleListView() -> some View {
        List(selection: $selectItemID) {
            let tags = modelData.tagList
            ForEach(tags) { tag in
                let items = principleItems.filter { $0.tag == tag.id }
                if items.count > 0 {
                    Section(header: Text(tag.title)) {
                        ForEach(items, id: \.id) { item in
                            principleItemView(item)
                                .tag(item.id)
                        }
                    }
                }
            }
            
            if ungroupPrincipleItems.count > 0 {
                Section {
                    ForEach(ungroupPrincipleItems, id: \.id) { item in
                        principleItemView(item)
                        .tag(item.id)
                    }
                } header: {
                    Text("未分组")
                }
            }
        }
    }
    
    func principleItemView(_ item: PrincipleModel) -> some View {
        HStack {
            Text(item.content)
            Spacer()
        }
    }
    
    func addNewPrincipleItem() {
        let item = PrincipleModel()
        item.content = "新原则"
        modelData.updatePrincipleItem(item)
    }
    
}
