//
//  HubComponents.swift
//  HerPlaybook
//
//  Single source of truth for the hub pattern components.
//  Previously copy-pasted across BasicsHubView, IQHubView, WatchLearnView.
//

import SwiftUI

// MARK: - Expand Tile
// The primary tappable surface on each Hub screen. Opens a sheet.
struct ExpandTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Brand.spacing14) {
                iconContainer
                textStack
                Spacer()
                chevron
            }
            .padding(Brand.spacing16)
            .background(Brand.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                    .stroke(Brand.cardBorder, lineWidth: 0.5)
            )
            .scaleEffect(pressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: pressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                self.pressed = pressing
            }
        }, perform: {})
    }

    private var iconContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Brand.radiusMD, style: .continuous)
                .fill(Brand.spark.opacity(0.15))
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Brand.spark)
        }
        .frame(width: 44, height: 44)
    }

    private var textStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(Brand.labelFont)
                .foregroundStyle(Brand.textSecondary)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Brand.textTertiary)
    }
}

// MARK: - Hub Header
// Consistent header for all three hub screens.
struct HubHeader: View {
    let title: String
    let subtitle: String
    let goalText: String
    let goalIcon: String

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacing12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Brand.titleFont)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(Brand.labelFont)
                    .foregroundStyle(Brand.textSecondary)
            }

            HStack(spacing: Brand.spacing12) {
                Image(systemName: goalIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Brand.spark)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's goal")
                        .font(Brand.captionFont)
                        .foregroundStyle(Brand.rose)
                        .kerning(0.6)
                    Text(goalText)
                        .font(Brand.labelFont)
                        .foregroundStyle(Brand.textSecondary)
                }
                Spacer()
            }
            .padding(Brand.spacing14)
            .background(Brand.spark.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous)
                    .stroke(Brand.spark.opacity(0.15), lineWidth: 0.5)
            )
        }
        .padding(.top, Brand.spacing12)
    }
}

// MARK: - Tip Pill
struct TipPill: View {
    let text: String

    var body: some View {
        HStack(spacing: Brand.spacing8) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Brand.spark)
            Text(text)
                .font(Brand.labelFont)
                .foregroundStyle(Brand.textSecondary)
            Spacer()
        }
        .padding(.horizontal, Brand.spacing14)
        .padding(.vertical, Brand.spacing10)
        .background(Brand.spark.opacity(0.06))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Brand.spark.opacity(0.12), lineWidth: 0.5)
        )
        .padding(.top, Brand.spacing4)
    }
}

// MARK: - Sheet Header
struct SheetHeader: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: Brand.spacing12) {
            ZStack {
                RoundedRectangle(cornerRadius: Brand.radiusMD + 4, style: .continuous)
                    .fill(Brand.spark.opacity(0.15))
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Brand.spark)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(Brand.labelFont)
                    .foregroundStyle(Brand.textSecondary)
            }
            Spacer()
        }
    }
}

// MARK: - Preview Row (inside sheets)
struct SheetPreviewRow: View {
    let title: String
    let trailing: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Brand.textSecondary)
                Spacer()
                if !trailing.isEmpty {
                    Text(trailing)
                        .font(Brand.captionFont)
                        .foregroundStyle(isSelected ? Brand.rose : Brand.textTertiary)
                        .kerning(0.4)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? Brand.spark : Brand.textTertiary)
            }
            .padding(.vertical, Brand.spacing10)
            .padding(.horizontal, Brand.spacing12)
            .background(
                RoundedRectangle(cornerRadius: Brand.radiusMD + 4, style: .continuous)
                    .fill(isSelected ? Brand.spark.opacity(0.15) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Brand.radiusMD + 4, style: .continuous)
                    .stroke(isSelected ? Brand.spark.opacity(0.3) : Color.clear, lineWidth: 0.5)
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.85), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Primary CTA (armed / disarmed state)
struct SheetCTA: View {
    let title: String
    let isArmed: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
            Spacer()
            Image(systemName: "arrow.right")
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.vertical, Brand.spacing16)
        .padding(.horizontal, Brand.spacing16)
        .background(
            RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous)
                .fill(isArmed ? Brand.spark : Color.white.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous)
                .stroke(isArmed ? Brand.spark.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 0.5)
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isArmed)
    }
}

// MARK: - Missing spacing token (used above)