//
//  TimerValueViewModel.swift
//  Pomodoro
//
//  Created by Keven Diaz on 6/23/25.
//

import SwiftUI
import WatchKit

class TimerViewModel: ObservableObject {
    @Published var adjustableTimeInMinutes: Double = 25.0
    @Published var elapsedTime: Double = 0.0
    @Published var isActive = false
    @Published var totalDuration: Double = 25.0 * 60
    
    let device = WKInterfaceDevice.current()
    
    var timeDisplay: String {
        let remaining = totalDuration - elapsedTime
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progress: Double {
        min(elapsedTime / totalDuration, 1.0)
    }
    
    var progressColor: Color {
        let progress = self.progress
        if progress < 0.75 { return .green }
        else if progress < 0.9 { return .yellow }
        else { return .red }
    }
    
    func toggleTimer() {
        isActive.toggle()
    }
    
    func resetTimer() {
        isActive = false
        elapsedTime = 0
        totalDuration = adjustableTimeInMinutes * 60
    }
    
    func updateTimer() {
        guard isActive else { return }
        
        elapsedTime += 1
        
        if elapsedTime >= totalDuration {
            timerCompleted()
        }
    }
    
    private func timerCompleted() {
        resetTimer()
        device.play(.success)
    }
}
