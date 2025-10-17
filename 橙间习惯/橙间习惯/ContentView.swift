//
//  ContentView.swift
//  橙间习惯
//
//  Created by 林凡滨 on 2025/10/12.
//

import SwiftUI
import Foundation

enum Typography {
    static let lineHeightMultiple: CGFloat = 1.8
    static let paragraphSpacing: CGFloat = 32

    static func bodyAttributed(_ string: String) -> AttributedString {
        let mutable = NSMutableAttributedString(string: string)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = lineHeightMultiple
        paragraph.paragraphSpacing = paragraphSpacing
        mutable.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: mutable.length))
        return AttributedString(mutable)
    }
}

enum LayoutSpacing {
    static let titleBottom: CGFloat = 32
    static let helperBottom: CGFloat = 24
    static let inputToAction: CGFloat = 24
    static let inputPadding: CGFloat = 16
}

struct ContentView: View {
    @EnvironmentObject private var journalStore: JournalStore
    @Environment(\.colorScheme) private var colorScheme

    private let prompts = RitualLibrary.prompts

    @State private var entries: [RitualPrompt.ID: String]
    @State private var animateOrbs = false
    @State private var currentIndex = 0
    @State private var transitionDirection: SlideDirection = .forward
    @FocusState private var focusedPrompt: RitualPrompt.ID?
    @State private var journalDate = Date()
    @State private var hasLoadedExistingEntry = false
    @State private var dragOffset: CGFloat = 0
    @State private var showOverwriteAlert = false
    @State private var hasSavedToday = false
    @State private var feedbackMessage: String?
    @State private var feedbackMessageID = UUID()

    private var palette: ThemePalette {
        ThemePalette(colorScheme: colorScheme)
    }

    private static func blankEntries() -> [RitualPrompt.ID: String] {
        Dictionary(uniqueKeysWithValues: RitualLibrary.prompts.lazy.map { ($0.id, "") })
    }

    private enum SlideDirection {
        case forward
        case backward
    }

