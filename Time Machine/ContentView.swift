//
//  ContentView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI // daniel says HI

struct ContentView: View {
    @AppStorage("user_apiKey") private var apiKey: String?
    @State private var isAuthenticated = false
    @State private var hasFinishedOnboarding: Bool = false
    
    var body: some View {
        Group {
            if isAuthenticated {
                MainTabView(isAuthenticated: $isAuthenticated)
                    .preferredColorScheme(.light)
            } else {
                if !hasFinishedOnboarding {
                    IntroView {
                        hasFinishedOnboarding = true
                    }
                } else {
                    LoginView(onLoginSuccess: {
                        isAuthenticated = true
                    })
                    .preferredColorScheme(.light)
                    .toolbar {
                        Text("Authentication")
                            .font(.callout)
                            .fontWeight(.regular)
                            .textScale(.secondary)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .onAppear {
            isAuthenticated = apiKey != nil
        }
    }
}


#Preview {
    ContentView()
}
