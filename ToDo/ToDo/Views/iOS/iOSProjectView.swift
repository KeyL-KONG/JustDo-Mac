//
//  iOSProjectView.swift
//  ToDo
//
//  Created by LQ on 2025/6/29.
//

import SwiftUI
#if os(iOS)
struct iOSProjectView: View {
    
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var timerModel: TimerModel
    
    @State var fixedProjects: [EventItem] = []
    @State var selectDate: Date = .now
    @State var showingSheet: Bool = false
    static var selectedItem: EventItem? = nil
    
    var tagList: [ItemTag] {
        modelData.tagList
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("项目统计").font(.title.bold()).foregroundStyle(.blue)
                
                Spacer()
                
                Menu {
                    
                } label: {
                    Label("", systemImage: "ellipsis.circle").foregroundStyle(.blue).font(.title2)
                }
            }.padding(.leading, 15)
            
            List {
                ForEach(tagList, id: \.self.id) { tag in
                    let items = fixedProjects.filter { $0.tag == tag.id }
                    if items.count > 0 {
                        let strideItems = stride(from: 0, to: items.count, by: 2).map { index in
                            Array(items[index..<min(index+2, items.count)])
                        }
                        
                        Section {
                            ForEach(strideItems, id: \.self) { rowItems in
                                HStack {
                                    if let first = rowItems.first {
                                        Spacer()
                                        quickItemView(item: first)
                                        Spacer()
                                    }
                                    if let last = rowItems.last, rowItems.count > 1 {
                                        quickItemView(item: last)
                                        Spacer()
                                    } else {
                                        Text("").frame(width: 160, height: 120)
                                        
                                        Spacer()
                                    }
                                }
                                .listRowSeparator(.hidden)
                            }
                            
                        } header: {
                            HStack {
                                Text(tag.title)
                                Spacer()
                            }
                        }

                    }
                }
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $showingSheet) {
            if let selectedItem = Self.selectedItem {
                EditTaskView(showSheetView: $showingSheet, selectedItem: selectedItem, setPlanTime: true, setReward: false)
                    .environmentObject(modelData)
            } else {
                EditTaskView(showSheetView: $showingSheet, fatherItem: nil, setPlanTime: true, setReward: false, initProjectType: true)
                   .environmentObject(modelData)
            }
        }
        .onChange(of: modelData.updateItemIndex, { oldValue, newValue in
            updateFixedProjects()
        })
        .onAppear {
            updateFixedProjects()
        }
    }
}

extension iOSProjectView {
    
    func quickItemView(item: EventItem) -> some View {
        let tag: ItemTag? = modelData.tagList.first { $0.id == item.tag }
        let tagColor = tag?.titleColor ?? .cyan
        let taskTimeItems = modelData.taskTimeItems.filter { !$0.isPlan }
        let totalTime = item.itemTotalTime(with: modelData.itemList, taskItems: taskTimeItems, taskId: item.id, date: .now)
        
        return VStack(alignment: .leading) {
            HStack {
                Text(item.title).bold().font(.system(size: 14))
                .onTapGesture {
                    Self.selectedItem = item
                    showingSheet.toggle()
                }
                Spacer()
            }
            .padding()
            .offset(y: (totalTime > 0 ? 10 : 0))
            if totalTime > 0 {
                HStack {
                    Text(totalTime.simpleTimeStr).foregroundStyle(.white).font(.system(size: 13)).bold()
                    Spacer()
                }.padding(.horizontal)
                    
            }
            Spacer()
            HStack {
                if let tag {
                    tagView(with: tag.title, color: tagColor)
                }
                Spacer()
                
                Image(systemName: "play.fill").foregroundStyle(.white)
                    .onTapGesture {
                        timerModel.startTimer(item: item)
                    }
            }
            .padding()
        }
        .containerShape(Rectangle())
        .frame(width: 160, height: 120)
        .background(content: {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(tagColor.opacity(0.6))
                    .cornerRadius(10)
                    .frame(width: 160, height: 120)
            }
        })
    }
    
    func tagView(with title: String, color: Color) -> some View {
        return Button(action: { }) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(color)
        }.buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(.white)
    }
    
}

extension iOSProjectView {
    
    func updateFixedProjects() {
        let weekDayIndex: Int = self.selectDate.weekDay
        self.fixedProjects = modelData.itemList.filter { event in
            guard event.isFixedEvent else { return false }
            if event.fixedWeekDays.count >= 7 {
                return event.fixedWeekDays[weekDayIndex] != 0
            }
            return false
        }
    }
    
}

#endif
