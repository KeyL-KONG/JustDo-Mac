//
//  TimerModel.swift
//  ToDo
//
//  Created by LQ on 2024/8/12.
//

import SwiftUI

class TimerModel: ObservableObject {
    
    @Published var timeSeconds: Int = 0
    
    var timer: Timer?
    
    var isTiming: Bool = false
    var timingItem: EventItem? = nil
    
    init() {
        
    }
    
    func startTimer(item: EventItem) -> Bool {
        if timingItem != nil {
            print("has timing item")
            return false
        }
        timingItem = item
        timeSeconds = 0
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
    }
    
    private func start() {
        isTiming = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.timeSeconds += 1
        })
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
}
