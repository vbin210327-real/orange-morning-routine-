//
//  ContentView.swift
//  橙间习惯
//
//  Created by 林凡滨 on 2025/10/12.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var journalStore: JournalStore
    private let prompts = RitualLibrary.prompts

    @State private var entries: [RitualPrompt.ID: String]
    @State private var animateOrbs = false
    @State private var currentIndex = 0
    @State private var showSummary = false
    @State private var transitionDirection: SlideDirection = .forward
    @FocusState private var focusedPrompt: RitualPrompt.ID?
    @State private var journalDate = Date()
    @State private var hasLoadedExistingEntry = false
    @State private var shouldAutoloadExistingEntry = true

    private enum SlideDirection {
        case forward
        case backward
    }

    init() {
        let initial = Dictionary(uniqueKeysWithValues: prompts.lazy.map { ($0.id, "") })
        _entries = State(initialValue: initial)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FFECD1"), Color(hex: "FFD6A5"), Color(hex: "FFC2E1")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GeometryReader { proxy in
                let size = proxy.size

                ZStack {
                    orb(color: Color(hex: "FFB49F"), blur: 80, scale: animateOrbs ? 1.08 : 0.94)
                        .frame(width: size.width * 0.52, height: size.width * 0.52)
                        .offset(x: size.width * -0.38, y: size.height * -0.30)

                    orb(color: Color(hex: "8FD5C3"), blur: 95, scale: animateOrbs ? 0.92 : 1.06)
                        .frame(width: size.width * 0.46, height: size.width * 0.46)
                        .offset(x: size.width * 0.42, y: size.height * -0.34)

                    orb(color: Color(hex: "C2D9FF"), blur: 130, scale: animateOrbs ? 1.12 : 0.96)
                        .frame(width: size.width * 0.78, height: size.width * 0.78)
                        .offset(x: size.width * 0.02, y: size.height * 0.48)
                }
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animateOrbs)
                .scaleEffect(showSummary ? 0.96 : 1)
                .opacity(showSummary ? 0.78 : 1)
                .animation(.easeInOut(duration: 0.8), value: showSummary)
                .onAppear { animateOrbs = true }
            }
            .allowsHitTesting(false)

            VStack(spacing: 24) {
                Group {
                    if showSummary {
                        summaryView
                    } else {
                        promptStage
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if showSummary {
                    summaryControls
                } else {
                    navigationControls
                }

                bottomProgress
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedPrompt = nil
        }
        .onAppear(perform: loadEntryIfNeeded)
    }

    private var bottomProgress: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ForEach(prompts.indices, id: \.self) { index in
                    Capsule()
                        .fill(stepColor(for: index))
                        .frame(height: 6)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentIndex)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSummary)
                }
            }

            if showSummary {
                Text("完成度 \(Int(progress * 100))% · 今日能量值 \(energyValue)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "6E4733").opacity(0.75))
            } else {
                Text("写下感受后，轻触「下一幕」，让故事继续播放。")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "6E4733").opacity(0.75))
            }
        }
    }

    private func stepColor(for index: Int) -> Color {
        if showSummary || index < currentIndex {
            return Color(hex: "FF8A5B")
        } else if index == currentIndex {
            return Color(hex: "3D7D59")
        } else {
            return Color.white.opacity(0.6)
        }
    }

    private var promptStage: some View {
        ZStack {
            stageCard(for: prompts[currentIndex], index: currentIndex)
                .id(prompts[currentIndex].id)
                .transition(transition(for: transitionDirection))
        }
        .animation(.easeInOut(duration: 0.55), value: currentIndex)
    }

    private func stageCard(for prompt: RitualPrompt, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Scene \(index + 1)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "845131").opacity(0.75))
                    .textCase(.uppercase)
                    .tracking(5)

                Text(prompt.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "4C2A1C"))
            }

            Text(prompt.guidance)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "6E4733").opacity(0.85))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.92))
                    .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color(hex: "FFB078").opacity(0.65), lineWidth: 1.3)
                    )

                TextEditor(text: binding(for: prompt.id))
                    .padding(20)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 220, alignment: .topLeading)
                    .background(Color.clear)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(hex: "4C2A1C"))
                    .cornerRadius(24)
                    .focused($focusedPrompt, equals: prompt.id)

                if (entries[prompt.id] ?? "").isEmpty {
                    Text(prompt.placeholder)
                        .padding(24)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "A8724A").opacity(0.45))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.white.opacity(0.86))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
    }

    private var navigationControls: some View {
        HStack(spacing: 18) {
            if currentIndex > 0 {
                Button(action: retreatStage) {
                    Label("上一幕", systemImage: "arrow.left")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.55), in: Capsule())
                        .foregroundColor(Color(hex: "4C2A1C"))
                }
                .buttonStyle(.plain)
            } else {
                Capsule()
                    .fill(Color.white.opacity(0.0))
                    .frame(width: 120, height: 48)
                    .accessibilityHidden(true)
            }

            Spacer()

            Button(action: advanceStage) {
                Text(currentIndex == prompts.count - 1 ? "完成 · 终幕" : "下一幕")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .padding(.horizontal, 36)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: canAdvance ? [Color(hex: "FF8866"), Color(hex: "FFA552"), Color(hex: "FFC95C")] : [Color.white.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(canAdvance ? Color.white : Color(hex: "A67A5B").opacity(0.7))
                    .clipShape(Capsule())
                    .shadow(color: canAdvance ? Color(hex: "FF8A5B").opacity(0.4) : Color.clear, radius: 20, x: 0, y: 12)
            }
            .disabled(!canAdvance)
            .buttonStyle(.plain)
        }
    }

    private var summaryView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("今日能量航图")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "845131"))

                    Text("完成度 \(Int(progress * 100))%，能量值 \(energyValue)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "3D7D59"))
                        .shadow(color: Color(hex: "3D7D59").opacity(0.3), radius: 12, x: 0, y: 10)

                    Text("愿这些文字成为你今天的底色。若想进一步雕琢，随时回到任意一幕。")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "6E4733").opacity(0.8))
                        .padding(.horizontal, 12)
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1.2)
                )

                ForEach(Array(prompts.enumerated()), id: \.element) { index, prompt in
                    summaryCard(for: prompt, index: index)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func summaryCard(for prompt: RitualPrompt, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("幕 \(index + 1) · \(prompt.title)")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "4C2A1C"))

            Text(entries[prompt.id]?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ?
                 entries[prompt.id]!.trimmingCharacters(in: .whitespacesAndNewlines) :
                    "还没有写下文字，可以随时回到这一幕补全。")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "6E4733").opacity(0.85))
                .lineSpacing(6)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
    }

    private var summaryControls: some View {
        VStack(spacing: 16) {
            Button(action: replayJourney) {
                Text("回放仪式，从第一幕再看一遍")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .padding(.horizontal, 36)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "FF8866"), Color(hex: "FFA552"), Color(hex: "FFC95C")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "FF8A5B").opacity(0.45), radius: 22, x: 0, y: 14)
            }
            .buttonStyle(.plain)

            Button(action: resetJourney) {
                Text("开启全新仪式")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 26)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.75), in: Capsule())
                    .foregroundColor(Color(hex: "4C2A1C"))
            }
            .buttonStyle(.plain)
        }
    }

    private func advanceStage() {
        guard currentIndex < prompts.count else { return }
        focusedPrompt = nil
        if currentIndex == prompts.count - 1 {
            let cleaned = trimmedEntries()
            journalStore.saveEntry(for: journalDate, responses: cleaned)
            shouldAutoloadExistingEntry = true
            hasLoadedExistingEntry = false
            withAnimation(.spring(response: 0.7, dampingFraction: 0.9)) {
                showSummary = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.55)) {
                transitionDirection = .forward
                currentIndex += 1
            }
        }
    }

    private func retreatStage() {
        guard currentIndex > 0 else { return }
        focusedPrompt = nil
        withAnimation(.easeInOut(duration: 0.55)) {
            transitionDirection = .backward
            currentIndex -= 1
        }
    }

    private func replayJourney() {
        focusedPrompt = nil
        withAnimation(.spring(response: 0.7, dampingFraction: 0.9)) {
            showSummary = false
            transitionDirection = .forward
            currentIndex = 0
        }
    }

    private func resetJourney() {
        focusedPrompt = nil
        withAnimation(.spring(response: 0.8, dampingFraction: 0.85)) {
            entries = Dictionary(uniqueKeysWithValues: prompts.map { ($0.id, "") })
            currentIndex = 0
            showSummary = false
            transitionDirection = .forward
            journalDate = Date()
        }
        hasLoadedExistingEntry = false
        shouldAutoloadExistingEntry = false
    }

    private func transition(for direction: SlideDirection) -> AnyTransition {
        switch direction {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }

    private var canAdvance: Bool {
        guard !showSummary else { return false }
        let prompt = prompts[currentIndex]
        return hasContent(for: prompt.id)
    }

    private func hasContent(for id: RitualPrompt.ID) -> Bool {
        let text = entries[id]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text.count >= 1
    }

    private func trimmedEntries() -> [String: String] {
        var cleaned: [String: String] = [:]
        for prompt in prompts {
            let value = entries[prompt.id]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            cleaned[prompt.id] = value
        }
        return cleaned
    }

    private func loadEntryIfNeeded() {
        guard shouldAutoloadExistingEntry else { return }
        guard !hasLoadedExistingEntry else { return }
        if let existing = journalStore.entry(for: journalDate) {
            entries = prompts.reduce(into: [String: String]()) { partialResult, prompt in
                partialResult[prompt.id] = existing.responses[prompt.id] ?? ""
            }
            if prompts.allSatisfy({ (existing.responses[$0.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).count > 0 }) {
                currentIndex = 0
                showSummary = false
            }
        }
        hasLoadedExistingEntry = true
    }

    private var completedCount: Int {
        prompts.filter { hasContent(for: $0.id) && (entries[$0.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).count > 3 }.count
    }

    private var progress: Double {
        guard !prompts.isEmpty else { return 0 }
        return Double(completedCount) / Double(prompts.count)
    }

    private var energyValue: Int {
        min(100, 45 + completedCount * 14)
    }

    private func binding(for id: RitualPrompt.ID) -> Binding<String> {
        Binding(
            get: { entries[id] ?? "" },
            set: { entries[id] = $0 }
        )
    }

    private func orb(color: Color, blur: CGFloat, scale: CGFloat) -> some View {
        Circle()
            .fill(color.opacity(0.65))
            .blur(radius: blur)
            .scaleEffect(scale)
            .blendMode(.plusLighter)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(JournalStore())
}
