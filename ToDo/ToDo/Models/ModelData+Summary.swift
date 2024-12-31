//
//  ModelData+Summary.swift
//  Summary
//
//  Created by LQ on 2024/5/5.
//

import Foundation

extension ModelData {
    
    func loadSummaryList(completion: @escaping (() -> ())) {
        querySummaryTags {
            self.querySummaryItemList {
                self.querySummaryModel {
                    completion()
                }
            }
        }
        
//        queryProgressItems {
//            
//        }
    }
    
    public func querySummaryItemList(completion: @escaping (() -> ())) {
        DataManager.shared.query(type: SummaryItem.self) { [weak self] items, error in
            guard let self = self else { return }
            if let items = items, items.count > 0 {
                self.summaryItemList = items
                print("load summary item list: \(items.count)")
                self.tryLoadSummaryTimes = 0
                completion()
            } else if self.tryLoadSummaryTimes < 3 {
                self.loadSummaryList(completion: completion)
                self.tryLoadSummaryTimes += 1
            }
            if let error = error {
                print(error)
            }
        }
    }
    
    public func querySummaryModel(completion: @escaping (() -> ())) {
        DataManager.shared.query(type: SummaryModel.self) { [weak self] items, error in
            guard let self = self else { return }
            if let items = items {
                self.summaryModelList = items
            }
        }
    }
    
}

//extension ModelData {
//    
//    func queryProgressItems(completion: @escaping (() -> ())) {
//        DataManager.shared.query(type: ProgressItem.self) { items, error in
//            if let items {
//                self.progressItemList = items
//            }
//            if let error {
//                print(error)
//            }
//        }
//    }
//    
//    func updateProgressItem(_ item: ProgressItem) {
//        if let index = progressItemList.firstIndex(where: { $0.id == item.id
//        }) {
//            progressItemList[index] = item
//        } else {
//            progressItemList.append(item)
//        }
//        saveProgressItem(item)
//    }
//    
//    func deleteProgressItem(_ item: ProgressItem) {
//        guard let index = progressItemList.firstIndex(where: { $0.id == item.id
//        }) else {
//           return
//        }
//        progressItemList.remove(at: index)
//        DataManager.shared.delete(models: [item]) { error in
//            if let error {
//                print(error)
//            }
//        }
//    }
//    
//    func saveProgressItem(_ item: ProgressItem) {
//        DataManager.shared.save(with: item.modelClassName(), models: [item]) { error in
//            if let error {
//                print(error)
//            }
//        }
//    }
//    
//}

extension ModelData {
    
    func saveSummaryModel(_ model: SummaryModel) {
        if summaryModelList.contains(where: { $0.id == model.id }) {
            return
        }
        summaryModelList.append(model)
        saveSummaryModelToServer([model])
    }
    
    func updateSummaryModel(_ model: SummaryModel) {
        if let index = summaryModelList.firstIndex(where: {$0.id == model.id })  {
            summaryModelList[index] = model
        } else {
            summaryModelList.append(model)
        }
        saveSummaryModelToServer([model])
    }
    
    func deleteSummaryModel(_ model: SummaryModel) {
        guard let index = summaryModelList.firstIndex(where: {$0.id == model.id }) else {
            return
        }
        summaryModelList.remove(at: index)
        DataManager.shared.delete(models: [model]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    private func saveSummaryModelToServer(_ models: [SummaryModel]) {
        DataManager.shared.save(with: SummaryModel.modelClassName(), models: models) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
}

extension ModelData {
    
    func saveSummaryItem(_ item: SummaryItem) {
        if summaryItemList.contains(where: { $0.id == item.id }) {
            return
        }
        summaryItemList.append(item)
        saveSummaryItemToServer([item])
    }
    
    func updateSummaryItem(_ item: SummaryItem) {
        if let index = summaryItemList.firstIndex(where: {$0.id == item.id })  {
            summaryItemList[index] = item
        } else {
            summaryItemList.append(item)
        }
        saveSummaryItemToServer([item])
    }
    
    func deleteSummaryItem(_ item: SummaryItem) {
        guard let index = summaryItemList.firstIndex(where: {$0.id == item.id }) else {
            return
        }
        summaryItemList.remove(at: index)
        DataManager.shared.delete(models: [item]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    private func saveSummaryItemToServer(_ items: [SummaryItem]) {
        DataManager.shared.save(with: SummaryItem.modelClassName(), models: items) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
}

extension ModelData {
    
    func querySummaryTags(completion: @escaping (() -> ())) {
        DataManager.shared.query(type: SummaryTag.self) { tags, error in
            if let error {
                print(error)
            } else if let tags {
                self.summaryTagList = tags
            }
            completion()
        }
    }
    
    func updateSummaryTag(_ tag: SummaryTag) {
        if let index = summaryTagList.firstIndex(where: { $0.id == tag.id }) {
            summaryTagList[index] = tag
        } else {
            summaryTagList.append(tag)
        }
        DataManager.shared.save(with: tag.modelClassName(), models: [tag]) { error in
            if let error {
                print(error)
            }
        }
    }
    
    func deleteSummaryTag(_ tag: SummaryTag) {
        guard let index = summaryTagList.firstIndex(where: { $0.id == tag.id }) else {
            return
        }
        summaryTagList.remove(at: index)
        DataManager.shared.delete(models: [tag]) { error in
            if let error {
                print(error)
            }
        }
    }
    
}
