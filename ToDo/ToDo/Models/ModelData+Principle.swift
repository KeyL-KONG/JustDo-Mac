//
//  ModelData+Principle.swift
//  ToDo
//
//  Created by LQ on 2025/4/13.
//

import Foundation

extension ModelData {
    
    public func loadPrincipleItems(_ completion: (() -> ())? = nil) {
        cache.asyncLoadCache(type: .principle) { items in
            if let items = items as? [PrincipleModel], self.principleItems.isEmpty {
                self.principleItems = items
                print("load principles from cache: \(items.count)")
            }
            if !self.principleItems.isEmpty {
                completion?()
            }
        }
        DataManager.shared.query(type: PrincipleModel.self) { [weak self] itemList, error in
            let callCompletion = self?.principleItems.isEmpty ?? false
            if let itemList = itemList, itemList.count > 0 {
                self?.principleItems = itemList
                self?.cache.asyncStoreCache(type: .principle, items: itemList)
                print("load principles from server: \(itemList.count)")
            }
            if callCompletion {
                completion?()
            }
        }
    }
    
    public func updatePrincipleItem(_ item: PrincipleModel, completion: (() -> ())? = nil) {
        if let index = principleItems.firstIndex(where: { $0.id == item.id }) {
            principleItems[index] = item
        } else {
            principleItems.append(item)
        }
        
        DataManager.shared.save(with: PrincipleModel.modelClassName(), models: [item]) { error in
            if let error = error {
                print(error)
            }
            completion?()
        }
    }
    
    public func deletePrincipleItem(_ item: PrincipleModel) {
        guard let index = principleItems.firstIndex(where: { $0.id == item.id }) else { return }
        itemList.remove(at: index)
        DataManager.shared.delete(models: [item]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
}
