//
//  GeminiTipsView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

struct GeminiTipsView: View {
    @ObservedObject var viewModel: TimeLoggerViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var rotation: Double = 0
    @State private var isExpanded: Bool = false
    
    @AppStorage("user_email") private var email: String = ""
    @AppStorage("user_apiKey") private var apiKey: String = ""
    
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with refresh button
            HStack {
                Text("🧠 Productivity Tips")
                    .font(.title3.bold())
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()

                Button {
                    refreshTips()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .rotationEffect(.degrees(rotation))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoadingGeminiTips)
            }

            if viewModel.isLoadingGeminiTips {
                loadingAnimation()
            } else if viewModel.geminiTips.isEmpty {
                Text("No tips available. Try generating tips!")
                    .foregroundColor(.secondary)
            } else {
                ForEach(displayedTips, id: \.self) { tip in
                    formattedTip(tip)
                        .font(.body)
                        .foregroundColor(Color.black )
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Text(isExpanded ? "See Less" : "See More")
                        .font(.subheadline.bold())
                        .foregroundColor(Color.accentColor)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white.opacity(0.6))
        )
        .padding(.horizontal)
        .onChange(of: viewModel.isLoadingGeminiTips) { isLoading in
            if isLoading {
                startSpinning()
            } else {
                stopSpinning()
            }
        }
        .onAppear {
            viewModel.loadGeminiTipsFromStorage()
        }
    }

    private var displayedTips: [String] {
        isExpanded ? viewModel.geminiTips : Array(viewModel.geminiTips.prefix(1))
    }

    private func refreshTips() {
        startSpinning()
        viewModel.fetchGeminiTips(email: email, apiKey: apiKey)
    }
    
    private func startSpinning() {
        rotation = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            rotation += 5
            if rotation >= 360 { rotation -= 360 }
        }
    }
    
    private func stopSpinning() {
        timer?.invalidate()
        timer = nil
        rotation = 0
    }

    @ViewBuilder
    private func loadingAnimation() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "lightbulb.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
                .rotationEffect(.degrees(rotation))
                //.animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
                .onAppear {
                    rotation = 360
                }

            Text("Generating smart tips...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private func formattedTip(_ tip: String) -> Text {
        let lines = tip.components(separatedBy: .newlines)
        var result = Text("")

        for (i, line) in lines.enumerated() {
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("* ") {
                // Bullet point
                let bulletContent = String(line.dropFirst(2))
                result = result + Text("• ") + parseInlineStyles(bulletContent) + Text("\n")
            } else {
                result = result + parseInlineStyles(line) + Text("\n")
            }
        }

        return result
    }

    private func parseInlineStyles(_ input: String) -> Text {
        var result = Text("")
        var current = input
        var isBold = false
        var isItalic = false

        while !current.isEmpty {
            if let boldRange = current.range(of: "**") {
                let prefix = String(current[..<boldRange.lowerBound])
                result = result + applyStyle(to: prefix, bold: isBold, italic: isItalic)
                current = String(current[boldRange.upperBound...])
                isBold.toggle()
            } else if let italicRange = current.range(of: "*") {
                let prefix = String(current[..<italicRange.lowerBound])
                result = result + applyStyle(to: prefix, bold: isBold, italic: isItalic)
                current = String(current[italicRange.upperBound...])
                isItalic.toggle()
            } else {
                result = result + applyStyle(to: current, bold: isBold, italic: isItalic)
                break
            }
        }

        return result
    }

    private func applyStyle(to text: String, bold: Bool, italic: Bool) -> Text {
        var styledText = Text(text)
        if bold && italic {
            styledText = styledText.bold().italic()
        } else if bold {
            styledText = styledText.bold()
        } else if italic {
            styledText = styledText.italic()
        }
        return styledText
    }

}
