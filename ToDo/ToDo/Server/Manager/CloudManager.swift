//
//  CloudManager.swift
//  Money
//
//  Created by LQ on 2022/1/16.
//

import Foundation
import LeanCloud

class CloudManager {
    
    static let shared = CloudManager.init()
    
    init() {
        
    }
    
    // MARK: File
    func upload(with data:Data, completion:@escaping((String?, Error?) -> Void)) {
        let file = LCFile.init(payload: .data(data: data))
        file.mimeType = "image/jpeg".lcString
        file.save { result in
            switch result {
            case .success:
                if let url = file.url?.stringValue {
                    completion(url, nil)
                } else {
                    completion("", nil)
                }
                break
            case .failure(let error):
                completion(nil, error)
                break
            }
        }
    }
    
    // MARK: CURD
    func query<T: CloudProtocol>(type:T.Type, completion:@escaping(([T]?, Error?) -> Void)) {
//        guard let user = UserManager.shared.currentLoginUser else {
//            completion(nil, CloudError.message("未登录"))
//            return
//        }
        let className = type.className()
        let query = LCQuery(className: className)
        //query.whereKey("user", .equalTo(user))
        query.limit = 100
        query.count { result in
            switch result {
            case .success(let count):
                self.pageQuery(type: type, user:nil, count: count, completion: completion)
                break
            case .failure(let error):
                completion(nil, error)
                break
            }
        }
    }
    
    private func pageQuery<T:CloudProtocol>(type:T.Type, user:LCUser?, count:Int, completion:@escaping(([T]?, Error?) -> Void)) {
        let pages = count / 100 + 1
        var resultError:Error? = nil
        var results:[LCObject] = []
        let group = DispatchGroup.init()
        for page in 0 ..< pages {
            group.enter()
            let className = type.className()
            let query = LCQuery(className: className)
            //query.whereKey("user", .equalTo(user))
            query.limit = 100
            query.skip = page * 100
            query.find { result in
                switch result {
                case .success(objects: let objs):
                    results.append(contentsOf: objs)
                    break
                case .failure(error: let error):
                    resultError = error
                    break
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(self.convertToModels(type: type, from: results), resultError)
        }
        
    }
    
    func save<T: CloudProtocol>(models:[T], completion:@escaping((Error?)->Void)) {
        do {
            let group = DispatchGroup.init()
            var batchError:Error?
            try models.forEach { model in
                group.enter()
                let obj = model.identify().count > 0 ? LCObject.init(className: model.modelClassName(), objectId: model.identify()) : LCObject.init(className: model.modelClassName())
                try model.convert(to: obj)
                obj.save { result in
                    switch result {
                    case .success:
                        model.fillIdentify(obj.objectId?.stringValue ?? "")
                        break
                    case .failure(let error):
                        batchError = error
                        break
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                completion(batchError)
            }
        } catch let error {
            completion(error)
        }
    }
    
    func delete<T: CloudProtocol>(models:[T], completion:@escaping((Error?)->Void)) {
        let group = DispatchGroup.init()
        var batchError:Error?
        models.forEach { model in
            group.enter()
            let obj = LCObject(className: T.className(), objectId: model.identify())
            obj.delete { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    batchError = error
                    break
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(batchError)
        }
    }
    
    private func convertToModels<T:CloudProtocol>(type:T.Type, from objs:[LCObject]) -> [T] {
        var models:[T] = []
        for obj in objs {
            let instance = T.init()
            instance.fillModel(with: obj)
            models.append(instance)
        }
        return models
    }
    
}
