//
//  ModelData+Cache.swift
//  JustDo
//
//  Created by LQ on 2025/5/1.
//

import Foundation
extension ModelData {
    
    
    // 在 asyncLoadCacheData 方法中添加
    func asyncLoadCacheData() {
        let startTime = Date()
        let group = DispatchGroup()
        var cacheTags: [ItemTag] = []
        var cacheTimeItems: [TaskTimeItem] = []
        var cacheEventItems: [EventItem] = []
        var cachePrincipleItems: [PrincipleModel] = []
        var cacheSummaryTags: [SummaryTag] = []
        var cacheSummaryItems: [SummaryItem] = []
        var cachePlanItems: [PlanTimeItem] = []
        var cacheReadTags: [ReadTag] = []
        var cacheReadItems: [ReadModel] = []
        var cachePersonalTags: [PersonalTag] = [] // 新增
        var cacheRecordItems: [RecordItem] = []
        
        group.enter()
        cache.asyncLoadCache(type: .tag) { tags in
            cacheTags = tags as? [ItemTag] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .timeItem) { items in
            cacheTimeItems = items as? [TaskTimeItem] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .event) { items in
            cacheEventItems = items as? [EventItem] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .principle) { items in
            cachePrincipleItems = items as? [PrincipleModel] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .summaryTag) { tags in
            cacheSummaryTags = tags as? [SummaryTag] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .summaryItem) { items in
            cacheSummaryItems = items as? [SummaryItem] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .planItem) { items in
            cachePlanItems = items as? [PlanTimeItem] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .readItem) { items in
            cacheReadItems = items as? [ReadModel] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .readTag) { items in
            cacheReadTags = items as? [ReadTag] ?? []
            group.leave()
        }
        
        // 新增 PersonalTag 缓存加载
        group.enter()
        cache.asyncLoadCache(type: .personalTag) { tags in
            cachePersonalTags = tags as? [PersonalTag] ?? []
            group.leave()
        }
        
        var cacheNoteItems: [NoteModel] = []
        var cacheNoteTags: [TagModel] = []
        var cacheNoteItemList: [NoteItem] = []
    
        // 添加缓存加载
        group.enter()
        cache.asyncLoadCache(type: .note) { items in
            cacheNoteItems = items as? [NoteModel] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .noteTag) { tags in
            cacheNoteTags = tags as? [TagModel] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .noteItem) { items in
            cacheNoteItemList = items as? [NoteItem] ?? []
            group.leave()
        }
        
        group.enter()
        cache.asyncLoadCache(type: .record) { items in
            cacheRecordItems = items as? [RecordItem] ?? []
            group.leave()
        }
    
        group.notify(queue: .main) {
            self.tagList = cacheTags
            self.taskTimeItems = cacheTimeItems
            self.principleItems = cachePrincipleItems
            self.itemList = cacheEventItems
            self.summaryTagList = cacheSummaryTags
            self.summaryItemList = cacheSummaryItems
            self.planTimeItems = cachePlanItems
            self.readList = cacheReadItems
            self.personalTagList = cachePersonalTags
            self.noteList = cacheNoteItems
            self.noteTagList = cacheNoteTags
            self.noteItemList = cacheNoteItemList
            self.readTagList = cacheReadTags
            self.recordList = cacheRecordItems
            let duration = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
            print("load all cache tag: \(cacheTags.count), events: \(cacheEventItems.count), times: \(cacheTimeItems.count), principles: \(cachePrincipleItems.count), summaryItems: \(cacheSummaryItems.count), planItems: \(cachePlanItems.count), notes: \(cacheNoteItems.count), noteitems: \(cacheNoteItemList.count), readItems: \(cacheReadItems.count) duration: \(Int(duration * 1000))ms")
            self.updateDataIndex += 1
        }
        
    }
    
