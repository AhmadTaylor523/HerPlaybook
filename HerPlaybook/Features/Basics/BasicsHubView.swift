//
//  BasicsHubView.swift
//  HerPlaybook
//
//  Redesigned to use shared HubComponents.
//  Private ExpandTile / sheetHeader / previewButton / primaryCTA removed.
//

import SwiftUI

struct BasicsHubView: View {
    @State private var path = NavigationPath()
    @State private var sheet: BasicsSheet? = nil
    @State private var glossaryDetent: PresentationDetent = .large

    enum BasicsSheet: Identifiable {
        case lessons, glossary
        var id: String { switch self { case .lessons: return "lessons"; case .glossary: return "glossary" } }
    }

    enum BasicsRoute: Hashable {
        case lesson(Lesson)
        case lessonList
        case term(Term)
        case glossarySearch(String)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Brand.ink.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Brand.spacing16) {

                        HubHeader(
                            title: "Football Basics",
                            subtitle: "Short lessons that make watching easy.",
                            goalText: "Learn one concept in under 5 minutes.",
                            goalIcon: "book.pages.fill"
                        )

                        ExpandTile(
                            title: "Start Basics Lessons",
                            subtitle: "3–5 min each · track your progress",
                            icon: "book.pages.fill",
                            onTap: { sheet = .lessons }
                        )

                        ExpandTile(
                            title: "Glossary",
                            subtitle: "Search any term while you watch",
                            icon: "text.book.closed.fill",
                            onTap: { sheet = .glossary }
                        )

                        TipPill(text: "Tip: use the Glossary during a live game.")

                        Spacer(minLength: Brand.spacing40)
                    }
                    .padding(.horizontal, Brand.spacing20)
                    .padding(.top, Brand.spacing10)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)

            .navigationDestination(for: BasicsRoute.self) { route in
                switch route {
                case .lesson(let lesson):   LessonDetailView(lesson: lesson)
                case .lessonList:           LessonListView(category: "Basics")
                case .term(let term):       TermDetailView(term: term)
                case .glossarySearch(let q): GlossaryView(initialSearch: q)
                }
            }

            .sheet(item: $sheet) { item in
                switch item {
                case .lessons:
                    BasicsLessonsSheet { route in dismissSheetAndNavigate(route) }
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Brand.ink)

                case .glossary:
                    BasicsGlossarySheet { route in dismissSheetAndNavigate(route) }
                        .presentationDetents([.large, .medium], selection: $glossaryDetent)
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Brand.ink)
                        .onAppear { glossaryDetent = .large }
                }
            }
        }
    }

    private func dismissSheetAndNavigate(_ route: BasicsRoute) {
        sheet = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            path.append(route)
        }
    }
}

// MARK: - Lessons Sheet
private struct BasicsLessonsSheet: View {
    let onRoute: (BasicsHubView.BasicsRoute) -> Void
    @State private var selectedTitle: String? = nil

    private let previews: [(title: String, time: String)] = [
        ("How the Game Works", "4:00"),
        ("Scoring 101", "3:00"),
        ("Common Penalties", "3:00"),
        ("Down & Distance", "4:00")
    ]

    private var isArmed: Bool { selectedTitle != nil }

    private var downAndDistanceLesson: Lesson? {
        SampleData.lessons.first { $0.title == "Down & Distance" }
    }

    private var goesToDetail: Bool {
        selectedTitle == "Down & Distance" && downAndDistanceLesson != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacing20) {
            SheetHeader(title: "Basics Lessons", subtitle: "Pick a lesson to begin.", icon: "book.pages.fill")
                .padding(.top, Brand.spacing8)

            VStack(alignment: .leading, spacing: Brand.spacing8) {
                OverlineLabel(text: "Lessons")
                ForEach(previews, id: \.title) { item in
                    SheetPreviewRow(
                        title: item.title,
                        trailing: item.time,
                        isSelected: selectedTitle == item.title
                    ) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                            selectedTitle = item.title
                        }
                    }
                }
            }

            Button {
                guard let selectedTitle else { return }
                if selectedTitle == "Down & Distance", let lesson = downAndDistanceLesson {
                    onRoute(.lesson(lesson))
                } else {
                    onRoute(.lessonList)
                }
            } label: {
                SheetCTA(
                    title: !isArmed ? "Start Lessons" : (goesToDetail ? "Start: Down & Distance" : "Go to Basics Lessons"),
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

// MARK: - Glossary Sheet
private struct BasicsGlossarySheet: View {
    let onRoute: (BasicsHubView.BasicsRoute) -> Void
    @State private var query: String = ""
    @State private var selectedTermTitle: String? = nil

    private let importantTerms = ["Blitz", "Down", "First Down", "Touchdown", "Field Goal", "Offsides"]

    private var filteredTerms: [String] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return importantTerms }
        return importantTerms.filter { $0.localizedCaseInsensitiveContains(q) }
    }

    private var target: String { (selectedTermTitle ?? query).trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isArmed: Bool { !target.isEmpty }
    private var blitzTerm: Term? { SampleData.terms.first { $0.title.lowercased() == "blitz" } }
    private var goesToBlitz: Bool { target.lowercased() == "blitz" && blitzTerm != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacing20) {
            SheetHeader(title: "Glossary", subtitle: "Search or tap a term.", icon: "text.book.closed.fill")
                .padding(.top, Brand.spacing8)

            // Inline search bar
            HStack(spacing: Brand.spacing10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Brand.textTertiary)
                    .font(.system(size: 14))
                TextField("Search terms…", text: $query)
                    .foregroundStyle(.white)
                    .tint(Brand.spark)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                if !query.isEmpty {
                    Button { query = ""; selectedTermTitle = nil } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Brand.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Brand.spacing14)
            .padding(.vertical, Brand.spacing12)
            .background(Brand.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous)
                    .stroke(Brand.cardBorder, lineWidth: 0.5)
            )

            VStack(alignment: .leading, spacing: Brand.spacing8) {
                OverlineLabel(text: "Key Terms")
                ForEach(filteredTerms, id: \.self) { termTitle in
                    SheetPreviewRow(title: termTitle, trailing: "", isSelected: selectedTermTitle == termTitle) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                            selectedTermTitle = termTitle
                            query = termTitle
                        }
                    }
                }
                if !query.isEmpty && filteredTerms.isEmpty {
                    Text("No matches — try a different term.")
                        .font(Brand.labelFont)
                        .foregroundStyle(Brand.textTertiary)
                        .padding(.top, Brand.spacing4)
                }
            }

            Button {
                guard isArmed else { return }
                if goesToBlitz, let term = blitzTerm { onRoute(.term(term)) }
                else { onRoute(.glossarySearch(target)) }
            } label: {
                SheetCTA(
                    title: !isArmed ? "Open Glossary" : (goesToBlitz ? "Open: Blitz" : "Open Glossary"),
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