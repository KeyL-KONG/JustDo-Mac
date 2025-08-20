//
//  ModelData+ReadList.swift
//  Summary
//
//  Created by LQ on 2024/5/4.
//

import Foundation

extension ModelData {
    
    public func loadReadList(completion: @escaping (() -> ())) {
        queryReadTags {
            self.queryReadModels {
                completion()
            }
        }
    }
    
    public func queryReadTags(completion: @escaping (() -> ())) {
        DataManager.shared.query(type: ReadTag.self) { [weak self] tags, error in
            guard let self = self else { return }
            if let tags = tags, tags.count > 0 {
                self.readTagList = tags
                self.tryLoadReadTagTimes = 0
                print("load readlist tag: \(tags.count)")
                completion()
            } else if self.tryLoadReadTagTimes < 3 {
                self.loadReadList(completion: completion)
                self.tryLoadReadTagTimes += 1
            }
            if let error = error {
                print(error)
            }
        }
    }
    
    public func queryReadModels(completion: @escaping (() -> ())) {
        DataManager.shared.query(type: ReadModel.self) { [weak self] items, error in
            if let items = items {
                self?.readList = items
                print("load readlist: \(items.count)")
            } else if let error = error {
                print(error)
            }
            completion()
        }
    }
    
    func deleteReadModel(_ model: ReadModel) {
        guard let index = readList.firstIndex(where: { $0.id == model.id
        }) else {
            return
        }
        readList.remove(at: index)
        DataManager.shared.delete(models: [model]) { error in
            if let error {
                print(error)
            }
        }
    }
    
    func updateReadTag(_ model: ReadTag) {
        if let index = readTagList.firstIndex(where: { $0.id == model.id
        }) {
            readTagList[index] = model
        } else {
            readTagList.append(model)
        }
        
        DataManager.shared.save(with: ReadTag.modelClassName(), models: [model]) { error in
            if let error {
                print(error)
            }
        }
    }
    
    func updateReadModel(_ model: ReadModel, completion: ((Error?) -> Void)? = nil) {
        if let index = readList.firstIndex(where: { $0.id == model.id
        }) {
            readList[index] = model
        } else {
            readList.append(model)
        }
        
        DataManager.shared.save(with: ReadModel.modelClassName(), models: [model]) { error in
            if let error {
                self.updateErrorReadItem = model
                print(error)
            } else {
                self.updateErrorReadItem = nil
            }
            completion?(error)
        }
    }

}
