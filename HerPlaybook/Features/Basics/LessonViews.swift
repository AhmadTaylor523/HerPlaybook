//
//  LessonViews.swift
//  HerPlaybook
//
//  Combines LessonListView, LessonDetailView, and LessonRow
//  Redesigned: dark surface, animated completion, better reading layout
//

import SwiftUI

// MARK: - Lesson List
struct LessonListView: View {
    let category: String

    var lessons: [Lesson] {
        SampleData.lessons.filter { $0.category == category }
    }

    var completedCount: Int {
        lessons.filter { UserProgress.isLessonCompleted($0.id) }.count
    }

    var body: some View {
        ZStack {
            Brand.ink.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Brand.spacing16) {

                    // Header + progress
                    VStack(alignment: .leading, spacing: Brand.spacing8) {
                        Text(category)
                            .font(Brand.titleFont)
                            .foregroundStyle(.white)

                        HStack(spacing: Brand.spacing8) {
                            // Mini progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Brand.cardFill)
                                        .frame(height: 4)
                                    Capsule()
                                        .fill(Brand.spark)
                                        .frame(
                                            width: lessons.isEmpty ? 0 : geo.size.width * CGFloat(completedCount) / CGFloat(lessons.count),
                                            height: 4
                                        )
                                        .animation(.easeInOut(duration: 0.5), value: completedCount)
                                }
                            }
                            .frame(height: 4)

                            Text("\(completedCount)/\(lessons.count)")
                                .font(Brand.captionFont)
                                .foregroundStyle(Brand.textTertiary)
                                .fixedSize()
                        }
                    }
                    .padding(.top, Brand.spacing12)

                    // Lesson rows
                    ForEach(lessons) { lesson in
                        NavigationLink {
                            LessonDetailView(lesson: lesson)
                        } label: {
                            LessonRow(lesson: lesson)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: Brand.spacing40)
                }
                .padding(.horizontal, Brand.spacing20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Lesson Row
struct LessonRow: View {
    let lesson: Lesson
    @State private var completed = false

    var body: some View {
        HStack(spacing: Brand.spacing14) {
            // Status icon
            ZStack {
                RoundedRectangle(cornerRadius: Brand.radiusMD, style: .continuous)
                    .fill(completed ? Brand.spark.opacity(0.15) : Brand.cardFill)
                Image(systemName: completed ? "checkmark.circle.fill" : "play.circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(completed ? Brand.spark : Brand.textSecondary)
            }
            .frame(width: 46, height: 46)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: completed)

            VStack(alignment: .leading, spacing: 3) {
                Text(lesson.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(completed ? Brand.textSecondary : .white)
                Text("\(lesson.minutes) min · \(lesson.subtitle)")
                    .font(Brand.labelFont)
                    .foregroundStyle(Brand.textTertiary)
                    .lineLimit(1)
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
                .stroke(completed ? Brand.spark.opacity(0.15) : Brand.cardBorder, lineWidth: 0.5)
        )
        .onAppear { completed = UserProgress.isLessonCompleted(lesson.id) }
    }
}

// MARK: - Lesson Detail
struct LessonDetailView: View {
    let lesson: Lesson
    @State private var completed = false
    @State private var showCompletionPulse = false

    var relatedTerms: [Term] {
        SampleData.terms.filter { lesson.relatedTermIDs.contains($0.id) }
    }

    var body: some View {
        ZStack {
            Brand.ink.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Brand.spacing16) {

                    // Hero header
                    VStack(alignment: .leading, spacing: Brand.spacing8) {
                        HStack(spacing: Brand.spacing8) {
                            Text(lesson.category.uppercased())
                                .font(Brand.captionFont)
                                .foregroundStyle(Brand.rose)
                                .kerning(0.8)
                            Text("·")
                                .foregroundStyle(Brand.textTertiary)
                            Text("\(lesson.minutes) MIN")
                                .font(Brand.captionFont)
                                .foregroundStyle(Brand.textTertiary)
                                .kerning(0.5)
                        }

                        Text(lesson.title)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(lesson.subtitle)
                            .font(Brand.bodyFont)
                            .foregroundStyle(Brand.textSecondary)
                    }
                    .padding(.top, Brand.spacing12)

                    // Sections
                    ForEach(lesson.sections) { sec in
                        LessonSectionCard(section: sec)
                    }

                    // Related terms
                    if !relatedTerms.isEmpty {
                        VStack(alignment: .leading, spacing: Brand.spacing10) {
                            OverlineLabel(text: "Related Terms")
                                .padding(.top, Brand.spacing4)

                            ForEach(relatedTerms) { term in
                                NavigationLink { TermDetailView(term: term) } label: {
                                    RelatedTermRow(term: term)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Completion button
                    completionButton
                        .padding(.top, Brand.spacing8)

                    Spacer(minLength: Brand.spacing40)
                }
                .padding(.horizontal, Brand.spacing20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { completed = UserProgress.isLessonCompleted(lesson.id) }
    }

    private var completionButton: some View {
        Button {
            let next = !completed
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                completed = next
                if next { showCompletionPulse = true }
            }
            UserProgress.setLessonCompleted(lesson.id, completed: next)
            if next {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showCompletionPulse = false
                }
            }
        } label: {
            HStack {
                Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16, weight: .semibold))
                Text(completed ? "Completed" : "Mark as Completed")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                if showCompletionPulse {
                    Text("🎉")
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundStyle(completed ? Brand.spark : .white)
            .padding(.vertical, Brand.spacing16)
            .padding(.horizontal, Brand.spacing20)
            .background(completed ? Brand.spark.opacity(0.12) : Brand.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous)
                    .stroke(completed ? Brand.spark.opacity(0.3) : Brand.cardBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Lesson Section Card
private struct LessonSectionCard: View {
    let section: LessonSection

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacing8) {
            Text(section.heading)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            Text(section.body)
                .font(Brand.bodyFont)
                .foregroundStyle(Brand.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .padding(Brand.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Brand.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                .stroke(Brand.cardBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Related Term Row
private struct RelatedTermRow: View {
    let term: Term

    var body: some View {
        HStack(spacing: Brand.spacing12) {
            ZStack {
                RoundedRectangle(cornerRadius: Brand.radiusMD, style: .continuous)
                    .fill(Brand.spark.opacity(0.1))
                Image(systemName: "doc.text")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Brand.rose)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(term.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text(term.shortDefinition)
                    .font(Brand.labelFont)
                    .foregroundStyle(Brand.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Brand.textTertiary)
        }
        .padding(Brand.spacing12)
        .background(Brand.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous)
                .stroke(Brand.cardBorder, lineWidth: 0.5)
        )
    }
}