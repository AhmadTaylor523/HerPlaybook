//
//  HomeView.swift
//  HerPlaybook
//
//  Redesigned: dark premium surface, clear hierarchy,
//  reduced density, reactive progress.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("learningProfile") private var learningProfileRaw = LearningProfile.brandNew.rawValue

    var profile: LearningProfile {
        LearningProfile(rawValue: learningProfileRaw) ?? .brandNew
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Brand.ink.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Brand.spacing20) {
                        headerRow
                        ContinueLearningBanner()
                        StreakProgressRow()
                        startHereSection
                        termOfDaySection
                        Spacer(minLength: Brand.spacing40)
                    }
                    .padding(.horizontal, Brand.spacing20)
                    .padding(.top, Brand.spacing12)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header
    private var headerRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingText)
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.textTertiary)
                    .kerning(0.5)
                Text("HerPlaybook")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            NavigationLink { SettingsView() } label: {
                ZStack {
                    Circle()
                        .fill(Brand.cardFill)
                        .frame(width: 38, height: 38)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Brand.textSecondary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "GOOD MORNING"
        case 12..<17: return "GOOD AFTERNOON"
        default: return "GOOD EVENING"
        }
    }

    // MARK: - Start Here
    private var startHereSection: some View {
        VStack(alignment: .leading, spacing: Brand.spacing12) {
            SectionLabel("Start Here")

            // Featured primary card — Basics
            NavigationLink { BasicsHubView() } label: {
                FeaturedActionCard(
                    title: "Learn the Basics",
                    subtitle: "Downs, scoring, penalties, positions",
                    icon: "book.pages.fill",
                    isPrimary: true
                )
            }
            .buttonStyle(.plain)

            // Secondary grid
            HStack(spacing: Brand.spacing10) {
                NavigationLink { WatchHubView() } label: {
                    SecondaryActionCard(
                        title: "Watch & Learn",
                        subtitle: "Live clips",
                        icon: "play.rectangle.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink { IQHubView() } label: {
                    SecondaryActionCard(
                        title: "Football IQ",
                        subtitle: "Quiz + glossary",
                        icon: "bolt.fill"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Term of Day
    private var termOfDaySection: some View {
        Group {
            if let term = SampleData.terms.first(where: { $0.id == "blitz" }) ?? SampleData.terms.first {
                VStack(alignment: .leading, spacing: Brand.spacing12) {
                    SectionLabel("Term of the Day")
                    TermOfDayCard(term: term)
                }
            }
        }
    }
}

// MARK: - Section Label
private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(Brand.captionFont)
            .foregroundStyle(Brand.textTertiary)
            .kerning(0.8)
    }
}

// MARK: - Continue Learning Banner
struct ContinueLearningBanner: View {
    var nextLesson: Lesson? {
        let all = SampleData.lessons.filter { $0.category == "Basics" }
        return all.first { !UserProgress.isLessonCompleted($0.id) } ?? all.first
    }

    var body: some View {
        if let lesson = nextLesson {
            NavigationLink { LessonDetailView(lesson: lesson) } label: {
                HStack(spacing: Brand.spacing14) {
                    VStack(alignment: .leading, spacing: 4) {
                        OverlineLabel(text: "Continue")
                        Text(lesson.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("\(lesson.minutes) min · \(lesson.subtitle)")
                            .font(Brand.labelFont)
                            .foregroundStyle(Brand.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Brand.spark)
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
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
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Streak + Progress Row
struct StreakProgressRow: View {
    @State private var refresh = false

    var body: some View {
        let progress = UserProgress.lessonCompletionRate(category: "Basics")
        let streak = UserProgress.streakDays()

        HStack(spacing: Brand.spacing10) {
            // Streak
            VStack(alignment: .leading, spacing: 6) {
                OverlineLabel(text: "Streak")
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(streak)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    Text("days")
                        .font(Brand.labelFont)
                        .foregroundStyle(Brand.textSecondary)
                }
                Text(streak > 0 ? "Keep going 🔥" : "Start today")
                    .font(Brand.captionFont)
                    .foregroundStyle(streak > 0 ? Brand.rose : Brand.textTertiary)
                    .kerning(0.3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Brand.spacing16)
            .background(Brand.spark.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                    .stroke(Brand.spark.opacity(0.15), lineWidth: 0.5)
            )

            // Progress ring
            VStack(spacing: 6) {
                OverlineLabel(text: "Basics")
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(Brand.spark, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.6), value: progress)

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 60, height: 60)
            }
            .frame(maxWidth: .infinity)
            .padding(Brand.spacing16)
            .background(Brand.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                    .stroke(Brand.cardBorder, lineWidth: 0.5)
            )
        }
        .onAppear { refresh.toggle() }
    }
}

// MARK: - Featured Action Card (full width, primary)
private struct FeaturedActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isPrimary: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: Brand.radiusMD, style: .continuous)
                    .fill(isPrimary ? .white.opacity(0.15) : Brand.spark.opacity(0.12))
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(Brand.labelFont)
                    .foregroundStyle(Brand.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Brand.textTertiary)
        }
        .padding(Brand.spacing16)
        .background(isPrimary ? Brand.spark.opacity(0.12) : Brand.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                .stroke(isPrimary ? Brand.spark.opacity(0.2) : Brand.cardBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Secondary Action Card (half width)
private struct SecondaryActionCard: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacing10) {
            ZStack {
                RoundedRectangle(cornerRadius: Brand.radiusMD, style: .continuous)
                    .fill(Brand.spark.opacity(0.12))
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Brand.spark)
            }
            .frame(width: 38, height: 38)

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(subtitle)
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.textSecondary)
                    .lineLimit(1)
                    .kerning(0.3)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .padding(Brand.spacing14)
        .background(Brand.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                .stroke(Brand.cardBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Term of Day Card
struct TermOfDayCard: View {
    let term: Term

    var body: some View {
        NavigationLink { TermDetailView(term: term) } label: {
            VStack(alignment: .leading, spacing: Brand.spacing10) {
                HStack {
                    OverlineLabel(text: "Term of the Day")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Brand.textTertiary)
                }

                Text(term.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Text(term.shortDefinition)
                    .font(Brand.bodyFont)
                    .foregroundStyle(Brand.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                if !term.tags.isEmpty {
                    HStack(spacing: Brand.spacing6) {
                        ForEach(term.tags.prefix(3), id: \.self) { tag in
                            Text(tag.capitalized)
                                .font(Brand.captionFont)
                                .foregroundStyle(Brand.rose)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Brand.spark.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
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
        .buttonStyle(.plain)
    }
}

// MARK: - Missing spacing token