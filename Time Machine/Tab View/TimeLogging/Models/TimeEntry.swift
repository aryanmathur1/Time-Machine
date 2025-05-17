//
//  TimeEntry.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import Foundation

struct TimeEntry: Identifiable, Codable {
    let id: UUID
    let category: String
    let start: Date
    let end: Date

    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    init(id: UUID = UUID(), category: String, start: Date, end: Date) {
        self.id = id
        self.category = category
        self.start = start
        self.end = end
    }
}
