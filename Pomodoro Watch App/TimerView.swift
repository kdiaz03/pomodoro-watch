//  ContentView.swift
//  Pomodoro Watch App
//
//  Created by Keven Diaz on 6/21/25.

import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    @FocusState private var isCrownFocused: Bool
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            Text("Study Period")
                .font(.system(size: 18, weight: .bold))
            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .foregroundColor(.gray.opacity(0.3))
                
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .foregroundColor(viewModel.progressColor)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: viewModel.progress)

                Text(viewModel.timeDisplay)
                    .font(.system(size: 28, weight: .bold))
                    .focusable()
                    .focused($isCrownFocused)
                    .digitalCrownRotation(
                        $viewModel.adjustableTimeInMinutes,
                        from: 1.0,
                        through: 60.0,
                        by: 1.0,
                        sensitivity: .medium,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )
            }
            .onTapGesture {
                if viewModel.isRinging {
                    viewModel.stopRinging()
                } else {
                    viewModel.toggleTimer()
                }
            }
            .onLongPressGesture(minimumDuration: 1.0) {
                viewModel.resetTimer()
            }
        }
        .onAppear {
            isCrownFocused = true
            viewModel.totalDuration = viewModel.adjustableTimeInMinutes * 60
        }
        .onReceive(timer) { _ in
            viewModel.updateTimer()
        }
        .onChange(of: viewModel.adjustableTimeInMinutes) {
            viewModel.resetTimer()
        }
    }
}

#Preview {
    TimerView()
}
