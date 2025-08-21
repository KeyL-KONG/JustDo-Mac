//
//  DataManager.swift
//  Reading
//
//  Created by liuqiang on 2022/7/12.
//

import Foundation

class DataManager: NSObject {
    
    static let shared = DataManager.init()
    private var data:Dictionary = [String : [AnyObject]]()
    
    private var retryCount = 0
    
    func data<T: CloudProtocol>(with type:T.Type) -> [T] {
        return self.data[type.className()] as? [T] ?? []
    }
    
    func query<T:CloudProtocol>(type:T.Type, completion:@escaping([T]?, Error?)->Void) {
        CloudManager.shared.query(type: type) { objs, error in
            if let objs = objs {
                self.data[type.className()] = objs as [AnyObject]
            }
            completion(objs, error)
        }
    }
    
    func save<T:CloudProtocol>(with clsName:String, models:[T], completion:@escaping((Error?)->Void)) {
        self.retryCount += 1
        CloudManager.shared.save(models: models) { error in
            if error == nil {
                if var arr = self.data[clsName] as? [T] {
                    models.forEach { model in
                        if !arr.contains(where: { obj in
                            return obj.identify() == model.identify()
                        }) {
                            arr.append(model)
                        }
                    }
                    self.data[clsName] = arr as [AnyObject]
                } else {
                    self.data[clsName] = models as [AnyObject]
                }
            }
//            if self.retryCount % 2 == 0 {
//                completion(NSError(domain: "unknonw", code: 1, userInfo: nil))
//            } else {
//                completion(error)
//            }
            completion(error)
        }
    }
    
    func delete<T:CloudProtocol>(models:[T], completion:@escaping((Error?)->Void)) {
        CloudManager.shared.delete(models: models) { error in
            if error == nil {
                if let arr = self.data[T.className()] as? [T] {
                    self.data[T.className()] = arr.filter({ obj in
                        return !models.contains { model in
                            return obj.identify() == model.identify()
                        }
                    }) as [AnyObject]
                }
            }
            completion(error)
        }
    }
    
//    func getReadItemLinks() -> [String:[String]] {
//        let keyChain = KeychainSwift.init()
//        if let data = keyChain.getData("readlist"), !data.isEmpty {
//            do {
//                let dict = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:[String]]
//                return dict ?? [:]
//            } catch {
//                print(error)
//            }
//        }
//        return [:]
//    }
}
