//
//  CommonTimerModel.swift
//  ToDo
//
//  Created by LQ on 2025/8/17.
//

import SwiftUI

class CommonTimerModel: ObservableObject {
    
    @Published var timeSeconds: Int = 0
    @Published var title: String = ""
    
    var timer: Timer?
    var startTime: Date?
    @Published var isTiming: Bool = false
    var timingItem: BaseModel? = nil
    
    init() {
        addObservers()
    }
    
    deinit {
        removeObservers()
        timer?.invalidate()
        timer = nil
    }
    
    private func addObservers() {
#if os(macOS)
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep(_:)),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake(_:)),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
#endif
    }
    
    private func removeObservers() {
#if os(macOS)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
#endif
    }
    
    @objc private func systemWillSleep(_ notification: Notification) {
        DispatchQueue.main.async {
            self.pauseTimer()
        }
    }
    
    @objc private func systemDidWake(_ notification: Notification) {
        DispatchQueue.main.async {
            if self.timingItem != nil {
                self.start()
            }
        }
    }
    
    func startTimer(item: BaseModel, title: String = "") -> Bool {
        if timingItem != nil {
            print("has timing item")
            return false
        }
        timingItem = item
        timeSeconds = 0
        self.title = title
        start()
        return true
    }
    
    func restartTimer() {
        start()
    }
    
    func pauseTimer() {
        self.timer?.invalidate()
        isTiming = false
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeSeconds = 0
        isTiming = false
        timingItem = nil
        title = ""
    }
    
    private func start() {
        isTiming = true
        startTime = .now
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.timeSeconds += 1
        })
    }
    
}