    init() {
        _entries = State(initialValue: Self.blankEntries())
    }

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            GeometryReader { proxy in
                let size = proxy.size
                let (warmOrb, calmOrb, glowOrb) = palette.orbColors

                ZStack {
                    orb(color: warmOrb, blur: 80, scale: animateOrbs ? 1.08 : 0.94)
                        .frame(width: size.width * 0.52, height: size.width * 0.52)
                        .offset(x: size.width * -0.38, y: size.height * -0.30)

                    orb(color: calmOrb, blur: 95, scale: animateOrbs ? 0.92 : 1.06)
                        .frame(width: size.width * 0.46, height: size.width * 0.46)
                        .offset(x: size.width * 0.42, y: size.height * -0.34)

                    orb(color: glowOrb, blur: 130, scale: animateOrbs ? 1.12 : 0.96)
                        .frame(width: size.width * 0.78, height: size.width * 0.78)
                        .offset(x: size.width * 0.02, y: size.height * 0.48)
                }
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animateOrbs)
                .scaleEffect(1)
                .opacity(1)
                .onAppear { animateOrbs = true }
            }
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                promptStage
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                Spacer(minLength: 0)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedPrompt = nil
        }
        .onAppear(perform: loadEntryIfNeeded)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if focusedPrompt == nil {
                confirmationButton
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
            }
        }
        .overlay(alignment: .top) {
            if let message = feedbackMessage {
                Text(message)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.feedbackText)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(palette.feedbackBackground)
                            .shadow(color: palette.feedbackShadow, radius: 18, x: 0, y: 12)
                    )
                    .padding(.top, 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var promptStage: some View {
        GeometryReader { proxy in
            ZStack {
                stageCard(for: prompts[currentIndex], index: currentIndex, isActive: true)
                    .id(prompts[currentIndex].id)
                    .offset(y: dragOffset)
                    .transition(transition(for: transitionDirection))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
        .clipped()
        .animation(.easeInOut(duration: 0.55), value: currentIndex)
        .gesture(stageDragGesture)
    }

    private var confirmationButton: some View {
        Button(action: handleSaveTapped) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .overlay {
                    Text("确认保存")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.3))
                }
        }
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.25), radius: 18, x: 0, y: 10)
        .buttonStyle(.plain)
        .alert("今天已经写过一次了", isPresented: $showOverwriteAlert) {
            Button("替换", role: .destructive) {
                performSave(isOverwrite: true)
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("确定要代替掉吗？")
        }
    }

    private func stageCard(for prompt: RitualPrompt, index: Int, isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(prompt.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryInk)
            }
            .padding(.bottom, LayoutSpacing.titleBottom)

            Text(Typography.bodyAttributed(prompt.guidance))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(palette.secondaryInk)
                .padding(.bottom, LayoutSpacing.helperBottom)

            let currentText = entries[prompt.id] ?? ""
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(palette.cardFill(isActive: isActive))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                palette.cardHighlightGradient.opacity(palette.cardStrokeOpacity(isActive: isActive)),
                                lineWidth: 1
                            )
                    )

                TextEditor(text: binding(for: prompt.id))
                    .padding(LayoutSpacing.inputPadding)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 220, alignment: .topLeading)
                    .background(Color.clear)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.primaryInk)
                    .cornerRadius(24)
                    .disabled(!isActive)
                    .allowsHitTesting(isActive)
                    .focused($focusedPrompt, equals: prompt.id)

                if currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(Typography.bodyAttributed(prompt.placeholder))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.placeholderInk)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, LayoutSpacing.inputPadding)
                        .padding(.vertical, LayoutSpacing.inputPadding)
                        .allowsHitTesting(false)
                }
            }
            .padding(.bottom, LayoutSpacing.inputToAction)

            Spacer(minLength: 0)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(glassBackground(isActive: isActive))
        .shadow(color: palette.cardShadow(isActive: isActive), radius: isActive ? 20 : 14, x: 0, y: isActive ? 18 : 12)
        .overlay {
            if !isActive {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(palette.inactiveOverlay)
                    .allowsHitTesting(false)
            }
        }
    }

    private func handleSaveTapped() {
        focusedPrompt = nil
        let existing = journalStore.entry(for: journalDate)
        if hasSavedToday || existing != nil {
            showOverwriteAlert = true
        } else {
            performSave(isOverwrite: false)
        }
    }

    private func performSave(isOverwrite: Bool) {
        let cleaned = trimmedEntries()
        focusedPrompt = nil
        journalStore.saveEntry(for: journalDate, responses: cleaned)
        hasSavedToday = true
        hasLoadedExistingEntry = false
        showOverwriteAlert = false
        dragOffset = 0
        withAnimation(.spring(response: 0.7, dampingFraction: 0.9)) {
            transitionDirection = .forward
            currentIndex = 0
        }
        entries = Self.blankEntries()
        showFeedback(isOverwrite ? "替换成功" : "保存成功")
    }

    private func showFeedback(_ message: String) {
        let id = UUID()
        feedbackMessageID = id
        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
            feedbackMessage = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            guard feedbackMessageID == id else { return }
            withAnimation(.easeInOut(duration: 0.35)) {
                feedbackMessage = nil
            }
        }
    }

    private func glassBackground(isActive: Bool) -> some View {
        let tint = palette.cardTintGradient
        let highlight = palette.cardHighlightGradient

        return RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(palette.cardFill(isActive: isActive))
            .overlay(
                tint
                    .opacity(palette.cardTintOpacity(isActive: isActive))
                    .blur(radius: 18)
                    .mask(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                    )
            )
            .overlay(
                highlight
                    .opacity(palette.cardHighlightBlendOpacity(isActive: isActive))
                    .blendMode(.plusLighter)
                    .mask(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(highlight.opacity(palette.cardStrokeOpacity(isActive: isActive)), lineWidth: 1.1)
            )
    }

    private func advanceStage() {
        guard currentIndex < prompts.count else { return }
        focusedPrompt = nil
        guard currentIndex < prompts.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.55)) {
            transitionDirection = .forward
            currentIndex += 1
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

    private func transition(for direction: SlideDirection) -> AnyTransition {
        switch direction {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            )
        }
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
        guard !hasLoadedExistingEntry else { return }
        if journalStore.entry(for: journalDate) != nil {
            hasSavedToday = true
            currentIndex = 0
            dragOffset = 0
            focusedPrompt = nil
            entries = Self.blankEntries()
        } else {
            hasSavedToday = false
            currentIndex = 0
            entries = Self.blankEntries()
        }
        hasLoadedExistingEntry = true
    }

    private var stageDragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                guard focusedPrompt == nil else {
                    dragOffset = 0
                    return
                }
                let translation = value.translation.height
                dragOffset = translation
            }
            .onEnded { value in
                guard focusedPrompt == nil else {
                    dragOffset = 0
                    return
                }
                let translation = value.translation.height
                let threshold: CGFloat = 110

                if translation <= -threshold {
                    transitionDirection = .forward
                    withAnimation(.easeInOut(duration: 0.45)) {
                        dragOffset = 0
                    }
                    advanceStage()
                } else if translation >= threshold, currentIndex > 0 {
                    transitionDirection = .backward
                    withAnimation(.easeInOut(duration: 0.45)) {
                        dragOffset = 0
                    }
                    retreatStage()
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func binding(for id: RitualPrompt.ID) -> Binding<String> {
        Binding(
            get: { entries[id] ?? "" },
            set: { entries[id] = $0 }
        )
    }

    private func orb(color: Color, blur: CGFloat, scale: CGFloat) -> some View {
        Circle()
            .fill(color.opacity(colorScheme == .dark ? 0.5 : 0.65))
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
