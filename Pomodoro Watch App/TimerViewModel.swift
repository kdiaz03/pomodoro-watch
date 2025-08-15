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
    @Published var isRinging = false
    @Published var pomoMode: Bool = true

    var totalDuration: Double { adjustableTimeInMinutes * 60 }

    private var startDate: Date?
    private var tickTimer: Timer?

    private var ringTimer: Timer?
    let device = WKInterfaceDevice.current()

    private let defaults = UserDefaults.standard
    private let persistKey = "TimerViewModel.state"

    private struct PersistedState: Codable {
        var adjustableTimeInMinutes: Double
        var elapsedTime: Double
        var isActive: Bool
        var isRinging: Bool
        var startDate: Date?
    }

    init() {
        loadState()
        reconcileWithWallClock()
        if isActive { startTicking() }
        if isRinging { startRinging() }
    }

    // MARK: - Derived Values
    private var effectiveElapsed: Double {
        if let start = startDate, isActive {
            return max(0, min(Date().timeIntervalSince(start), totalDuration))
        } else {
            return min(elapsedTime, totalDuration)
        }
    }
    
    func userAdjustedMinutes(_ minutes: Double) {
        let clamped = max(1, min(60, minutes))

        if isActive {
            adjustableTimeInMinutes = clamped
            resetTimer()
        } else {
            adjustableTimeInMinutes = clamped
            saveState()
        }
    }

    var timeDisplay: String {
        let remaining = max(totalDuration - effectiveElapsed, 0)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return min(effectiveElapsed / totalDuration, 1.0)
    }

    var progressColor: Color {
        let p = progress
        if p < 0.75 { return .green }
        else if p < 0.9 { return .yellow }
        else { return .red }
    }

    // MARK: - Controls
    func toggleTimer() {
        isActive ? pauseTimer() : startTimer()
    }

    func resetTimer() {
        stopTicking()
        isActive = false
        isRinging = false
        elapsedTime = 0
        startDate = nil
        saveState()
    }

    func updateTimer() {
        guard isActive else { return }
        elapsedTime = effectiveElapsed
        if elapsedTime >= totalDuration {
            timerCompleted()
        }
    }

    private func startTimer() {
        let now = Date()
        startDate = now.addingTimeInterval(-elapsedTime)
        isActive = true
        isRinging = false
        startTicking()
        saveState()
    }

    private func pauseTimer() {
        elapsedTime = effectiveElapsed
        isActive = false
        stopTicking()
        startDate = nil
        saveState()
    }

    private func startTicking() {
        tickTimer?.invalidate()
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    private func stopTicking() {
        tickTimer?.invalidate()
        tickTimer = nil
    }

    // MARK: - Ringing
    func startRinging() {
        isRinging = true

        ringTimer?.invalidate()
        ringTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.device.play(.success)
        }

        device.play(.success)
        saveState()
    }

    func stopRinging() {
        ringTimer?.invalidate()
        ringTimer = nil
        isRinging = false
        resetTimer()
        saveState()
    }

    private func timerCompleted() {
        isActive = false
        stopTicking()
        startDate = nil
        startRinging()
        primeNextSession()
        saveState()
    }

    private func primeNextSession() {
        pomoMode.toggle()
        adjustableTimeInMinutes = pomoMode ? 25 : 5
        elapsedTime = 0
        startDate = nil
    }

    // MARK: - Persistence & Recovery
    private func saveState() {
        let state = PersistedState(
            adjustableTimeInMinutes: adjustableTimeInMinutes,
            elapsedTime: elapsedTime,
            isActive: isActive,
            isRinging: isRinging,
            startDate: startDate
        )
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: persistKey)
        }
    }

    private func loadState() {
        guard let data = defaults.data(forKey: persistKey),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data) else { return }
        adjustableTimeInMinutes = state.adjustableTimeInMinutes
        elapsedTime = state.elapsedTime
        isActive = state.isActive
        isRinging = state.isRinging
        startDate = state.startDate
    }

    private func reconcileWithWallClock() {
        if isActive, let start = startDate {
            let newElapsed = max(0, min(Date().timeIntervalSince(start), totalDuration))
            elapsedTime = newElapsed
            if newElapsed >= totalDuration {
                timerCompleted()
            }
        }
    }
    
    // MARK: - Pomodoro Switch
    var sessionLabel: String { pomoMode ? "Session" : "Break"}
    
    func togglePomodoroMode() {
        pomoMode.toggle()
        adjustableTimeInMinutes = pomoMode ? 25 : 5
        resetTimer()
        saveState()
    }
}
