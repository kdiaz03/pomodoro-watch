//
//  WelcomeTabView.swift
//  Pomodoro
//
//  Created by Keven Diaz on 8/21/25.
//

import SwiftUI

struct WelcomeTabView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some View{
        TabView() {
            OnboardingView(
                title: "Welcome!",
                description: "Thanks for trying Doro!",
                icon: "hand.rays.fill",
                notif: false)
            
            OnboardingView(
                title: "Notifications",
                description: "To allow timer notification, press the button below",
                icon: "bell.and.waves.left.and.right.fill",
                notif: true)
            
            OnboardingView(
                title: "That's it!",
                description: "Press the button below to start studying. Good luck!",
                icon: "graduationcap.circle.fill",
                notif: false)
        }
    }
}

#Preview {
    WelcomeTabView()
}
