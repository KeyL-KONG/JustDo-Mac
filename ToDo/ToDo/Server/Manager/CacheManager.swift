//
//  CacheManager.swift
//  JustDo
//
//  Created by LQ on 2024/5/2.
//

import Foundation

enum CacheDataType {
    case tag
    case reward
    case event
    case wish
    case timeItem
    case principle
    case summaryTag
    case summaryItem
    case planItem
    case readItem
    case personalTag
    
    var cacheKey: String {
        switch self {
        case .tag:
            return "com.cache.taglist"
        case .reward:
            return "com.cache.reward"
        case .event:
            return "com.cache.event"
        case .wish:
            return "com.cache.wish"
        case .timeItem:
            return "com.cache.timitem"
        case .principle:
            return "com.cache.principle"
        case .summaryTag:
            return "com.cache.summary.tag"
        case .summaryItem:
            return "com.cache.summary.item"
        case .planItem:
            return "com.cache.planitem"
        case .readItem:
            return "com.cache.readitem"
        case .personalTag:
            return "com.cache.personalTag"
        }
    }
    
    var decodeType: Decodable.Type {
        switch self {
        case .tag:
            return ItemTag.self
        case .reward:
            return RewardModel.self
        case .event:
            return EventModel.self
        case .wish:
            return WishModel.self
        case .timeItem:
            return TaskTimeItem.self
        case .principle:
            return PrincipleModel.self
        case .summaryTag:
            return SummaryTag.self
        case .summaryItem:
            return SummaryItem.self
        case .planItem:
            return PlanTimeItem.self
        case .readItem:
            return ReadModel.self
        case .personalTag:
            return PersonalTag.self
        }
    }
}

struct CacheManager {
    
    func asyncLoadCache<T: BaseModel>(type: CacheDataType, completion: @escaping ([T]) -> ()) {
        DispatchQueue.global().async {
            let items: [T] = loadCache(type: type)
            DispatchQueue.main.async {
                completion(items)
            }
        }
    }
    
    func loadCache<T: BaseModel>(type: CacheDataType) -> [T] {
        guard let jsonStrArray = UserDefaults.standard.array(forKey: type.cacheKey) as? [String], jsonStrArray.count > 0 else {
            return []
        }
        var data = [T]()
        jsonStrArray.forEach { jsonString in
            if let jsonData = jsonString.data(using: .utf8)  {
                do {
                    if let item = try JSONDecoder().decode(type.decodeType, from: jsonData) as? T {
                        data.append(item)
                    }
                } catch {
                    print("json to model error: \(error)")
                }
            }
            
        }
        print("load cache items: \(data.count)")
        return data
    }
    
    func storeCache<T: Encodable>(type: CacheDataType, items: [T]) {
        var jsonStringArray = [String]()
        items.forEach { item in
            if let jsonData = try? JSONEncoder().encode(item), let jsonString = String(data: jsonData, encoding: .utf8) {
                jsonStringArray.append(jsonString)
            }
        }
        print("store cache items: \(items.count)")
        UserDefaults.standard.setValue(jsonStringArray, forKey: type.cacheKey)
    }
    
    func asyncStoreCache<T: Encodable>(type: CacheDataType, items: [T], completion: (() -> ())? = nil) {
        DispatchQueue.global().async {
            self.storeCache(type: type, items: items)
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
}
