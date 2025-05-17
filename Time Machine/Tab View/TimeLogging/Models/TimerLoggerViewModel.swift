//
//  TimerLoggerViewModel.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import Foundation
import Combine
import SwiftUI

class TimeLoggerViewModel: ObservableObject {
    @Published var selectedCategory: String = "Work"
    @Published var isLogging: Bool = false
    @Published var log: [TimeEntry] = [] {
        didSet {
            saveLog()
        }
    }
    
    @AppStorage("user_email") private var email: String = ""
    @AppStorage("user_apiKey") private var apiKey: String = ""

    private var startTime: Date?
    let categories = ["Work", "Study", "Rest", "Social Media", "Exercise"]

    private let savePath = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("TimeLog.json")

    init() {
        //loadLog()
        loadLogFromServer() // ✅ pull remote log on launch
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
        saveLog()
        saveLogToServer() // ✅ save remotely
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
    
    func saveLogToServer() {
        guard let url = URL(string: "https://timemachine.aryanrajmathur.workers.dev/log/save") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": email,
            "apiKey": apiKey,
            "log": log.map { entry in
                [
                    "id": entry.id.uuidString,
                    "category": entry.category,
                    "start": ISO8601DateFormatter().string(from: entry.start),
                    "end": ISO8601DateFormatter().string(from: entry.end)
                ]
            }
        ]
        
        print(body)

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request).resume()
    }

    func loadLogFromServer() {
        guard let url = URL(string: "https://timemachine.aryanrajmathur.workers.dev/log/load") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "apiKey": apiKey]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let raw = try JSONDecoder().decode([[String: String]].self, from: data)

                let remoteLog: [TimeEntry] = raw.compactMap { dict in
                    guard let idStr = dict["id"],
                          let category = dict["category"],
                          let startStr = dict["start"],
                          let endStr = dict["end"],
                          let start = ISO8601DateFormatter().date(from: startStr),
                          let end = ISO8601DateFormatter().date(from: endStr),
                          let id = UUID(uuidString: idStr) else {
                        return nil
                    }

                    return TimeEntry(id: id, category: category, start: start, end: end)
                }
                print("📡 Server log: \(remoteLog)")

                DispatchQueue.main.async {
                    self.log = remoteLog // ✅ Replace local log with remote
                }

            } catch {
                print("❌ Server log decode failed: \(error)")
            }
        }.resume()
    }

    func deleteEntries(at offsets: IndexSet) {
        log.remove(atOffsets: offsets)
        saveLog()
        saveLogToServer()
    }
    
}
