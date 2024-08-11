//
//  ToDoApp.swift
//  ToDo
//
//  Created by LQ on 2024/8/9.
//

import SwiftUI
import LeanCloud

@main
struct ToDoApp: App {
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    let modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ToDoListView()
                .environmentObject(modelData)
                .onAppear {
                    print("main view appear")
                    modelData.loadFromServer()
                }
        }
    }
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
 
    func applicationWillFinishLaunching(_ notification: Notification) {
        LCApplication.logLevel = .debug
        let appId = "sVkf4GuCkJf9r8q9BjTVax8b-gzGzoHsz"
        let appKey = "sD7s2RQAGL77oRNg9rCkQIzE"
        let url = "https://svkf4guc.lc-cn-n1-shared.com"
        
        do {
            try LCApplication.default.set(id: appId, key: appKey, serverURL: url)
        } catch {
            print(error)
        }
    }
    
}
#endif
