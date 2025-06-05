//
//  TimerModel.swift
//  ToDo
//
//  Created by LQ on 2024/8/12.
//

import SwiftUI

class TimerModel: ObservableObject {
    
    @Published var timeSeconds: Int = 0
    @Published var title: String = ""
    
    var timer: Timer?
    
    var isTiming: Bool = false
    var timingItem: EventItem? = nil
    
    init() {
        addObservers()
    }
    
    deinit {
        removeObservers()
        timer?.invalidate()
        timer = nil
    }
    
    private func addObservers() {
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
    }
    
    private func removeObservers() {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
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
    
    func startTimer(item: EventItem) -> Bool {
        if timingItem != nil {
            print("has timing item")
            return false
        }
        timingItem = item
        timeSeconds = 0
        title = item.title
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
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.timeSeconds += 1
        })
    }
    
}
