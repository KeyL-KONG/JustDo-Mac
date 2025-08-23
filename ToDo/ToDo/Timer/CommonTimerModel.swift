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
        
#if os(iOS)
        // 添加iOS平台的前后台切换监听
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
#endif
    }
    
#if os(iOS)
    /// 应用将要进入非活跃状态（如切换到后台）
    @objc private func appWillResignActive(_ notification: Notification) {
        DispatchQueue.main.async {
            self.pauseTimer()
        }
    }
    
    /// 应用已进入活跃状态（如从后台回到前台）
    @objc private func appDidBecomeActive(_ notification: Notification) {
        DispatchQueue.main.async {
            if self.timingItem != nil && !self.isTiming {
                self.restartTimer()
            }
        }
    }
#endif
    
    private func removeObservers() {
#if os(macOS)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
#endif
        
#if os(iOS)
        // 移除iOS平台的监听
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
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
        isTiming = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.timeSeconds += 1
        })
    }
    
    func pauseTimer() {
        print("pause time")
        self.timer?.invalidate()
        self.timer = nil
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
