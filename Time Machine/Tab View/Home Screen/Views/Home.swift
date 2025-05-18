//
//  Home.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

struct Home: View {
    
    @State private var trigger: Bool = false
    @AppStorage("user_email") private var email: String = ""
    
    @StateObject private var timeLoggerViewModel = TimeLoggerViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing:12) {
                Spacer()
                HackerTextView(
                    text: "Hello \(email)!",
                    trigger: trigger,
                    transition: .numericText(),
                    duration: 0.75,
                    speed: 0.06
                )
                .font(.largeTitle.bold())
                .lineLimit(2)
                .onAppear {
                    trigger.toggle()
                }
                
                //Spacer(minLength: 20)
                
                CategoryTotalsGridView(viewModel: timeLoggerViewModel)
                    .padding(.top, 15)
                
                WheelPickerView()
                    .frame(minHeight: 200)
                
                GeminiTimelineView(viewModel: timeLoggerViewModel)
                
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    Home()
}
