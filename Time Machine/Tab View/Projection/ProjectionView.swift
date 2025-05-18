//
//  ProjectionView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//


//
//  Projection.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

struct ProjectionView: View {
    
    @StateObject private var timeLoggerViewModel = TimeLoggerViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 20.0) {
                    Text("AI Projections")
                        .font(.title.bold())
                        .foregroundStyle(Color.black)
                    Text("Powered by Google Gemini Artificial Intelligence")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)

                    GeminiTipsView(viewModel: timeLoggerViewModel)
                    GeminiScenariosView(viewModel: timeLoggerViewModel)

                }
                .padding(.top, 20.0)
                
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("AI Projections")
    }
}
