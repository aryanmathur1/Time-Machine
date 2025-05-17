//
//  TimeLoggerView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//


import SwiftUI

struct TimeLoggerView: View {
    
    @StateObject private var viewModel = TimeLoggerViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Picker("Category", selection: $viewModel.selectedCategory) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Button(action: {
                    if viewModel.isLogging {
                        viewModel.stopLogging()
                    } else {
                        viewModel.startLogging()
                    }
                }) {
                    Text(viewModel.isLogging ? "⏹️ Stop" : "▶️ Start")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isLogging ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                List {
                    ForEach(viewModel.log) { entry in
                        VStack(alignment: .leading) {
                            Text("📌 \(entry.category)")
                                .font(.headline)
                            Text("🕒 \(entry.start.formatted(date: .omitted, time: .shortened)) → \(entry.end.formatted(date: .omitted, time: .shortened))")
                            Text("Duration: \(formatDuration(entry.duration))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: viewModel.deleteEntries) // 👈 Add this line
                }

            }
            .navigationTitle("Time Capsule")
        }
        
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(mins)m \(secs)s"
    }

}
