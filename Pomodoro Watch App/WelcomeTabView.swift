//
//  WelcomeTabView.swift
//  Pomodoro
//
//  Created by Keven Diaz on 8/21/25.
//

import SwiftUI
import UserNotifications

struct WelcomeTabView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some View{
        TabView() {
            OnboardingView(
                title: "Welcome!",
                description: "Thanks for trying Doro!",
                icon: "hand.rays.fill")
            
            ButtonOnboardingView(
                title: "Notifications",
                description: "To allow timer notification, press the button below",
                icon: "bell.and.waves.left.and.right.fill",
                buttonText: "Enable Notifications",
                buttonAction: {
                    requestNotificationPermission()
                })
            
            ButtonOnboardingView(
                title: "That's it!",
                description: "Press the button below to start studying. Good luck!",
                icon: "graduationcap.circle.fill",
                buttonText: "Continue",
                buttonAction: {
                    isFirstLaunch = false
                    
                })
            
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    print("Error requesting notifications: \(error)")
                } else {
                    print(granted ? "Permission granted" : "Permission denied")
                }
            }
    }
}

#Preview {
    WelcomeTabView()
}
