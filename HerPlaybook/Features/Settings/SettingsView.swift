//
//  SettingsView.swift
//  HerPlaybook
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = true
    @AppStorage("learningProfile") private var learningProfileRaw = LearningProfile.brandNew.rawValue
    @State private var showResetConfirm = false

    var profile: LearningProfile {
        LearningProfile(rawValue: learningProfileRaw) ?? .brandNew
    }

    var body: some View {
        ZStack {
            Brand.ink.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Brand.spacing24) {

                    // Profile summary
                    VStack(alignment: .leading, spacing: Brand.spacing4) {
                        Text("YOUR PROFILE")
                            .font(Brand.captionFont)
                            .foregroundStyle(Brand.textTertiary)
                            .kerning(0.8)
                            .padding(.bottom, Brand.spacing4)

                        HStack(spacing: Brand.spacing12) {
                            ZStack {
                                Circle()
                                    .fill(Brand.spark.opacity(0.15))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Brand.spark)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(profile.rawValue)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text(profile.subtitle)
                                    .font(Brand.labelFont)
                                    .foregroundStyle(Brand.textSecondary)
                            }
                        }
                        .padding(Brand.spacing16)
                        .background(Brand.cardFill)
                        .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                                .stroke(Brand.cardBorder, lineWidth: 0.5)
                        )
                    }

                    // Actions
                    VStack(alignment: .leading, spacing: Brand.spacing8) {
                        Text("OPTIONS")
                            .font(Brand.captionFont)
                            .foregroundStyle(Brand.textTertiary)
                            .kerning(0.8)
                            .padding(.bottom, Brand.spacing4)

                        Button {
                            hasOnboarded = false
                        } label: {
                            settingsRow(icon: "arrow.counterclockwise", title: "Redo Onboarding", subtitle: "Change your learning profile")
                        }
                        .buttonStyle(.plain)

                        Button {
                            showResetConfirm = true
                        } label: {
                            settingsRow(icon: "trash", title: "Reset Progress", subtitle: "Clears all lesson completions and streak", isDestructive: true)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: Brand.spacing40)
                }
                .padding(.horizontal, Brand.spacing20)
                .padding(.top, Brand.spacing16)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .confirmationDialog(
            "Reset all progress?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset Progress", role: .destructive) {
                UserProgress.resetAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear all completed lessons and your streak. This cannot be undone.")
        }
    }

    private func settingsRow(icon: String, title: String, subtitle: String, isDestructive: Bool = false) -> some View {
        HStack(spacing: Brand.spacing12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isDestructive ? Color.red.opacity(0.12) : Brand.cardFill)
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isDestructive ? Color.red.opacity(0.8) : Brand.textSecondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isDestructive ? Color.red.opacity(0.85) : .white)
                Text(subtitle)
                    .font(Brand.labelFont)
                    .foregroundStyle(Brand.textTertiary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Brand.textTertiary)
        }
        .padding(Brand.spacing14)
        .background(Brand.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                .stroke(isDestructive ? Color.red.opacity(0.2) : Brand.cardBorder, lineWidth: 0.5)
        )
    }
}