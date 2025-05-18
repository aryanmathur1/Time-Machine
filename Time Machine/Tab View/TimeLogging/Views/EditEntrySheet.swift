//
//  EditEntrySheet.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

struct EditEntrySheet: View {
    var entry: TimeEntry
    var categories: [String]
    var onSave: (TimeEntry) -> Void
    var onCancel: () -> Void

    @State private var selectedCategory: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var customCategory: String = ""

    var body: some View {
        NavigationView {
            Form {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(.menu) // or .wheel, .inline based on your UI

                // Show TextField if "Other" is selected
                if selectedCategory == "Other" {
                    TextField("Enter custom category", text: $customCategory)
                }

                DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)

                DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finalCategory = selectedCategory == "Other" ? customCategory : selectedCategory
                        let updatedEntry = TimeEntry(
                            id: entry.id,
                            category: finalCategory,
                            start: startDate,
                            end: endDate
                        )
                        onSave(updatedEntry)
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
            .onAppear {
                selectedCategory = entry.category
                startDate = entry.start
                endDate = entry.end
            }
        }
    }
}

