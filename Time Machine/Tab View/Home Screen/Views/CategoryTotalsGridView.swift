//
//  CategoryTotalsGridView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/18/25.
//

import SwiftUI

struct CategoryTotalsGridView: View {
    @ObservedObject var viewModel: TimeLoggerViewModel

    private let primaryCategories = ["Work", "Rest", "Social Media", "Exercise"]

    private var timeSpentByCategory: [String: TimeInterval] {
        var totals: [String: TimeInterval] = [
            "Work": 0,
            "Rest": 0,
            "Social Media": 0,
            "Exercise": 0,
            "Other": 0
        ]

        for entry in viewModel.log {
            if primaryCategories.contains(entry.category) {
                totals[entry.category, default: 0] += entry.duration
            } else {
                totals["Other", default: 0] += entry.duration
            }
        }

        return totals
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack {
            Button(action: {
                viewModel.loadLogFromServer()
            }) {
                Label {
                    Text("Refresh")
                        .font(.body)
                        .bold()
                } icon: {
                    Image(systemName: "arrow.clockwise.circle")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .foregroundColor(Color.accentColor.opacity(0.8))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(timeSpentByCategory.keys.sorted(), id: \.self) { category in
                    if let duration = timeSpentByCategory[category], duration > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(formattedTime(for: duration))
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(gradientBackground(for: category))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                }
            }
            .navigationTitle("Time by Category")
        }
    }

    private func gradientBackground(for category: String) -> some View {
        ZStack {
            baseColor(for: category)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.15),
                    Color.clear
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func baseColor(for category: String) -> Color {
        switch category {
        case "Work":
            return .blue
        case "Rest":
            return .green
        case "Social Media":
            return .pink
        case "Exercise":
            return .red
        case "Other":
            return .yellow
        default:
            return .gray
        }
    }

    private func formattedTime(for duration: TimeInterval) -> String {
        let totalMinutes = Int(duration / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h \(minutes)m"
    }
}

