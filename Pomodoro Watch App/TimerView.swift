import SwiftUI
import UserNotifications

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    @FocusState private var isCrownFocused: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.30),
                        style: StrokeStyle(lineWidth: 10))
                .padding(12)
                .frame(width: 175, height: 175)
            Circle()
                .trim(from: 0, to: min(max(viewModel.progress, 0), 1))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(viewModel.progressColor)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: viewModel.progress)
                .padding(12)
            
            Text(viewModel.timeDisplay)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
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
                .padding(.bottom, 15)
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
        .overlay(alignment: .center) {
            Button {
                viewModel.togglePomodoroMode()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.pomoMode ? "graduationcap.fill" : "moon.zzz.fill")
                    Text(viewModel.sessionLabel)
                }
            }
            
            .font(.system(size: 12, weight: .semibold))
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(radius: 2)
            .buttonStyle(.plain)
            .padding(.top, 50)
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
