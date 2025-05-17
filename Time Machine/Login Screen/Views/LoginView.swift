//
//  LoginView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

struct LoginView: View {
    
    enum AuthMode {
        case login, signup
    }
    
    var onLoginSuccess: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var authMode: AuthMode = .login
    
    var body: some View {
        ZStack {
            Color.pink.ignoresSafeArea()
            Circle()
                .scale(1.5)
                .foregroundColor(.white.opacity(0.15))
            Circle()
                .scale(1.2)
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                Text(authMode == .login ? "Login" : "Create Account")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                
                TextField("Email", text: $email)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.none)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(10)
                    .border(errorMessage != nil ? Color.red : Color.clear, width: 2)
                    .textFieldStyle(PlainTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.none)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(10)
                    .border(errorMessage != nil ? Color.red : Color.clear, width: 2)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                Button {
                    Task {
                        if authMode == .login {
                            await authenticateUser(email: email, password: password)
                        } else {
                            await createUser(email: email, password: password)
                        }
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: 300, height: 50)
                    } else {
                        Text(authMode == .login ? "Login" : "Create Account")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.pink)
                            .cornerRadius(10)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                Button {
                    withAnimation {
                        authMode = authMode == .login ? .signup : .login
                        errorMessage = nil
                    }
                } label: {
                    Text(authMode == .login ? "Don't have an account? Create one" : "Already have an account? Login")
                        .foregroundColor(.pink)
                        .font(.footnote)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    func authenticateUser(email: String, password: String) async {
        await performAuthRequest(endpoint: "login", email: email, password: password)
    }
    
    func createUser(email: String, password: String) async {
        await performAuthRequest(endpoint: "signup", email: email, password: password)
    }
    
    private func performAuthRequest(endpoint: String, email: String, password: String) async {
        guard let url = URL(string: "https://loginchatworthy.aryanrajmathur.workers.dev/\(endpoint)") else {
            errorMessage = "Invalid server URL"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["email": email, "password": password]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response"
                isLoading = false
                return
            }
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let key = json["apiKey"] as? String {
                    
                    // ✅ Save to AppStorage so GeminiView can access it
                    UserDefaults.standard.set(key, forKey: "user_apiKey")
                    
                    DispatchQueue.main.async {
                        onLoginSuccess()
                    }
                } else {
                    errorMessage = "Failed to parse API key."
                }
            } else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = json["error"] as? String {
                    errorMessage = error
                } else {
                    errorMessage = "Authentication failed with status \(httpResponse.statusCode)"
                }
            }
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

