//
//  TimerLoggerViewModel.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import Foundation
import Combine

class TimeLoggerViewModel: ObservableObject {
    @Published var selectedCategory: String = "Work"
    @Published var isLogging: Bool = false
    @Published var log: [TimeEntry] = [] {
        didSet {
            saveLog()
        }
    }

    private var startTime: Date?
    let categories = ["Work", "Study", "Rest", "Social Media", "Exercise"]

    private let savePath = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("TimeLog.json")

    init() {
        loadLog()
    }

    func startLogging() {
        startTime = Date()
        isLogging = true
    }

    func stopLogging() {
        guard let start = startTime else { return }
        let end = Date()
        let entry = TimeEntry(category: selectedCategory, start: start, end: end)
        log.insert(entry, at: 0)
        isLogging = false
        startTime = nil
    }

    // MARK: - Save/Load
    private func saveLog() {
        do {
            let data = try JSONEncoder().encode(log)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
            print("✅ Log saved.")
        } catch {
            print("❌ Failed to save log: \(error.localizedDescription)")
        }
    }

    private func loadLog() {
        do {
            let data = try Data(contentsOf: savePath)
            log = try JSONDecoder().decode([TimeEntry].self, from: data)
            print("📥 Log loaded.")
        } catch {
            print("⚠️ No existing log or failed to load: \(error.localizedDescription)")
            log = []
        }
    }
}
