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
    @State var toggleToRefresh: Bool = false
    static var selectedItem: EventItem? = nil
    
    @State var showFixedEventOnly: Bool = true
    @State var showUnArchiOny: Bool = true
    @State var showUnFinish: Bool = true
    @State var expandedItems: Set<String> = []
    
    var tagList: [ItemTag] {
        modelData.tagList
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("项目统计").font(.title.bold()).foregroundStyle(.blue)
                
                Spacer()
                
                Menu {
                    Toggle(isOn: $showFixedEventOnly) {
                        Text("仅展示固定项目")
                    }
                    Toggle(isOn: $showUnArchiOny) {
                        Text("仅展示未归档项目")
                    }
                    Toggle(isOn: $showUnFinish) {
                        Text("仅展示未完成事项")
                    }
                } label: {
                    Label("", systemImage: "ellipsis.circle").foregroundStyle(.blue).font(.title2)
                }
            }.padding(.leading, 15)
            
            if toggleToRefresh {
                Text("")
            }
            
            if showFixedEventOnly {
                fixedProjectListView()
            } else {
                projectListView()
            }
            
        }
        .sheet(isPresented: $showingSheet) {
            if let selectedItem = Self.selectedItem {
                EditTaskView(showSheetView: $showingSheet, selectedItem: selectedItem, setPlanTime: true, setReward: false, setDeadlineTime: false)
                    .environmentObject(modelData)
            } else {
                EditTaskView(showSheetView: $showingSheet, fatherItem: nil, setPlanTime: true, setReward: false, setDeadlineTime: false, initProjectType: true)
                   .environmentObject(modelData)
            }
        }
        .onChange(of: modelData.updateItemIndex, { oldValue, newValue in
            updateProjectData()
        })
        .onChange(of: showFixedEventOnly, { oldValue, newValue in
            updateProjectData()
        })
        .onAppear {
            updateProjectData()
        }
    }
}

extension iOSProjectView {
    
    func updateProjectData() {
        if showFixedEventOnly {
            updateFixedProjects()
        }
    }
    
    
    
}



#endif
