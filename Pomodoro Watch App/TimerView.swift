//  ContentView.swift
//  Pomodoro Watch App
//
//  Created by Keven Diaz on 6/21/25.

import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    @FocusState private var isCrownFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let dialDiameter = size
            let lineWidth = max(6, dialDiameter * 0.06)

            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.gray.opacity(0.30),
                            style: StrokeStyle(lineWidth: lineWidth))
                    .frame(width: dialDiameter, height: dialDiameter)

                // Progress ring
                Circle()
                    .trim(from: 0, to: min(max(viewModel.progress, 0), 1))
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(viewModel.progressColor)
                    .rotationEffect(.degrees(-90))
                    .frame(width: dialDiameter, height: dialDiameter)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.progress)

                // Time
                Text(viewModel.timeDisplay)
                    .font(.system(size: dialDiameter * 0.2, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.5)
                    .focusable(true)
                    .focused($isCrownFocused)
                    .digitalCrownRotation(
                        Binding(
                            get: { viewModel.adjustableTimeInMinutes },
                            set: { viewModel.userAdjustedMinutes($0) }
                        ),
                        from: 1.0,
                        through: 60.0,
                        by: 1.0,
                        sensitivity: .medium,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .onTapGesture {
                if viewModel.isRinging { viewModel.stopRinging() }
                else { viewModel.toggleTimer() }
            }
            .onLongPressGesture(minimumDuration: 1.0) {
                viewModel.resetTimer()
            }
            .overlay() {
                Button {
                    viewModel.togglePomodoroMode()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.pomoMode ? "graduationcap.fill" : "moon.zzz.fill")
                        Text(viewModel.sessionLabel)
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(radius: 2)
                .padding(.trailing, 10)
                .padding(.bottom, 8)
                .buttonStyle(.plain)
                .offset(y: 35)
            }
        }
        .onAppear { isCrownFocused = true }
        .onChange(of: isCrownFocused) { oldVal, newVal in
            if oldVal == true, newVal == false {
                viewModel.resetTimer()
            }
        }
    }
}

#Preview {
    TimerView()
}
