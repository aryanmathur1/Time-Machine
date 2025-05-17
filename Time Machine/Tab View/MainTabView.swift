//
//  MainTabView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

struct MainTabView: View {
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                // Home view here
            }
            
            Tab("Time Log", systemImage: "calendar.badge.clock") {
                TimeLoggerView()
            }
            
            Tab("Projection", systemImage: "sparkles") {
                // Projection view here
            }
            
            Tab("Time Energy", systemImage: "bolt") {
                // Energy view here
            }
            
            Tab("Account", systemImage: "person.crop.circle.fill") {
                ProfileView(onSignOut: {
                    UserDefaults.standard.removeObject(forKey: "user_apiKey")
                    UserDefaults.standard.removeObject(forKey: "user_email")
                    isAuthenticated = false // ⬅️ go back to login
                })
            }
        }
    }
}

