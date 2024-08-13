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
    @StateObject var timerModel = TimerModel()
    
    var body: some Scene {
        
        WindowGroup {
            ToDoListView(timerModel: timerModel)
                .environmentObject(modelData)
                .onAppear {
                    print("main view appear")
                    modelData.loadFromServer()
                }
        }
        
        MenuBarExtra("\(timerModel.timeSeconds > 0 ? timerModel.timeSeconds.timeStr : "无任务") \(timerModel.timeSeconds > 0 ? (timerModel.timingItem?.title ?? "") : "")") {
            Button("pause") {
                if timerModel.isTiming {
                    timerModel.pauseTimer()
                    handlePauseEvent()
                }
            }
            
            Button("stop") {
                self.handleStopEvent()
                timerModel.stopTimer()
            }
            
            Button("restart") {
                if timerModel.isTiming {
                    return
                }
                timerModel.restartTimer()
                handleRestartEvent()
            }
        }
    }
    
    func handleRestartEvent() {
        guard let item = timerModel.timingItem else {
             return
        }
        item.playTime = .now
        modelData.updateItem(item)
    }
    
    func handlePauseEvent() {
        guard let item = timerModel.timingItem, let playTime = item.playTime else {
             return
        }
        let interval = Int(Date.now.timeIntervalSince1970 - playTime.timeIntervalSince1970)
        if interval < 60 {
            return
        }
        let dateInterval = LQDateInterval(start: playTime, end: .now)
        item.intervals.append(dateInterval)
        modelData.updateItem(item)
    }
    
    func handleStopEvent() {
        guard let item = timerModel.timingItem, let playTime = item.playTime else {
            return
        }
        let interval = Int(Date.now.timeIntervalSince1970 - playTime.timeIntervalSince1970)
        if interval < 60 {
            return
        }
        let dateInterval = LQDateInterval(start: playTime, end: .now)
        item.intervals.append(dateInterval)
        item.isPlay = false
        modelData.updateItem(item)
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
