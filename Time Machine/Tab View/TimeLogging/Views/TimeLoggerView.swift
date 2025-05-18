//
//  TimeLoggerView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//


import SwiftUI

struct TimeLoggerView: View {
    
    @ObservedObject var viewModel: TimeLoggerViewModel
    
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("userApiKey") var userApiKey: String = ""
    
    @State private var showingEditSheet = false
    @State private var selectedEntryForEdit: TimeEntry?
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var startTime: Date?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer(minLength: 10)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button(action: {
                                viewModel.selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.callout)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(viewModel.selectedCategory == category ? Color.accentColor.opacity(0.8) : Color.gray.opacity(0.2))
                                    .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    if viewModel.isLogging, startTime == nil {
                        // Reconstruct startTime using last entry
                        if let last = viewModel.log.last(where: { $0.end == nil }) {
                            startTime = last.start
                            startTimer()
                        }
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                }
                
                
                Button(action: {
                    if viewModel.isLogging {
                        viewModel.stopLogging()
                        timer?.invalidate()
                        timer = nil
                        startTime = nil
                    } else {
                        viewModel.startLogging()
                        startTime = Date()
                        elapsedTime = 0
                        startTimer()
                    }
                }) {
                    withAnimation(.bouncy) {
                        Label {
                            HStack {
                                Text(viewModel.isLogging ? "Stop" : "Start")
                                if viewModel.isLogging {
                                    Text(formatDuration(elapsedTime))
                                        .font(.caption)
                                }
                            }
                        } icon: {
                            Image(systemName: viewModel.isLogging ? "stop.circle.fill" : "play.circle.fill")
                        }
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isLogging ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                
                List {
                    ForEach(viewModel.log) { entry in
                        VStack(alignment: .leading) {
                            Text("📌 \(entry.category)")
                                .font(.headline)
                            Text("🕒 \(formattedDateRange(from: entry.start, to: entry.end))")
                            Text("Duration: \(formatDuration(entry.duration))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 5)
                        .swipeActions(edge: .leading) {
                            Button("Edit") {
                                selectedEntryForEdit = entry
                                showingEditSheet = true
                            }
                            .tint(.yellow)
                        }
                    }
                    .onDelete(perform: viewModel.deleteEntries)
                }
                
            }
            .navigationTitle("Time Log")
        }
        .sheet(item: $selectedEntryForEdit) { entry in
            EditEntrySheet(
                entry: entry,
                categories: viewModel.categories,
                onSave: { updatedEntry in
                    if let index = viewModel.log.firstIndex(where: { $0.id == updatedEntry.id }) {
                        viewModel.log[index] = updatedEntry
                        viewModel.saveLogToServer()
                    }
                    selectedEntryForEdit = nil
                },
                onCancel: {
                    selectedEntryForEdit = nil
                }
            )
        }

        
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(mins)m \(secs)s"
    }
    
    private func formattedDateRange(from start: Date, to end: Date) -> String {
        let calendar = Calendar.current
        let sameDay = calendar.isDate(start, inSameDayAs: end)
        
        let datePart = TimeLoggerView.customDateOnlyFormatter.string(from: start)
        let startTime = TimeLoggerView.timeOnlyFormatter.string(from: start)
        let endTime = TimeLoggerView.timeOnlyFormatter.string(from: end)
        
        if sameDay {
            return "\(datePart) \(startTime) → \(endTime)"
        } else {
            let endDatePart = TimeLoggerView.customDateOnlyFormatter.string(from: end)
            return "\(datePart) \(startTime) → \(endDatePart) \(endTime)"
        }
    }
    
    private static let customDateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    private static let timeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    private static let customDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy h:mm a"
        return formatter
    }()
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }

}
