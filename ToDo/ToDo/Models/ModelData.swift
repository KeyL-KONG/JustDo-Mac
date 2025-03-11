//
//  ModelData.swift
//  JustDo
//
//  Created by ByteDance on 2023/7/8.
//

import SwiftUI

 typealias EventItem = EventModel

final class ModelData: ObservableObject {
    
    @Published var itemList: [EventItem] = []
    @Published var goalList: [GoalModel] = []
    @Published var wishList: [WishModel] = []
    @Published var rewardList: [RewardModel] = []
    @Published var tagList: [ItemTag] = []
    
    @Published var readList: [ReadModel] = []
    @Published var readTagList: [ReadTag] = []
    @Published var noteList: [NoteModel] = []
    @Published var noteTagList: [TagModel] = []
    
    @Published var summaryItemList: [SummaryItem] = []
    @Published var summaryModelList: [SummaryModel] = []
    @Published var summaryTagList: [SummaryTag] = []
    
    @Published var toggleToRefresh: Bool = false
    
    private let cache = CacheManager()
    
    var tryLoadReadTagTimes = 0
    
    var tryLoadNoteTagTimes = 0
    
    var tryLoadSummaryTimes = 0
    
    public func saveItem(_ item: EventItem) {
        if itemList.contains(where: { $0.id == item.id || $0.generateId == item.generateId }) {
            return
        }
        itemList.append(item)
        saveToServer(items: [item])
    }
    
    public func updateItem(_ item: EventItem, completion: (() -> ())? = nil) {
        if let index = itemList.firstIndex(where: { $0.id == item.id || $0.generateId == item.generateId}) {
            itemList[index] = item
        } else {
            itemList.append(item)
        }
        saveToServer(items: [item]) { error in
            completion?()
        }
    }
    
