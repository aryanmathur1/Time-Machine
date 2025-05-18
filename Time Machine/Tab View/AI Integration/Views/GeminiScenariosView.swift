//
//  GeminiScenariosView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//


//
//  GeminiScenariosView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/18/25.
//

import SwiftUI

struct GeminiScenariosView: View {
    @ObservedObject var viewModel: TimeLoggerViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var rotation: Double = 0
    @State private var isExpanded: Bool = false
    
    @AppStorage("user_email") private var email: String = ""
    @AppStorage("user_apiKey") private var apiKey: String = ""
    
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🔮 Travel into the Future")
                    .font(.title3.bold())
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()

                Button {
                    refreshScenarios()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .rotationEffect(.degrees(rotation))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoadingGeminiScenarios)
            }

            if viewModel.isLoadingGeminiScenarios {
                loadingAnimation()
            } else if viewModel.geminiScenarios.isEmpty {
                Text("No scenarios available. Try generating them!")
                    .foregroundColor(.secondary)
            } else {
                ForEach(displayedScenarios, id: \.self) { scenario in
                    formattedScenario(scenario)
                        .font(.body)
                        .foregroundColor(Color.black)
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
        .onChange(of: viewModel.isLoadingGeminiScenarios) { isLoading in
            if isLoading {
                startSpinning()
            } else {
                stopSpinning()
            }
        }
        .onAppear {
            viewModel.loadGeminiScenariosFromStorage()
        }
    }

    private var displayedScenarios: [String] {
        isExpanded ? viewModel.geminiScenarios : Array(viewModel.geminiScenarios.prefix(1))
    }

    private func refreshScenarios() {
        startSpinning()
        viewModel.loadLogFromServer()
        viewModel.fetchGeminiScenarios(email: email, apiKey: apiKey)
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
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    rotation = 360
                }

            Text("Imagining your future...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private func formattedScenario(_ scenario: String) -> Text {
        let paragraphs = scenario.components(separatedBy: .newlines)
        var result = Text("")

        for para in paragraphs {
            result = result + parseInlineStyles(para) + Text("\n\n")
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
