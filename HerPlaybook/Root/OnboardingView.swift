//
//  OnboardingView.swift
//  HerPlaybook
//
//  Redesigned: dark surface, stronger visual hierarchy,
//  more confident brand voice.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("learningProfile") private var learningProfileRaw = LearningProfile.brandNew.rawValue

    @State private var selected: LearningProfile = .brandNew
    @State private var appeared = false

    var body: some View {
        ZStack {
            Brand.ink.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                // Brand mark
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Brand.spark.opacity(0.15))
                            .frame(width: 64, height: 64)
                        Image("PlaybookLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
                .padding(.bottom, Brand.spacing24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.easeOut(duration: 0.5), value: appeared)

                // Hero copy
                VStack(alignment: .leading, spacing: Brand.spacing8) {
                    Text("HerPlaybook")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Football — finally explained for you.")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(Brand.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, Brand.spacing32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

                // Profile picker
                VStack(alignment: .leading, spacing: Brand.spacing10) {
                    Text("WHERE ARE YOU STARTING FROM?")
                        .font(Brand.captionFont)
                        .foregroundStyle(Brand.textTertiary)
                        .kerning(0.8)
                        .padding(.bottom, Brand.spacing4)

                    ForEach(Array(LearningProfile.allCases.enumerated()), id: \.element.id) { i, profile in
                        OnboardingProfileCard(
                            profile: profile,
                            isSelected: selected == profile,
                            action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { selected = profile } }
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.easeOut(duration: 0.45).delay(0.2 + Double(i) * 0.07), value: appeared)
                    }
                }
                .padding(.bottom, Brand.spacing32)

                // CTA
                Button {
                    learningProfileRaw = selected.rawValue
                    hasOnboarded = true
                } label: {
                    HStack {
                        Text("Get Started")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, Brand.spacing16)
                    .padding(.horizontal, Brand.spacing20)
                    .background(Brand.spark)
                    .clipShape(RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous))
                }
                .buttonStyle(.plain)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.easeOut(duration: 0.4).delay(0.45), value: appeared)

                Spacer()
            }
            .padding(.horizontal, Brand.spacing24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appeared = true
            }
        }
    }
}

// MARK: - Profile Card
private struct OnboardingProfileCard: View {
    let profile: LearningProfile
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Brand.spacing14) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Brand.spark : Brand.cardFill)
                        .frame(width: 24, height: 24)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(profile.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : Brand.textSecondary)
                    Text(profile.subtitle)
                        .font(Brand.labelFont)
                        .foregroundStyle(Brand.textTertiary)
                }

                Spacer()
            }
            .padding(Brand.spacing16)
            .background(isSelected ? Brand.spark.opacity(0.12) : Brand.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous)
                    .stroke(isSelected ? Brand.spark.opacity(0.35) : Brand.cardBorder, lineWidth: 0.5)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}