    public func deleteItem(_ item: EventItem) {
        guard let index = itemList.firstIndex(where: { $0.id == item.id }) else { return }
        itemList.remove(at: index)
        DataManager.shared.delete(models: [item]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    public func autoSaveItems() {
        saveToServer(items: itemList)
    }
    
    public func saveDisplayMode(_ displayMode: DisplayMode) {
        UserDefaults.standard.set(displayMode.rawValue, forKey: Keys.displayMode)
    }
    
    public func displayMode() -> DisplayMode {
        let mode = UserDefaults.standard.integer(forKey: Keys.displayMode)
        return DisplayMode(rawValue: mode) ?? .time
    }
    
    func saveToServer(items: [EventItem], completion: ((Error?) -> ())? = nil) {
        print("save item: \(items.first?.title ?? "")")
        DataManager.shared.save(with: EventItem.modelClassName(), models: items) { error in
            if let error = error {
                print(error)
            }
            completion?(error)
        }
    }
    
    func loadFromServer() {
        loadTag {
            self.loadMainData {
                self.loadSummaryList {
                    self.loadReadList {
                        self.loadNoteList {
                            
                        }
                    }
                }
            }
        }
    }
    
    func loadMainData(completion: (() -> ())? = nil) {
        loadReward {
            self.loadEvent {
                completion?()
            }
        }
    }
    
    func loadTag(_ completion: (() -> ())? = nil) {
        cache.asyncLoadCache(type: .tag) { items in
            if let tags = items as? [ItemTag], self.tagList.isEmpty {
                self.tagList = tags
                print("load tags from cache: \(tags.count)")
            }
            if !self.tagList.isEmpty {
                completion?()
            }
        }
        DataManager.shared.query(type: ItemTag.self) { [weak self] tagList, error in
            let callCompletion = self?.tagList.isEmpty ?? false
            if let tagList = tagList, tagList.count > 0 {
                self?.tagList = tagList
                self?.cache.asyncStoreCache(type: .tag, items: tagList)
                print("load tags from server: \(tagList.count)")
            }
            if callCompletion {
                completion?()
            }
        }
    }
    
    func loadEvent(_ completion: (() -> ())? = nil) {
        cache.asyncLoadCache(type: .event) { items in
            if let events = items as? [EventModel], self.itemList.isEmpty {
                self.itemList = events
                print("load events from cache: \(items.count)")
                completion?()
            }
        }
        DataManager.shared.query(type: EventModel.self) { [weak self] items, error in
            let callCompletion = self?.itemList.isEmpty ?? false
            if let items = items, items.count > 0 {
                self?.itemList = items.reduce([], { partialResult, model in
                    return partialResult.contains { $0.id == model.id || $0.generateId == model.generateId } ? partialResult : partialResult + [model]
                })
                self?.cache.asyncStoreCache(type: .event, items: self?.itemList ?? [])
            }
            if callCompletion {
                completion?()
            }
        }
    }
    
    func loadReward(_ completion: (() -> ())? = nil) {
        cache.asyncLoadCache(type: .reward) { items in
            if let rewards = items as? [RewardModel], rewards.count > 0, self.rewardList.isEmpty {
                self.rewardList = rewards
                print("load reward from cache: \(rewards.count)")
            }
            if !self.rewardList.isEmpty {
                completion?()
            }
        }
        DataManager.shared.query(type: RewardModel.self) { [weak self] rewards, error in
            let callCompletion = self?.rewardList.isEmpty ?? false
            if let rewards = rewards, rewards.count > 0 {
                self?.rewardList = rewards
                self?.cache.asyncStoreCache(type: .reward, items: rewards)
                print("load rewardlist from server: \(rewards.count)")
            }
            if callCompletion {
                completion?()
            }
        }
    }
    
    func loadWish(_ completion: (() -> ())? = nil) {
        cache.asyncLoadCache(type: .wish) { items in
            if let wishs = items as? [WishModel], wishs.count > 0 {
                self.wishList = wishs
                print("load wish from cache: \(wishs.count)")
                completion?()
            }
        }
        DataManager.shared.query(type: WishModel.self) { [weak self] items, error in
            let callCompletion = self?.wishList.isEmpty ?? false
            if let items = items, items.count > 0 {
                self?.wishList = items
                self?.cache.asyncStoreCache(type: .wish, items: items)
            }
            if callCompletion {
                completion?()
            }
        }
    }
    
}

// MARK: Tag
extension ModelData {
    
    public func saveTag(_ tag: ItemTag) {
        if tagList.contains(where: { $0.id == tag.id }) {
            return
        }
        tagList.append(tag)
        saveTagToServer([tag])
    }
    
    public func updateTag(_ tag: ItemTag) {
        guard let index = tagList.firstIndex(where: { $0.id == tag.id }) else {
            return
        }
        tagList[index] = tag
        saveTagToServer([tag])
    }
    
    public func deleteTag(_ tag: ItemTag) {
        guard let index = tagList.firstIndex(where: { $0.id == tag.id }) else {
            return
        }
        tagList.remove(at: index)
        DataManager.shared.delete(models: [tag]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func saveTagToServer(_ tagList: [ItemTag]) {
        DataManager.shared.save(with: ItemTag.modelClassName(), models: tagList) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
}

// MARK: Goal
extension ModelData {
    
    public func saveGoalModel(_ model: GoalModel) {
        if goalList.contains(where: { $0.id == model.id }) {
            return
        }
        goalList.append(model)
        saveGoalToServer(goalList)
    }
    
    public func updateGoalModel(_ model: GoalModel) {
        if let index = goalList.firstIndex(where: { $0.id == model.id }) {
            goalList[index] = model
        }
        saveGoalToServer(goalList)
    }
    
    public func deleteGoalModel(_ model: GoalModel) {
        guard let index = goalList.firstIndex(where: { $0.id == model.id }) else {
            return
        }
        goalList.remove(at: index)
        DataManager.shared.delete(models: [model]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func saveGoalToServer(_ goalList: [GoalModel]) {
        DataManager.shared.save(with: GoalModel.modelClassName(), models: goalList) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
}

// MARK: Wish
extension ModelData {
    
    func saveWishModel(_ model: WishModel) {
        if wishList.contains(where: { $0.id == model.id }) {
            return
        }
        wishList.append(model)
        saveWishToServer([model])
    }
    
    func updateWishModel(_ model: WishModel) {
        if let index = wishList.firstIndex(where: { $0.id == model.id }) {
            wishList[index] = model
        }
        saveWishToServer([model])
    }
    
    func deleteWishModel(_ model: WishModel) {
        guard let index = wishList.firstIndex(where: { $0.id == model.id }) else {
            return
        }
        wishList.remove(at: index)
        DataManager.shared.delete(models: [model]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func saveWishToServer(_ wishList: [WishModel]) {
        DataManager.shared.save(with: WishModel.modelClassName(), models: wishList) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
}

// MARK: Reward
extension ModelData {
    
    func saveRewardModel(_ model: RewardModel) {
        if rewardList.contains(where: { $0.id == model.id
        }) {
            return
        }
        rewardList.append(model)
        saveRewardToServer([model])
    }
    
    func updateRewardModel(_ model: RewardModel) {
        if let index = rewardList.firstIndex(where: { $0.id == model.id }) {
            rewardList[index] = model
        }
        saveRewardToServer([model])
    }
    
    func deleteRewardModel(_ model: RewardModel) {
        guard let index = rewardList.firstIndex(where: { $0.id == model.id }) else {
            return
        }
        rewardList.remove(at: index)
        DataManager.shared.delete(models: [model]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func saveRewardToServer(_ rewardList: [RewardModel]) {
        DataManager.shared.save(with: RewardModel.modelClassName(), models: rewardList) { error in
            if let error = error {
                print(error)
            }
        }
    }
}

// MARK: covert
extension ModelData {
    
    func covertEventToReward() {
        
        DispatchQueue.global().async {
            let eventList = self.itemList.filter { $0.fixedReward }
            var rewardList = [RewardModel]()
            eventList.forEach { event in
                let reward = RewardModel(id: event.id, title: event.title, mark: event.mark, tag: event.tag, eventType: event.eventType, isFinish: event.isFinish, rewardType: event.rewardType, rewardValueType: event.rewardValueType, rewardValue: event.rewardValue, rewardCount: event.rewardCount, intervals: event.intervals)
                rewardList.append(reward)
                DispatchQueue.main.asyncAfter(deadline: .now() + (0.5 * Double(rewardList.count))) {
                    self.saveRewardToServer([reward])
                    print("save reward list: \(rewardList.count)")
                }
            }
        }
    }
    
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}


func loadItems() -> [EventItem] {
    var items = [EventItem]()
    if let jsonArray = UserDefaults.standard.array(forKey: Keys.items) as? [[String: Any]]  {
        for dict in jsonArray {
            let id = dict["id"] as? String ?? ""
            let title = dict["title"] as? String ?? ""
            let mark = dict["mark"] as? String ?? ""
            let tag = dict["tag"] as? String ?? ""
            let isFinish = dict["isFinish"] as? Bool ?? false
            let importance = ImportanceTag(rawValue: dict["importance"] as? String ?? "") ?? .mid
            var createTime: Date?
            if let createTimeIntervalStr = dict["createTime"] as? String, let createTimeInterval = Double(createTimeIntervalStr) {
                createTime = Date(timeIntervalSince1970: createTimeInterval)
            }
            var planTime: Date?
            if let planTimeIntervalStr = dict["planTime"] as? String, let planTimeInterval = Double(planTimeIntervalStr) {
                planTime = Date(timeIntervalSince1970: planTimeInterval)
            }
            var finishTime: Date?
            if let finishTimeIntervalStr = dict["finishTime"] as? String, let finishTimeInterval = Double(finishTimeIntervalStr) {
                finishTime = Date(timeIntervalSince1970: finishTimeInterval)
            }
            let item = EventItem(id: id, title: title, mark: mark, tag: tag, isFinish: isFinish, importance: importance, createTime: createTime, planTime: planTime, finishTime: finishTime)
            items.append(item)
        }
    }
    return items
}

private struct Keys {
    public static let items = "items"
    public static let displayMode = "displayMode"
}

func saveItems(_ items: [EventItem]) {
    guard items.count > 0 else { return }
    var jsonArray: [[String: Any]] = []
    for item in items {
        var dict = [String: Any]()
        dict["id"] = item.id
        dict["title"] = item.title
        dict["mark"] = item.mark
        dict["tag"] = item.tag
        dict["isFinish"] = item.isFinish
        dict["importance"] = item.importance.rawValue
        if let createTime = item.createTime {
            dict["createTime"] = createTime.timeIntervalSince1970.stringValue
        }
        if let planTime = item.planTime {
            dict["planTime"] = planTime.timeIntervalSince1970.stringValue
        }
        if let finishTime = item.finishTime {
            dict["finishTime"] = finishTime.timeIntervalSince1970.stringValue
        }
        jsonArray.append(dict)
    }
    UserDefaults.standard.set(jsonArray, forKey: Keys.items)
}
