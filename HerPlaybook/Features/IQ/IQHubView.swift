//
//  IQHubView.swift
//  HerPlaybook
//
//  Updated to use shared HubComponents.
//  QuizRunnerView extracted to QuizRunnerView.swift.
//

import SwiftUI

struct IQHubView: View {
    @State private var path = NavigationPath()
    @State private var sheet: IQSheet? = nil
    @State private var quizzesDetent: PresentationDetent = .large

    enum IQSheet: Identifiable {
        case miniQuizzes, daily
        var id: String { switch self { case .miniQuizzes: return "mini"; case .daily: return "daily" } }
    }

    enum IQRoute: Hashable {
        case quiz(Quiz)
        case quizList
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Brand.ink.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Brand.spacing16) {

                        HubHeader(
                            title: "Football IQ",
                            subtitle: "Fast reps that make terms stick.",
                            goalText: "Take one mini quiz to lock it in.",
                            goalIcon: "brain.head.profile"
                        )

                        ExpandTile(
                            title: "Mini Quizzes",
                            subtitle: "Quick checks · 1–2 minutes",
                            icon: "bolt.fill",
                            onTap: { sheet = .miniQuizzes }
                        )

                        ExpandTile(
                            title: "Daily IQ",
                            subtitle: "One question a day · build your streak",
                            icon: "calendar.badge.clock",
                            onTap: { sheet = .daily }
                        )

                        TipPill(text: "Tip: short quizzes beat cramming — do one, then stop.")

                        Spacer(minLength: Brand.spacing40)
                    }
                    .padding(.horizontal, Brand.spacing20)
                    .padding(.top, Brand.spacing10)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)

            .navigationDestination(for: IQRoute.self) { route in
                switch route {
                case .quiz(let quiz): QuizRunnerView(quiz: quiz)
                case .quizList:       QuizListView()
                }
            }

            .sheet(item: $sheet) { item in
                switch item {
                case .miniQuizzes:
                    MiniQuizzesSheet { route in dismissSheetAndNavigate(route) }
                        .presentationDetents([.large, .medium], selection: $quizzesDetent)
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Brand.ink)
                        .onAppear { quizzesDetent = .large }
                case .daily:
                    DailyIQSheet { route in dismissSheetAndNavigate(route) }
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Brand.ink)
                }
            }
        }
    }

    private func dismissSheetAndNavigate(_ route: IQRoute) {
        sheet = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { path.append(route) }
    }
}

// MARK: - Mini Quizzes Sheet
private struct MiniQuizzesSheet: View {
    let onRoute: (IQHubView.IQRoute) -> Void
    @State private var selectedQuizID: String? = nil

    private let quizzes = QuizBank.miniQuizzes
    private var selectedQuiz: Quiz? { quizzes.first { $0.id == selectedQuizID } }
    private var isArmed: Bool { selectedQuiz != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacing20) {
            SheetHeader(title: "Mini Quizzes", subtitle: "Pick one to begin.", icon: "bolt.fill")
                .padding(.top, Brand.spacing8)

            VStack(alignment: .leading, spacing: Brand.spacing8) {
                OverlineLabel(text: "Choose a Quiz")
                ForEach(quizzes) { q in
                    SheetPreviewRow(
                        title: q.title,
                        trailing: "\(q.questions.count) Q",
                        isSelected: selectedQuizID == q.id
                    ) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                            selectedQuizID = q.id
                        }
                    }
                }
            }

            Button {
                guard let quiz = selectedQuiz else { return }
                onRoute(.quiz(quiz))
            } label: {
                SheetCTA(
                    title: isArmed ? "Start: \(selectedQuiz!.title)" : "Start Quiz",
                    isArmed: isArmed
                )
            }
            .buttonStyle(.plain)
            .disabled(!isArmed)

            Spacer()
        }
        .padding(.horizontal, Brand.spacing20)
    }
}

// MARK: - Daily IQ Sheet
private struct DailyIQSheet: View {
    let onRoute: (IQHubView.IQRoute) -> Void
    private let daily = QuizBank.dailyIQ

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacing20) {
            SheetHeader(title: "Daily IQ", subtitle: "One question. No pressure.", icon: "calendar.badge.clock")
                .padding(.top, Brand.spacing8)

            VStack(alignment: .leading, spacing: Brand.spacing8) {
                OverlineLabel(text: "Today")
                SheetPreviewRow(title: daily.title, trailing: "1 Q", isSelected: true) {}
            }

            Button { onRoute(.quiz(daily)) } label: {
                SheetCTA(title: "Start Daily IQ", isArmed: true)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, Brand.spacing20)
    }
}

// MARK: - Quiz List (full list screen)
private struct QuizListView: View {
    var body: some View {
        ZStack {
            Brand.ink.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Brand.spacing12) {
                    Text("All Quizzes")
                        .font(Brand.titleFont)
                        .foregroundStyle(.white)
                        .padding(.top, Brand.spacing12)

                    ForEach(QuizBank.miniQuizzes) { q in
                        HStack(spacing: Brand.spacing12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: Brand.radiusMD, style: .continuous)
                                    .fill(Brand.spark.opacity(0.12))
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Brand.spark)
                            }
                            .frame(width: 38, height: 38)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(q.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("\(q.questions.count) questions")
                                    .font(Brand.labelFont)
                                    .foregroundStyle(Brand.textTertiary)
                            }
                            Spacer()
                        }
                        .padding(Brand.spacing14)
                        .background(Brand.cardFill)
                        .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                                .stroke(Brand.cardBorder, lineWidth: 0.5)
                        )
                    }
                    Spacer(minLength: Brand.spacing40)
                }
                .padding(.horizontal, Brand.spacing20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}