//
//  ModelData+Cache.swift
//  JustDo
//
//  Created by LQ on 2025/5/1.
//

import Foundation
extension ModelData {
    
    
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
        
        group.notify(queue: .main) {
            self.tagList = cacheTags
            self.taskTimeItems = cacheTimeItems
            self.principleItems = cachePrincipleItems
            self.itemList = cacheEventItems
            self.summaryTagList = cacheSummaryTags
            self.summaryItemList = cacheSummaryItems
            self.planTimeItems = cachePlanItems
            let duration = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
            print("load all cache tag: \(cacheTags.count), events: \(cacheEventItems.count), times: \(cacheTimeItems.count), principles: \(cachePrincipleItems.count), summaryItems: \(cacheSummaryItems.count), planItems: \(cachePlanItems.count), duration: \(Int(duration * 1000))ms")
        }
        
    }
    
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
        
        group.enter()
        DataManager.shared.query(type: SummaryItem.self) { tagList, error in
            if let error {
                print("cloud load all summary items error: \(error)")
                isFailRequest = true
            } else {
                serverSummaryItems = tagList ?? []
                print("cloud load all server items: \(serverTags.count)")
            }
            group.leave()
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
                group.leave()
            }
        }
        
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
        
        group.enter()
        DataManager.shared.query(type: PrincipleModel.self) { items, error in
            if let error {
                print("cloud load all server principles error: \(error)")
                isFailRequest = true
            } else {
                serverPrincipleItems = items ?? []
                print("cloud load all server principles: \(serverPrincipleItems.count)")
            }
            group.leave()
        }
        
        group.enter()
        DataManager.shared.query(type: PlanTimeItem.self) { items, error in
            if let error {
                print("cloud load all server plan items error: \(error)")
                isFailRequest = true
            } else {
                serverPlanItems = items ?? []
                print("cloud load all server plan items: \(serverPlanItems.count)")
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoadingServer = false
            if isFailRequest {
                print("cloud load all server fail")
                return
            }
            self.tagList = serverTags
            self.taskTimeItems = serverTimeItems
            self.principleItems = serverPrincipleItems
            self.itemList = serverEventItems
            self.summaryTagList = serverSummaryTags
            self.summaryItemList = serverSummaryItems
            self.planTimeItems = serverPlanItems
            let duration = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
            print("cloud load all server tag: \(serverTags.count), events: \(serverTimeItems.count), times: \(serverTimeItems.count), principles: \(serverPrincipleItems.count), summary: \(serverSummaryItems.count), plan items: \(serverPlanItems.count), duration: \(Int(duration * 1000))ms")
            self.asyncStoreCache(tags: serverTags, times: serverTimeItems, events: serverEventItems, principles: serverPrincipleItems, summaryTags: serverSummaryTags, summaryItems: serverSummaryItems, planItems: serverPlanItems)
        }
    }
    
    func asyncStoreCache(tags: [ItemTag], times: [TaskTimeItem], events: [EventItem], principles: [PrincipleModel], summaryTags: [SummaryTag], summaryItems: [SummaryItem], planItems: [PlanTimeItem]) {
        cache.asyncStoreCache(type: .tag, items: tags)
        cache.asyncStoreCache(type: .timeItem, items: times)
        cache.asyncStoreCache(type: .event, items: events)
        cache.asyncStoreCache(type: .principle, items: principles)
        cache.asyncStoreCache(type: .summaryTag, items: summaryTags)
        cache.asyncStoreCache(type: .summaryItem, items: summaryItems)
        cache.asyncStoreCache(type: .planItem, items: planItems)
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
        default:
            break
        }
    }
    
}
