//
//  Brand.swift
//  HerPlaybook
//
//  Redesigned design system — premium sports × clean mobile product
//

import SwiftUI

// MARK: - Color System
enum Brand {

    // Core palette
    static let ink        = Color(hex: "#0A0A0A")       // dominant dark surface
    static let spark      = Color(hex: "#FF3D87")       // primary accent — CTAs, streaks, progress
    static let rose       = Color(hex: "#FF85B3")       // secondary accent — labels, tags, overlines
    static let blush      = Color(hex: "#FFE4EF")       // light tint — light-mode backgrounds only
    static let surface    = Color(.systemBackground)    // adaptive — white / near-black
    static let raised     = Color(.secondarySystemBackground) // adaptive — slightly elevated

    // Semantic
    static let success    = Color(hex: "#22C55E")
    static let warning    = Color(hex: "#F59E0B")

    // Text hierarchy (on dark surfaces)
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let textTertiary  = Color.white.opacity(0.35)

    // MARK: - Typography Scale
    // Display — hero titles, onboarding
    static let displayFont   = Font.system(size: 34, weight: .bold, design: .default)
    // Title — screen titles
    static let titleFont     = Font.system(size: 24, weight: .bold, design: .default)
    // Headline — card titles, section titles
    static let headlineFont  = Font.system(size: 17, weight: .semibold, design: .default)
    // Body — main readable content
    static let bodyFont      = Font.system(size: 15, weight: .regular, design: .default)
    // Label — supporting info, metadata
    static let labelFont     = Font.system(size: 13, weight: .medium, design: .default)
    // Caption — overlines, timestamps, tags
    static let captionFont   = Font.system(size: 11, weight: .semibold, design: .default)

    // MARK: - Spacing (4pt grid)
    static let spacing4:  CGFloat = 4
    static let spacing8:  CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    static let spacing40: CGFloat = 40

    // MARK: - Corner Radius System
    static let radiusSM:   CGFloat = 4    // tags, badges
    static let radiusMD:   CGFloat = 10   // icon containers
    static let radiusLG:   CGFloat = 16   // rows, input fields
    static let radiusXL:   CGFloat = 22   // cards
    static let radiusFull: CGFloat = 100  // pills, chips

    // MARK: - Card backgrounds (on dark ink surface)
    static let cardFill      = Color.white.opacity(0.07)
    static let cardBorder    = Color.white.opacity(0.10)
    static let cardFillHover = Color.white.opacity(0.11)
}

// MARK: - Hex Color Init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
struct HPCardModifier: ViewModifier {
    var padding: CGFloat = Brand.spacing16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Brand.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                    .stroke(Brand.cardBorder, lineWidth: 0.5)
            )
    }
}

struct HPPrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Brand.spacing16)
            .background(Brand.ink)
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous))
    }
}

struct HPAccentButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Brand.spacing16)
            .background(Brand.spark)
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous))
    }
}

extension View {
    func hpCard(padding: CGFloat = Brand.spacing16) -> some View {
        modifier(HPCardModifier(padding: padding))
    }
    func hpPrimaryButton() -> some View {
        modifier(HPPrimaryButtonModifier())
    }
    func hpAccentButton() -> some View {
        modifier(HPAccentButtonModifier())
    }
}

// MARK: - Overline Label
struct OverlineLabel: View {
    let text: String
    var color: Color = Brand.rose

    var body: some View {
        Text(text.uppercased())
            .font(Brand.captionFont)
            .foregroundStyle(color)
            .kerning(0.8)
    }
}
