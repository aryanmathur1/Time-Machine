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
    
    // Change geminiTips type to array of strings
    @Published var geminiTips: [String] = []
    @Published var isLoadingGeminiTips = false
    @Published var isLoadingGeminiScenarios = false
    
    @Published var geminiScenarios: [String] = []
    
    @AppStorage("user_email") private var email: String = ""
    @AppStorage("user_apiKey") private var apiKey: String = ""
    
    private var startTime: Date?
    let categories = ["Work", "Rest", "Social Media", "Exercise", "Other"]
    
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
    
    func fetchGeminiTips(email: String, apiKey: String) {
        
        isLoadingGeminiTips = true
        
        loadLogFromServer()
        
        let prompt = """
            You are a productivity assistant. Given this time log, suggest daily optimization tips, and productivity insights in bullet points. Also give estimates of how much time the user is losing/gaining with certain tasks. Ex: Lose 10 hours/week to distractions → Miss project deadline by 3 weeks or Keep studying 2 hours a day → Reach fluency in 6 months:
            
            \(log.map {
                "\($0.category): \($0.start.formatted(date: .abbreviated, time: .shortened)) - \($0.end.formatted(date: .abbreviated, time: .shortened)) (\(Int($0.duration / 60)) minutes)"
            }.joined(separator: "\n"))
            """
        
        guard let url = URL(string: "https://timemachine.aryanrajmathur.workers.dev/gemini") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingGeminiTips = false
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String else {
                return
            }
            
            // Parse the text response into an array by splitting on new lines
            let parsedTips = text
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            DispatchQueue.main.async {
                self.geminiTips = parsedTips
                self.saveGeminiTipsToStorage()
            }
        }.resume()
    }
    
    private let geminiTipsKey = "geminiTips"

    func saveGeminiTipsToStorage() {
        UserDefaults.standard.set(geminiTips, forKey: geminiTipsKey)
    }

    func loadGeminiTipsFromStorage() {
        if let saved = UserDefaults.standard.stringArray(forKey: geminiTipsKey) {
            self.geminiTips = saved
        }
    }
    
    /// GEMINI SCENARIOS
    
    //private let geminiScenariosKey = "geminiScenarios"

    func fetchGeminiScenarios(email: String, apiKey: String) {
        isLoadingGeminiScenarios = true
        loadLogFromServer()

        let prompt = """
        IN BULLET POINTS JUST RESPONSE NO "Okay let's do it!" just the response. Based on the given time log, generate:
        You are a fortune teller predicting someone's future. Predict their Family, happiness out of 10, etc. Make the responses formatted as a paragraph without any other text such as titles. In the prompt, when I reference you, I mean the person who you are judging.
        - A short paragraph (5-6 sentences) about your present self.
        - Another paragraph about your future self *if you keep your current habits*.
        - Another paragraph about your future self *if your habits worsen*.
        - Another paragraph about your future self *if your habits improve*.

        Time log:
        \(log.map {
            "\($0.category): \($0.start.formatted(date: .abbreviated, time: .shortened)) - \($0.end.formatted(date: .abbreviated, time: .shortened)) (\(Int($0.duration / 60)) minutes)"
        }.joined(separator: "\n"))
        """

        guard let url = URL(string: "https://timemachine.aryanrajmathur.workers.dev/gemini") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingGeminiScenarios = false
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String else {
                return
            }

            let parsedScenarios = text
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            DispatchQueue.main.async {
                self.geminiScenarios = parsedScenarios
                self.saveGeminiScenariosToStorage()
            }
        }.resume()
    }
    
    private let geminiScenariosKey = "geminiScenarios"

    func saveGeminiScenariosToStorage() {
        UserDefaults.standard.set(geminiScenarios, forKey: geminiScenariosKey)
    }

    func loadGeminiScenariosFromStorage() {
        if let saved = UserDefaults.standard.stringArray(forKey: geminiScenariosKey) {
            self.geminiScenarios = saved
        }
    }

}
