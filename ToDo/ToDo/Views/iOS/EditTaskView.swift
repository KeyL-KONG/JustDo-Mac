//
//  EditTaskView.swift
//  JustDo
//
//  Created by ByteDance on 2023/7/9.
//

import SwiftUI

struct EditTaskView: View {
    
    enum FocusedField {
        case title
        case reward
        case mark
        case finish
        case difficult
    }
    
    @EnvironmentObject var modelData: ModelData
    @Binding var showSheetView: Bool
    @State var title: String = ""
    @State var mark: String = ""
    @State var selectedTag: String = ""
    @State var importantTag: ImportanceTag = .mid
    @State var eventType: EventValueType = .time
    @State var rewardType: RewardType = .good
    //@State var rewardValueType: RewardValueType = .num
    @State var rewardValue: String = ""
    @State var planTime = Date.now
    @State var finishTime = Date.now
    @FocusState var focusedField: FocusedField?
    
    @State var importanceList: [ImportanceTag] = [.mid, .low, .high]
    @State var rewardTypeList: [RewardType] = [.good, .bad]
    //@State var rewardValueTypeList: [RewardValueType] = [.num, .time]
    @State var eventTypeList: [EventValueType] = [.num, .time, .count]
    
    @State public var selectedItem: EventItem? = nil
    @State public var fatherItem: EventItem? = nil
    @State public var setPlanTime: Bool
    @State public var setReward: Bool
    @State public var setFixedReward: Bool = false
    @State var isFinish: Bool = false
    @State var defaultSelectDate: Date = .now
    
    @State var finishStateList: [FinishState] = [.normal, .good, .bad]
    @State var finishState: FinishState = .normal
    @State var finishRating: Int = 3
    @State var finishText: String = ""
    
    @State var difficultRating: Int = 3
    @State var difficultText: String = ""
    
    @State var intervals: [LQDateInterval] = []
    
    @State var initProjectType: Bool = false
    @State var actionList: [EventActionType] = [.task, .project, .tag]
    @State var actionType: EventActionType = .task
    @State var selectProject: String = ""
    var projectListTitle: [String] {
        let tagId = modelData.tagList.filter{ $0.title == selectedTag }.first?.id ?? ""
        return ["无"] + modelData.itemList.filter { $0.tag == tagId && $0.actionType == .project}.compactMap { $0.title }
    }
    
    @State var selectFather: String = "无"
    var fatherListTitle: [String] {
        guard selectProject.count > 1, let projectItem = modelData.itemList.first(where: { $0.title == selectProject && $0.actionType == .project }) else { return [] }
        return ["无"] + modelData.itemList.filter { $0.projectId == projectItem.id }.sorted(by: { first, second in
            return first.childrenIds.count > second.childrenIds.count
        }).compactMap { return $0.childrenIds.count > 0 ? "\($0.title) (\($0.childrenIds.count))" : "\($0.title)" }
    }
    
    @State var selectReward: String = ""
    var rewardListTitle: [String] {
        let tagId = modelData.tagList.filter{ $0.title == selectedTag }.first?.id ?? ""
        return ["无"] + modelData.rewardList.filter { $0.tag == tagId }.compactMap { $0.title }
    }
    
    @State var isDetailExpand: Bool = false
    @State var isMarkExpand: Bool = false
    @State var isTimeExpand: Bool = false
    @State var isPlanTimeExpand: Bool = false
    @State var isEditMark: Bool = false
    @State var isArchive: Bool = false
    @State var isQuickEvent: Bool = false
    
    @State var showingTimeIntervalView: Bool = false
    static var selectedTimeIntervalItem: RewardTimeItem? = nil
    
    @State var showingTimeTaskItemView: Bool = false
    static var selectedTaskItem: TaskTimeItem? = nil
    
    @State var toggleToRefresh: Bool = false
    
