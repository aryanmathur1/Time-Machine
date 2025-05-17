//
//  ProfileView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

struct ProfileView: View {
    
    @AppStorage("user_apiKey") private var apiKey: String?
    @AppStorage("user_email") private var email: String?
    
    var onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Profile")
                .font(.largeTitle)
                .bold()
            
            if let userEmail = email {
                Text("Logged in as:")
                    .font(.headline)
                Text(userEmail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text("No email found")
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            Button {
                signOut()
            } label: {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding()
    }
    
    private func signOut() {
        apiKey = nil
        email = nil
        onSignOut()
    }
}
