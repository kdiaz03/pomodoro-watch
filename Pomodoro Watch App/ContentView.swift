//
//  ContentView.swift
//  Pomodoro Watch App
//
//  Created by Keven Diaz on 6/21/25.
//

import SwiftUI

struct TimerView: View {
    @State private var adjustableTime: Double = 30.0
    @State private var progress: Double = 1.0
    
    @FocusState private var isCrownFocused: Bool
    
    private func formatTime(from totalSeconds: Double) -> String {
            let minutes = Int(totalSeconds) / 60
            let seconds = Int(totalSeconds) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 8))
                    .foregroundColor(.gray.opacity(0.3))

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)

                Text(formatTime(from: adjustableTime * 60))
                    .focusable()
                    .digitalCrownRotation(
                        $adjustableTime,
                        from: 1.0,
                        through: 60.0,
                        by: 1.0,
                        sensitivity: .medium,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )
            }
            .padding(.horizontal, 10)
            .font(.title2)
        }
    }
}

// MARK: - Preview

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