    var body: some View {
        
        NavigationView {
            
            VStack {
#if os(iOS)
                Text("")
                    .navigationBarTitle(Text("创建任务"), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        self.showSheetView = false
                    }, label: {
                        Text("取消").bold()
                    }), trailing: Button(action: {
                        self.showSheetView = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.saveTask()
                        }
                    }, label: {
                        Text("保存").bold()
                    }))
#endif
                List {
                    
                    if toggleToRefresh {
                        Text("")
                    }
                    
                    contentView()
                    
                    detailView()
                    
                    taskItemViews()
                    
                    taskPlanItemViews()
                    
                    markView()
                    
                }
                .scrollDismissesKeyboard(.interactively)
                
            }
        }.onAppear {
            updateTask()
        }.onDisappear {
//            if let _ = selectedItem {
//                saveTask()
//            }
        }
        .sheet(isPresented: $showingTimeIntervalView) {
            if let item = Self.selectedTimeIntervalItem {
                return EditTaskIntervalView.init(showSheetView: $showingTimeIntervalView, item: item, timeChange: {
                    self.intervals = self.selectedItem?.intervals ?? []
                    self.toggleToRefresh.toggle()
                }).environmentObject(modelData).presentationDetents([.height(250)])
            } else {
                return EditTaskIntervalView.init(showSheetView: $showingTimeIntervalView, startTime: .now, endTime: .now, timeChange: {
                    self.toggleToRefresh.toggle()
                }).environmentObject(modelData).presentationDetents([.height(250)])
            }
        }
        .sheet(isPresented: $showingTimeTaskItemView) {
            if let selectedItem = Self.selectedTaskItem {
                EditTimeLineRowView(showSheetView: $showingTimeTaskItemView, item: selectedItem)
                    .environmentObject(modelData)
                    .presentationDetents([.height(450)])
            }
        }
        
    }
    
    func saveTask() {
        let rewardItem = modelData.rewardList.filter { $0.title == selectReward }.first
        let tag = modelData.tagList.filter({ $0.title == selectedTag}).first?.id ?? ""
        if let selectedItem = selectedItem {
            if let projectItem = modelData.itemList.filter({ $0.title == selectProject}).first {
                selectedItem.projectId = projectItem.id
                if !projectItem.childrenIds.contains(selectedItem.id) {
                    projectItem.childrenIds.append(selectedItem.id)
                }
                modelData.updateItem(projectItem)
            }
            
            let selectFatherTitle = selectFather.replacingOccurrences(of: " \\(\\d+\\)", with: "", options: .regularExpression)
            if let fatherItem = modelData.itemList.filter({ $0.title == selectFatherTitle }).first {
                selectedItem.fatherId = fatherItem.id
                fatherItem.childrenIds.append(selectedItem.id)
                modelData.updateItem(fatherItem)
            }
            
            selectedItem.title = title
            selectedItem.tag = tag
            selectedItem.mark = mark
            selectedItem.setPlanTime = setPlanTime
            if setPlanTime {
                selectedItem.planTime = planTime
            }
            selectedItem.importance = importantTag
            selectedItem.finishState = finishState
            selectedItem.finishText = finishText
            selectedItem.finishRating = finishRating
            selectedItem.difficultRating = difficultRating
            selectedItem.difficultText = difficultText
            selectedItem.intervals = intervals
            selectedItem.rewardType = rewardType
            selectedItem.eventType = eventType
            selectedItem.rewardValue = Int(rewardValue) ?? 0
            selectedItem.fixedReward = setFixedReward
            selectedItem.isFinish = isFinish
            selectedItem.rewardId = rewardItem?.id ?? ""
            selectedItem.actionType = actionType
            selectedItem.finishTime = finishTime
            selectedItem.isArchive = isArchive
            selectedItem.quickEvent = isQuickEvent
            modelData.updateItem(selectedItem)
        } else {
            let item = EventItem.init(id: UUID().uuidString, title: title, mark: mark, tag: tag, isFinish: false, importance: importantTag, finishState: finishState, finishText: finishText, finishRating: finishRating, difficultRating: difficultRating, difficultText: difficultText, createTime: Date.now, rewardType: rewardType, rewardValue: Int(rewardValue) ?? 0, fixedReward: setFixedReward)
            
            if let projectItem = modelData.itemList.filter({ $0.title == selectProject}).first {
                item.projectId = projectItem.id
                if !projectItem.childrenIds.contains(item.generateId) {
                    projectItem.childrenIds.append(item.generateId)
                }
                modelData.updateItem(projectItem)
            }
            
            let selectFatherTitle = selectFather.replacingOccurrences(of: " \\(\\d+\\)", with: "", options: .regularExpression)
            if let fatherItem = modelData.itemList.filter({ $0.title == selectFatherTitle }).first {
                item.fatherId = fatherItem.id
                fatherItem.childrenIds.append(item.generateId)
                modelData.updateItem(fatherItem)
            }
            
            item.eventType = eventType
            item.intervals = intervals
            item.setPlanTime = setPlanTime
            if setPlanTime {
                item.planTime = planTime
            }
            item.isFinish = isFinish
            item.rewardId = rewardItem?.id ?? ""
            item.actionType = actionType
            item.finishTime = finishTime
            item.isArchive = isArchive
            item.quickEvent = isQuickEvent
            modelData.saveItem(item)
        }
    }
    
    
    func updateTask() {
        if let selectedItem = selectedItem {
            title = selectedItem.title
            mark = selectedItem.mark
            isMarkExpand = selectedItem.mark.count > 0
            selectedTag = modelData.tagList.filter({ $0.id == selectedItem.tag}).first?.title ?? ""
            importantTag = selectedItem.importance
            finishState = selectedItem.finishState
            finishText = selectedItem.finishText
            finishRating = selectedItem.finishRating
            difficultRating = selectedItem.difficultRating
            difficultText = selectedItem.difficultText
            intervals = selectedItem.intervals.sorted(by: { $0.start.timeIntervalSince1970 >= $1.start.timeIntervalSince1970
            })
            rewardType = selectedItem.rewardType
            eventType = selectedItem.eventType
            rewardValue = selectedItem.rewardValue > 0 ? String(selectedItem.rewardValue) : ""
            setFixedReward = selectedItem.fixedReward
            setPlanTime = selectedItem.setPlanTime
            if let planTime = selectedItem.planTime {
                self.planTime = planTime
            } else {
                planTime = .now
            }
            isFinish = selectedItem.isFinish
            selectReward = modelData.rewardList.filter({ $0.id == selectedItem.rewardId }).first?.title ?? "无"
            selectProject = modelData.itemList.filter { $0.id == selectedItem.projectId}.first?.title ?? "无"
            if let fatherItem = modelData.itemList.filter({ $0.id == selectedItem.fatherId}).first {
                selectFather = fatherItem.childrenIds.count > 0 ? "\(fatherItem.title) (\(fatherItem.childrenIds.count))" : "\(fatherItem.title)"
            } else {
                selectFather = "无"
            }
            actionType = selectedItem.actionType
            isTimeExpand = selectedItem.intervals.count > 0
            finishTime = selectedItem.finishTime ?? .now
            isArchive = selectedItem.isArchive
            isQuickEvent = selectedItem.quickEvent
        } else {
            selectedTag = modelData.tagList.first?.title ?? ""
            focusedField = .title
            if initProjectType {
                actionType = .project
            }
            if let fatherItem {
                selectedTag = modelData.tagList.first(where: { $0.id == fatherItem.tag
                })?.title ?? ""
                
                if let projectItem = modelData.itemList.first(where: { $0.actionType == .project && $0.id == fatherItem.projectId }) {
                    selectProject = projectItem.title
                }
                selectFather = fatherItem.childrenIds.count > 0 ? "\(fatherItem.title) (\(fatherItem.childrenIds.count))" : "\(fatherItem.title)"
            }
            planTime = defaultSelectDate
        }
        isMarkExpand = !mark.isEmpty
    }
    
}


struct EditTaskView_Previews: PreviewProvider {
    
    static var previews: some View {
        EditTaskView(showSheetView: .constant(true), setPlanTime: true, setReward: false, setFixedReward: false).environmentObject(ModelData())
    }
    
}
