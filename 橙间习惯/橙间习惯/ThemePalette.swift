import SwiftUI

struct ThemePalette {
    let colorScheme: ColorScheme

    private var isDark: Bool { colorScheme == .dark }

    var background: Color {
        isDark ? Color(hex: "0B1014") : Color(hex: "F9F8F5")
    }

    var orbColors: (Color, Color, Color) {
        if isDark {
            return (
                Color(hex: "FF9B76"),
                Color(hex: "63C9B7"),
                Color(hex: "90AAFF")
            )
        }
        return (
            Color(hex: "FFB49F"),
            Color(hex: "8FD5C3"),
            Color(hex: "C2D9FF")
        )
    }

    var primaryInk: Color {
        isDark ? Color(hex: "FCE9DD") : Color(hex: "4C2A1C")
    }

    var secondaryInk: Color {
        let base = isDark ? Color(hex: "E8CBB3") : Color(hex: "6E4733")
        return base.opacity(isDark ? 0.88 : 0.85)
    }

    var placeholderInk: Color {
        let base = isDark ? Color(hex: "DAB08B") : Color(hex: "A8724A")
        return base.opacity(isDark ? 0.45 : 0.45)
    }

    var tertiaryInk: Color {
        isDark ? Color(hex: "DAB08B") : Color(hex: "6E4733").opacity(0.78)
    }

    var calendarAccent: Color {
        isDark ? Color(hex: "FFAE7B") : Color(hex: "FF8A5B")
    }

    var calendarSelectedFill: LinearGradient {
        let light = [
            Color(hex: "FF8866"),
            Color(hex: "FFA552"),
            Color(hex: "FFC95C")
        ]
        let dark = [
            Color(hex: "FF9D6F"),
            Color(hex: "FFBE73"),
            Color(hex: "FFD97B")
        ]
        return LinearGradient(
            colors: isDark ? dark : light,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func calendarDayTextColor(isWithinMonth: Bool) -> Color {
        if isWithinMonth {
            return primaryInk
        }
        return secondaryInk.opacity(isDark ? 0.4 : 0.3)
    }

    var calendarSelectedShadow: Color {
        calendarAccent.opacity(isDark ? 0.45 : 0.35)
    }

    var primaryButtonFill: LinearGradient {
        calendarSelectedFill
    }

    var primaryButtonShadow: Color {
        isDark ? Color(hex: "FFD27F").opacity(0.38) : Color.black.opacity(0.25)
    }

    var cardTintGradient: LinearGradient {
        if isDark {
            return LinearGradient(
                colors: [
                    Color(red: 60.0 / 255.0, green: 49.0 / 255.0, blue: 42.0 / 255.0).opacity(0.42),
                    Color(red: 28.0 / 255.0, green: 26.0 / 255.0, blue: 25.0 / 255.0).opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.97, blue: 0.92),
                Color(red: 1.0, green: 0.93, blue: 0.82),
                Color(red: 0.99, green: 0.88, blue: 0.76)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var cardHighlightGradient: LinearGradient {
        if isDark {
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                Color.white.opacity(0.45),
                Color.white.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func cardFill(isActive: Bool) -> Color {
        if isDark {
            let base = Color(red: 32.0 / 255.0, green: 29.0 / 255.0, blue: 26.0 / 255.0)
            return base.opacity(isActive ? 0.9 : 0.78)
        }
        let active = Color(red: 1.0, green: 0.95, blue: 0.88)
        let inactive = Color(red: 0.98, green: 0.9, blue: 0.84)
        return isActive ? active : inactive
    }

    func cardShadow(isActive: Bool) -> Color {
        if isDark {
            return Color.black.opacity(isActive ? 0.5 : 0.32)
        }
        return Color.black.opacity(isActive ? 0.12 : 0.06)
    }

    var inactiveOverlay: Color {
        if isDark {
            return Color.black.opacity(0.28)
        }
        return Color.black.opacity(0.04)
    }

    func cardStrokeOpacity(isActive: Bool) -> Double {
        if isDark {
            return isActive ? 0.24 : 0.16
        }
        return isActive ? 0.48 : 0.34
    }

    func cardTintOpacity(isActive: Bool) -> Double {
        if isDark {
            return isActive ? 0.55 : 0.35
        }
        return isActive ? 0.35 : 0.25
    }

    func cardHighlightBlendOpacity(isActive: Bool) -> Double {
        if isDark {
            return isActive ? 0.45 : 0.28
        }
        return isActive ? 0.42 : 0.28
    }

    var detailPanelFill: Color {
        if isDark {
            return Color(red: 28.0 / 255.0, green: 26.0 / 255.0, blue: 25.0 / 255.0).opacity(0.82)
        }
        return Color(red: 0.99, green: 0.97, blue: 0.93)
    }

    var detailPanelStroke: Color {
        if isDark {
            return Color.white.opacity(0.16)
        }
        return Color(red: 1.0, green: 0.84, blue: 0.68).opacity(0.38)
    }

    var detailCardFill: Color {
        if isDark {
            return Color(red: 32.0 / 255.0, green: 29.0 / 255.0, blue: 28.0 / 255.0).opacity(0.86)
        }
        return Color(red: 1.0, green: 0.98, blue: 0.95)
    }

    var detailCardStroke: Color {
        if isDark {
            return Color.white.opacity(0.14)
        }
        return Color(red: 1.0, green: 0.85, blue: 0.72).opacity(0.34)
    }

    var emptyCardFill: Color {
        if isDark {
            return Color(red: 30.0 / 255.0, green: 27.0 / 255.0, blue: 26.0 / 255.0).opacity(0.82)
        }
        return Color(red: 0.99, green: 0.95, blue: 0.91)
    }

    var splashBackground: Color {
        isDark ? Color(hex: "0A0D11") : Color(hex: "F9F8F5")
    }

    var splashTitle: Color {
        isDark ? Color(hex: "FCE0CC") : primaryInk
    }

    var splashSubtitle: Color {
        isDark ? Color(hex: "E5C7AF") : Color(hex: "845131").opacity(0.75)
    }

    var feedbackBackground: Color {
        isDark ? Color.white.opacity(0.18) : Color.black.opacity(0.8)
    }

    var feedbackText: Color {
        isDark ? primaryInk : Color.white
    }

    var feedbackShadow: Color {
        isDark ? Color.black.opacity(0.45) : Color.black.opacity(0.18)
    }

    var toolbarButtonBackground: Color {
        isDark ? Color.white.opacity(0.12) : Color.white.opacity(0.6)
    }

    var calendarCellFill: Color {
        isDark ? Color.white.opacity(0.04) : Color.white.opacity(0.3)
    }

    var calendarCellInactiveFill: Color {
        isDark ? Color.white.opacity(0.02) : Color.white.opacity(0.15)
    }

    var calendarCellShadow: Color {
        isDark ? Color.black.opacity(0.45) : Color.black.opacity(0.06)
    }

    var entryShadow: Color {
        isDark ? Color.black.opacity(0.48) : Color.black.opacity(0.08)
    }
}
