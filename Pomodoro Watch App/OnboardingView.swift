//
//  OnboardingView.swift
//  Pomodoro
//
//  Created by Keven Diaz on 8/21/25.
//

import SwiftUI

struct OnboardingView: View {
    
    let title: String
    let description: String
    let icon: String
    
    let notif: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundStyle(.yellow)
                
                Text(title)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 10)
                
                if notif {
                    Button {
                        
                    } label: {
                        Text("Enable Notifications")
                    }
                }
            }
            .padding(5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(.gray.opacity(0.12)))
    }
}

#Preview {
    OnboardingView(
        title: "Test Title hey sup",
        description: "Hello, welcome to Studoro!",
        icon: "hand.wave.fill",
        notif: true
    )
}
