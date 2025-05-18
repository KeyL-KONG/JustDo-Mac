//
//  ModelData+PlanItem.swift
//  ToDo
//
//  Created by LQ on 2025/5/17.
//

import Foundation

extension ModelData {
    
    public func loadPlanTimeItems(_ completion: (() -> ())? = nil) {
        cache.asyncLoadCache(type: .planItem) { items in
            if let items = items as? [PlanTimeItem], self.planTimeItems.isEmpty {
                self.planTimeItems = items
                print("load plans from cache: \(items.count)")
            }
            if !self.planTimeItems.isEmpty {
                completion?()
            }
        }
        DataManager.shared.query(type: PlanTimeItem.self) { [weak self] itemList, error in
            let callCompletion = self?.planTimeItems.isEmpty ?? false
            if let itemList = itemList, itemList.count > 0 {
                self?.planTimeItems = itemList
                self?.cache.asyncStoreCache(type: .planItem, items: itemList)
                print("load plan items from server: \(itemList.count)")
            }
            if callCompletion {
                completion?()
            }
        }
    }
    
    public func updatePlanTimeItem(_ item: PlanTimeItem, completion: (() -> ())? = nil) {
        if let index = planTimeItems.firstIndex(where: { $0.id == item.id }) {
            planTimeItems[index] = item
        } else {
            planTimeItems.append(item)
        }
        
        DataManager.shared.save(with: PlanTimeItem.modelClassName(), models: [item]) { error in
            if let error = error {
                print(error)
            }
            completion?()
        }
    }
    
    public func deletePlanTimeItem(_ item: PlanTimeItem) {
        guard let index = planTimeItems.firstIndex(where: { $0.id == item.id }) else { return }
        planTimeItems.remove(at: index)
        DataManager.shared.delete(models: [item]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
}