    // 在 asyncLoadServer 方法中添加
    func asyncLoadServer() {
        if self.isLoadingServer {
            print("cloud load all return")
            return
        }
        self.isLoadingServer = true
        let startTime = Date()
        let group = DispatchGroup()
        var serverTags: [ItemTag] = []
        var serverTimeItems: [TaskTimeItem] = []
        var serverEventItems: [EventItem] = []
        var serverPrincipleItems: [PrincipleModel] = []
        var serverSummaryTags: [SummaryTag] = []
        var serverSummaryItems: [SummaryItem] = []
        var serverPlanItems: [PlanTimeItem] = []
        var serverReadItems: [ReadModel] = []
        var serverPersonalTags: [PersonalTag] = []
        var serverNoteItems: [NoteModel] = []
        var serverNoteTags: [TagModel] = []
        var serverNoteItemList: [NoteItem] = []
        var serverReadTags: [ReadTag] = []
        var serverRecordItems: [RecordItem] = []
        var isFailRequest = false
        
        group.enter()
        DataManager.shared.query(type: ItemTag.self) { tagList, error in
            if let error {
                print("cloud load all server tags error: \(error)")
                isFailRequest = true
            } else {
                serverTags = tagList ?? []
                print("cloud load all server tags: \(serverTags.count)")
            }
            group.leave()
        }
        
        group.enter()
        DataManager.shared.query(type: SummaryTag.self) { tagList, error in
            if let error {
                print("cloud load all summary tags error: \(error)")
                isFailRequest = true
            } else {
                serverSummaryTags = tagList ?? []
                print("cloud load all server tags: \(serverSummaryTags.count)")
            }
            group.leave()
        }
        
        
        func loadSummaryItems() {
            group.enter()
            DataManager.shared.query(type: SummaryItem.self) { tagList, error in
                if let error {
                    print("cloud load all summary items error: \(error)")
                    isFailRequest = true
                } else {
                    serverSummaryItems = tagList ?? []
                    print("cloud load all server items: \(serverTags.count)")
                }
                loadReadItems()
                group.leave()
            }
        }
        
        func loadEventItems() {
            group.enter()
            DataManager.shared.query(type: EventItem.self) { items, error in
                if let error {
                    print("cloud load all server events error: \(error)")
                    isFailRequest = true
                } else {
                    serverEventItems = items ?? []
                    print("cloud load all server events: \(serverEventItems.count)")
                }
                loadSummaryItems()
                group.leave()
            }
        }
        
        func loadTaskItems() {
            group.enter()
            DataManager.shared.query(type: TaskTimeItem.self) { items, error in
                if let error {
                    print("cloud load all server times error: \(error)")
                    isFailRequest = true
                } else {
                    serverTimeItems = items ?? []
                    print("cloud load all server times: \(serverTimeItems.count)")
                }
                loadEventItems()
                
                group.leave()
            }
        }
        
        group.enter()
        DataManager.shared.query(type: PersonalTag.self) { tagList, error in
            if let error {
                print("cloud load all personal tags error: \(error)")
                isFailRequest = true
            } else {
                serverPersonalTags = tagList ?? []
                print("cloud load all personal tags: \(serverPersonalTags.count)")
            }
            loadTaskItems()
            group.leave()
        }
        
        loadRecordItems()
        
//        group.enter()
//        DataManager.shared.query(type: PrincipleModel.self) { items, error in
//            if let error {
//                print("cloud load all server principles error: \(error)")
//                isFailRequest = true
//            } else {
//                serverPrincipleItems = items ?? []
//                print("cloud load all server principles: \(serverPrincipleItems.count)")
//            }
//            group.leave()
//        }
//        
//        group.enter()
//        DataManager.shared.query(type: PlanTimeItem.self) { items, error in
//            if let error {
//                print("cloud load all server plan items error: \(error)")
//                isFailRequest = true
//            } else {
//                serverPlanItems = items ?? []
//                print("cloud load all server plan items: \(serverPlanItems.count)")
//            }
//            group.leave()
//        }
        
        func loadNoteItemList() {
            group.enter()
            DataManager.shared.query(type: NoteItem.self) { items, error in
                if let error {
                    print("cloud load all server note items error: \(error)")
                    isFailRequest = true
                } else {
                    serverNoteItemList = items ?? []
                    print("cloud load all server note itemlist: \(serverNoteItemList.count)")
                }
                group.leave()
            }
        }
        
        func loadNoteItems() {
            group.enter()
            DataManager.shared.query(type: NoteModel.self) { items, error in
                if let error {
                    print("cloud load all server note items error: \(error)")
                    isFailRequest = true
                } else {
                    serverNoteItems = items ?? []
                    loadNoteItemList()
                    print("cloud load all server note items: \(serverNoteItems.count)")
                }
                group.leave()
            }
        }
        
        func loadNoteTagss() {
            group.enter()
            DataManager.shared.query(type: TagModel.self) { items, error in
                if let error {
                    print("cloud load all server note tags error: \(error)")
                    isFailRequest = true
                } else {
                    serverNoteTags = items ?? []
                    print("cloud load all server note tags: \(serverNoteTags.count)")
                }
                loadNoteItems()
                group.leave()
            }
        }
        
        func loadReadTags() {
            group.enter()
            DataManager.shared.query(type: ReadTag.self) { items, error in
                if let error {
                    print("cloud load all server read items error: \(error)")
                    isFailRequest = true
                } else {
                    serverReadTags = items ?? []
                    print("cloud load all server read items: \(serverReadTags.count)")
                }
                loadNoteTagss()
                group.leave()
            }
        }
        
        func loadReadItems() {
            group.enter()
            DataManager.shared.query(type: ReadModel.self) { items, error in
                if let error {
                    print("cloud load all server read items error: \(error)")
                    isFailRequest = true
                } else {
                    serverReadItems = items ?? []
                    print("cloud load all server read items: \(serverReadItems.count)")
                }
                loadReadTags()
                group.leave()
            }
        }
        
        func loadRecordItems() {
            group.enter()
            DataManager.shared.query(type: RecordItem.self) { items, error in
                if let error {
                    print("cloud load all server read items error: \(error)")
                    isFailRequest = true
                } else {
                    serverRecordItems = items ?? []
                    print("cloud load all server record items: \(serverRecordItems.count)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isLoadingServer = false
            if isFailRequest {
                print("cloud load all server fail")
                if self.retryLoadServerTimes == 0 {
                    self.retryLoadServerTimes += 1
                    self.asyncLoadServer()
                }
                return
            }
            self.tagList = serverTags
            self.taskTimeItems = serverTimeItems
            self.principleItems = serverPrincipleItems
            self.itemList = serverEventItems
            self.summaryTagList = serverSummaryTags
            self.summaryItemList = serverSummaryItems
            self.planTimeItems = serverPlanItems
            self.readList = serverReadItems
            self.personalTagList = serverPersonalTags
            self.noteList = serverNoteItems
            self.noteTagList = serverNoteTags
            self.noteItemList = serverNoteItemList
            self.readTagList = serverReadTags
            self.updateDataIndex += 1
            let duration = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
            print("cloud load all server tag: \(serverTags.count), events: \(serverTimeItems.count), times: \(serverTimeItems.count), principles: \(serverPrincipleItems.count), summary: \(serverSummaryItems.count), plan items: \(serverPlanItems.count), noteTags:\(serverNoteTags.count), noteItems: \(serverNoteItems.count), notesubitems: \(serverNoteItemList.count), duration: \(Int(duration * 1000))ms")
            self.asyncStoreCache(tags: serverTags, times: serverTimeItems, events: serverEventItems, principles: serverPrincipleItems, summaryTags: serverSummaryTags, summaryItems: serverSummaryItems, planItems: serverPlanItems, readItems: serverReadItems, personalTags: serverPersonalTags, noteTags: serverNoteTags, noteItems: serverNoteItems, noteItemList: serverNoteItemList, readTags: serverReadTags, recordItems: serverRecordItems) // 新增参数
        }
    }
    
    // 更新 asyncStoreCache 方法
    func asyncStoreCache(tags: [ItemTag], times: [TaskTimeItem], 
                   events: [EventItem], principles: [PrincipleModel],
                   summaryTags: [SummaryTag], summaryItems: [SummaryItem],
                   planItems: [PlanTimeItem], readItems: [ReadModel],
                         personalTags: [PersonalTag], noteTags: [TagModel], noteItems: [NoteModel], noteItemList: [NoteItem], readTags: [ReadTag], recordItems: [RecordItem]) { // 新增参数
    
        cache.asyncStoreCache(type: .tag, items: tags)
        cache.asyncStoreCache(type: .timeItem, items: times)
        cache.asyncStoreCache(type: .event, items: events)
        cache.asyncStoreCache(type: .principle, items: principles)
        cache.asyncStoreCache(type: .summaryTag, items: summaryTags)
        cache.asyncStoreCache(type: .summaryItem, items: summaryItems)
        cache.asyncStoreCache(type: .planItem, items: planItems)
        cache.asyncStoreCache(type: .personalTag, items: personalTags) // 新增
        cache.asyncStoreCache(type: .note, items: noteItems)
        cache.asyncStoreCache(type: .noteTag, items: noteTags)
        cache.asyncStoreCache(type: .noteItem, items: noteItemList)
        cache.asyncStoreCache(type: .readItem, items: readItems)
        cache.asyncStoreCache(type: .readTag, items: readTags)
        cache.asyncStoreCache(type: .record, items: recordItems)
    }
    
    func asyncUpdateCache(type: CacheDataType) {
        switch type {
        case .tag:
            cache.asyncStoreCache(type: .tag, items: self.tagList)
        case .event:
            cache.asyncStoreCache(type: .event, items: self.itemList)
        case .principle:
            cache.asyncStoreCache(type: .principle, items: self.principleItems)
        case .timeItem:
            cache.asyncStoreCache(type: .timeItem, items: self.taskTimeItems)
        case .planItem:
            cache.storeCache(type: .planItem, items: self.planTimeItems)
        case .summaryItem:
            cache.storeCache(type: .summaryItem, items: summaryItemList)
        case .personalTag:
            cache.storeCache(type: .personalTag, items: self.personalTagList)
        case .note:
            cache.storeCache(type: .note, items: self.noteList)
        case .noteTag:
            cache.storeCache(type: .noteTag, items: self.noteTagList)
        case .noteItem:
            cache.storeCache(type: .noteItem, items: self.noteItemList)
        case .readItem:
            cache.storeCache(type: .readItem, items: self.readList)
        case .readTag:
            cache.storeCache(type: .readTag, items: self.readTagList)
        case .record:
            cache.storeCache(type: .record, items: self.recordList)
        default:
            break
        }
    }
    
}
