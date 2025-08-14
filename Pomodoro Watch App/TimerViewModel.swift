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
    @Published var totalDuration: Double = 25.0 * 60

    // New: wall-clock based timing
    private var startDate: Date?
    private var endDate: Date?
    private var tickTimer: Timer?

    // Existing ring timer for haptics
    private var ringTimer: Timer?

    // Haptics device
    let device = WKInterfaceDevice.current()

    // Persistence
    private let defaults = UserDefaults.standard
    private let persistKey = "TimerViewModel.state"

    private struct PersistedState: Codable {
        var adjustableTimeInMinutes: Double
        var elapsedTime: Double
        var isActive: Bool
        var isRinging: Bool
        var totalDuration: Double
        var startDate: Date?
        var endDate: Date?
    }

    // Init: restore any in-progress timer from disk and reconcile with wall clock
    init() {
        loadState()
        reconcileWithWallClock()
        if isActive { startTicking() }
        if isRinging { startRinging() }
    }

    // MARK: - Derived Values
    private var effectiveElapsed: Double {
        if let start = startDate, isActive {
            return min(Date().timeIntervalSince(start), totalDuration)
        } else {
            return min(elapsedTime, totalDuration)
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
        if isActive { pauseTimer() } else { startTimer() }
    }

    func resetTimer() {
        stopTicking()
        isActive = false
        isRinging = false
        elapsedTime = 0
        startDate = nil
        endDate = nil
        totalDuration = adjustableTimeInMinutes * 60
        saveState()
    }

    // Called by a 1s UI ticker. Computes from wall clock, not by incrementing.
    func updateTimer() {
        guard isActive else { return }
        elapsedTime = effectiveElapsed
        if elapsedTime >= totalDuration {
            timerCompleted()
        }
    }

    private func startTimer() {
        // If resuming after a pause, preserve existing elapsedTime
        let now = Date()
        startDate = now.addingTimeInterval(-elapsedTime)
        endDate = startDate!.addingTimeInterval(totalDuration)
        isActive = true
        isRinging = false
        startTicking()
        saveState()
    }

    private func pauseTimer() {
        // Freeze elapsed based on wall clock, clear dates
        elapsedTime = effectiveElapsed
        isActive = false
        stopTicking()
        startDate = nil
        endDate = nil
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
        elapsedTime = totalDuration
        startDate = nil
        endDate = nil
        startRinging()
        saveState()
    }

    // MARK: - Persistence & Recovery
    private func saveState() {
        let state = PersistedState(
            adjustableTimeInMinutes: adjustableTimeInMinutes,
            elapsedTime: elapsedTime,
            isActive: isActive,
            isRinging: isRinging,
            totalDuration: totalDuration,
            startDate: startDate,
            endDate: endDate
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
        totalDuration = state.totalDuration
        startDate = state.startDate
        endDate = state.endDate
    }

    private func reconcileWithWallClock() {
        // If we had an active timer and a startDate, recompute elapsed vs current time.
        if isActive, let start = startDate {
            let newElapsed = min(Date().timeIntervalSince(start), totalDuration)
            elapsedTime = newElapsed
            if newElapsed >= totalDuration {
                timerCompleted()
            }
        }
    }
}
