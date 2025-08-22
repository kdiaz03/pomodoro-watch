//
//  PomodoroApp.swift
//  Pomodoro Watch App
//
//  Created by Keven Diaz on 6/21/25.
//

import SwiftUI

@main
struct Pomodoro_Watch_App: App {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some Scene {
        WindowGroup {
            if isFirstLaunch {
                WelcomeTabView()
            } else {
                TimerView()
            }
        }
    }
}
