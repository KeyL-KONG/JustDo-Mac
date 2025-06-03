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
    
    @State var title: String = "无事项"
    @State var selectedID: String = "" {
        didSet {
            print("select id: \(selectedID)")
        }
    }
    
    // 新增状态属性
    @State private var showStopAlert = false
    @State private var eventContent = ""
    @State private var pendingItem: (item: EventItem, playTime: Date)?
    @State private var showSearchWindow: Bool = false
    @State var selection: ToDoSection = .today {
        didSet {
            print("select section: \(selection)")
        }
    }
    
    // 新增窗口场景
    var body: some Scene {
        WindowGroup {
            EquatableView(content: ToDoListView(uniqueID: "unique", timerModel: timerModel, selection: $selection, selectItemID: $selectedID))
                .environmentObject(modelData)
                .onAppear {
                    print("main view appear")
                    self.addKeyboardEvent()
                    modelData.loadFromServer()
                }
                .sheet(isPresented: $showSearchWindow, content: {
                    SearchWindowView(showSearchWindowView: $showSearchWindow, section: $selection, selectionId: $selectedID).environmentObject(modelData)
                })
                .alert("编辑事件内容", isPresented: $showStopAlert) {
                    TextField("请输入内容...", text: $eventContent)
                    Button("取消", role: .cancel) {
                        pendingItem = nil
                        downWindow()
                    }
                    Button("确定") {
                        downWindow()
                        if let pendingItem {
                            let taskItem = TaskTimeItem(startTime: pendingItem.playTime, endTime: .now, content: eventContent)
                            taskItem.eventId = pendingItem.item.id
                            modelData.updateTimeItem(taskItem)
                            
                            pendingItem.item.isPlay = false
                            modelData.updateItem(pendingItem.item)
                        }
                    }
                } message: {
                    Text("")
                }
        }
        
        // 注册预览窗口
        WindowGroup("Markdown Preview", id: "markdown-preview", for: EventItem.self) { $item in
            if let item {
                MarkdownView(item: item)
                    .environmentObject(modelData)
                    .frame(minWidth: 300, minHeight: 200)
                    .padding()
            }
        }
        .windowStyle(.hiddenTitleBar)
        
        WindowGroup("Markdown Preview", id: CommonDefine.noteWindow, for: NoteModel.self) { $item in
            if let item {
                NoteDetailView(isWindow: true, noteItem: item)
                    .environmentObject(modelData)
                    .frame(minWidth: 300, minHeight: 200)
                    .padding()
            }
        }
        .windowStyle(.hiddenTitleBar)
        
        
        MenuBarExtra {
            AddItemView()
                .environmentObject(modelData)
        } label: {
            Image(systemName: "lightbulb.max").font(.largeTitle)
        }
        .menuBarExtraStyle(.window)
        
        MenuBarExtra {
            NoteQuickView()
                .environmentObject(modelData)
        } label: {
            Image(systemName: "pencil").font(.largeTitle)
        }
        .menuBarExtraStyle(.window)

        
        MenuBarExtra("\(timerModel.timeSeconds > 0 ? timerModel.timeSeconds.minAndHourTimeStr : "none")") {
            TaskSaveView(timerModel: timerModel)
                .environmentObject(modelData)
        }
        .menuBarExtraStyle(.window)
        .onChange(of: timerModel.title) { oldValue, newValue in
            self.title =  timerModel.title.isEmpty ? "无事项" : "<\(timerModel.title)> 进行中"
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
        guard let item = timerModel.timingItem, let playTime = item.playTime else { return }
        pendingItem = (item, playTime)
        timerModel.stopTimer()
        showStopAlert.toggle()
        // 打开新窗口
        NSApp.activate(ignoringOtherApps: true)
        let window = NSApp.windows.first
        window?.level = .floating
        window?.makeKeyAndOrderFront(nil)
    }
    
    func downWindow() {
        let window = NSApp.windows.first
        window?.level = .normal
    }
    
    func addKeyboardEvent() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
           if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers?.lowercased() == "k" {
               self.showSearchWindow.toggle()
               return nil
           } else if event.charactersIgnoringModifiers?.lowercased() == "esc" {
               self.showSearchWindow = false
           }
           return event
       }
    }
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
 
    func applicationWillFinishLaunching(_ notification: Notification) {
        //LCApplication.logLevel = .debug
        let appId = "sVkf4GuCkJf9r8q9BjTVax8b-gzGzoHsz"
        let appKey = "sD7s2RQAGL77oRNg9rCkQIzE"
        let url = "https://svkf4guc.lc-cn-n1-shared.com"
        
        do {
            try LCApplication.default.set(id: appId, key: appKey, serverURL: url)
        } catch {
            print(error)
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("did finish")
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        return true
    }
    
}
#endif
