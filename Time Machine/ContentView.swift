//
//  ContentView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI // daniel says HI

struct ContentView: View {
    @State private var isAuthenticated = false
    
    var body: some View {
        if isAuthenticated {
            MainTabView()
                .preferredColorScheme(.light)
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

#Preview {
    ContentView()
}
