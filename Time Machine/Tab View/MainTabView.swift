//
//  MainTabView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        
        TabView {
            
            Tab("Home", systemImage: "house") {
                
            }
            
            Tab("Time Log", systemImage: "calendar.badge.clock") {
                TimeLoggerView()
            }
            
            Tab("Projection", systemImage: "sparkles") {
                
            }
            
            Tab("Time Energy", systemImage: "bolt") {
                
            }
            
            Tab("Account", systemImage: "person.crop.circle.fill") {
                ProfileView(onSignOut: {
                    // Clear login credentials
                    UserDefaults.standard.removeObject(forKey: "user_apiKey")
                    UserDefaults.standard.removeObject(forKey: "user_email")
                })
            }
            //.badge(2)
            
        }
        
    }
}

#Preview {
    MainTabView()
}
