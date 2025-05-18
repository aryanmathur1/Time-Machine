//
//  WheelPickerView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

struct WheelPickerView: View {
    
    @State private var config: WheelPicker.Config = .init(count: 11, multiplier: 10)
    @AppStorage("wheelPickerValueAge") private var storedValue: Double = 0
    @State private var value: CGFloat = 0

    var body: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text("\(Int(value))")
                        .font(.largeTitle.bold())
                        .contentTransition(.numericText(value: value))
                        .animation(.snappy, value: value)
                    
                    Text("y/o")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                }

                WheelPicker(config: config, value: $value)
                    .frame(height: 60)
            }
            .onAppear {
                value = CGFloat(storedValue)
            }
            .onChange(of: value) { newValue in
                storedValue = Double(newValue)
            }
        }
    }
}

#Preview {
    WheelPickerView()
}
