//
//  WatchLearnView.swift
//  HerPlaybook
//
//  WatchHubView updated to use shared HubComponents.
//  VideoDetailView unchanged (AVKit logic preserved).
//

import SwiftUI
import AVKit
import WebKit

fileprivate enum WatchRoute: Hashable {
    case clip(Clip)
    case savedList
}

// MARK: - Watch Hub
struct WatchHubView: View {
    @State private var path = NavigationPath()
    @State private var sheet: WatchSheet? = nil
    @State private var whatDetent: PresentationDetent = .large

    enum WatchSheet: Identifiable {
        case whatJustHappened, saved
        var id: String { switch self { case .whatJustHappened: return "what"; case .saved: return "saved" } }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Brand.ink.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Brand.spacing16) {

                        HubHeader(
                            title: "Watch",
                            subtitle: "Quick clips that explain the play.",
                            goalText: "Tap a clip and get the explanation fast.",
                            goalIcon: "sparkles.tv.fill"
                        )

                        ExpandTile(
                            title: "What just happened?",
                            subtitle: "Short clips that explain the play",
                            icon: "play.rectangle.fill",
                            onTap: { sheet = .whatJustHappened }
                        )

                        ExpandTile(
                            title: "Saved",
                            subtitle: "Your bookmarked clips",
                            icon: "bookmark.fill",
                            onTap: { sheet = .saved }
                        )

                        TipPill(text: "Tip: "What just happened?" is best during live games.")

                        Spacer(minLength: Brand.spacing40)
                    }
                    .padding(.horizontal, Brand.spacing20)
                    .padding(.top, Brand.spacing10)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)

            .navigationDestination(for: WatchRoute.self) { route in
                switch route {
                case .clip(let clip):  VideoDetailView(clip: clip)
                case .savedList:       SavedClipsView()
                }
            }

            .sheet(item: $sheet) { item in
                switch item {
                case .whatJustHappened:
                    WhatJustHappenedSheet { route in dismissSheetAndNavigate(route) }
                        .presentationDetents([.large, .medium], selection: $whatDetent)
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Brand.ink)
                        .onAppear { whatDetent = .large }
                case .saved:
                    SavedSheet { route in dismissSheetAndNavigate(route) }
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Brand.ink)
                }
            }
        }
    }

    private func dismissSheetAndNavigate(_ route: WatchRoute) {
        sheet = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { path.append(route) }
    }
}

// MARK: - What Just Happened Sheet
private struct WhatJustHappenedSheet: View {
    let onRoute: (WatchRoute) -> Void
    @State private var selectedID: String? = nil

    private let clips = WatchClips.whatJustHappened
    private var selectedClip: Clip? { clips.first { $0.id == selectedID } }
    private var isArmed: Bool { selectedClip != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacing20) {
            SheetHeader(title: "What just happened?", subtitle: "Pick a clip to watch.", icon: "play.rectangle.fill")
                .padding(.top, Brand.spacing8)

            VStack(alignment: .leading, spacing: Brand.spacing8) {
                OverlineLabel(text: "Clips")
                ForEach(clips) { c in
                    SheetPreviewRow(title: c.title, trailing: c.duration, isSelected: selectedID == c.id) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) { selectedID = c.id }
                    }
                }
            }

            Button {
                guard let clip = selectedClip else { return }
                onRoute(.clip(clip))
            } label: {
                SheetCTA(title: isArmed ? "Play: \(selectedClip!.title)" : "Play Clip", isArmed: isArmed)
            }
            .buttonStyle(.plain)
            .disabled(!isArmed)

            Spacer()
        }
        .padding(.horizontal, Brand.spacing20)
    }
}

// MARK: - Saved Sheet
private struct SavedSheet: View {
    let onRoute: (WatchRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacing20) {
            SheetHeader(title: "Saved", subtitle: "Your bookmarked clips.", icon: "bookmark.fill")
                .padding(.top, Brand.spacing8)

            VStack(alignment: .leading, spacing: Brand.spacing8) {
                OverlineLabel(text: "Coming Soon")
                Text("Bookmark clips while you watch and they'll show up here.")
                    .font(Brand.bodyFont)
                    .foregroundStyle(Brand.textSecondary)
            }
            .padding(Brand.spacing16)
            .background(Brand.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                    .stroke(Brand.cardBorder, lineWidth: 0.5)
            )

            Button { onRoute(.savedList) } label: {
                SheetCTA(title: "Open Saved", isArmed: true)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, Brand.spacing20)
    }
}

// MARK: - Video Detail
private struct VideoDetailView: View {
    let clip: Clip

    var body: some View {
        ZStack {
            Brand.ink.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Brand.spacing16) {

                    VStack(alignment: .leading, spacing: Brand.spacing6) {
                        OverlineLabel(text: clip.duration)
                        Text(clip.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        Text(clip.subtitle)
                            .font(Brand.bodyFont)
                            .foregroundStyle(Brand.textSecondary)
                    }
                    .padding(.top, Brand.spacing12)

                    // Video player
                    Group {
                        if case .local(let name, let ext) = clip.source,
                           let url = Bundle.main.url(forResource: name, withExtension: ext) {
                            VideoPlayer(player: AVPlayer(url: url))
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
                        } else if case .web(let urlString) = clip.source,
                                  let url = URL(string: urlString) {
                            WebVideoView(url: url)
                                .frame(height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                                    .fill(Brand.cardFill)
                                    .frame(height: 160)
                                VStack(spacing: Brand.spacing8) {
                                    Image(systemName: "video.slash")
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundStyle(Brand.textTertiary)
                                    Text("Video unavailable")
                                        .font(Brand.labelFont)
                                        .foregroundStyle(Brand.textTertiary)
                                }
                            }
                        }
                    }

                    // Explanation card
                    VStack(alignment: .leading, spacing: Brand.spacing10) {
                        OverlineLabel(text: "What you're seeing")
                        Text(clip.explanation)
                            .font(Brand.bodyFont)
                            .foregroundStyle(Brand.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(3)
                    }
                    .padding(Brand.spacing16)
                    .background(Brand.cardFill)
                    .clipShape(RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Brand.radiusXL, style: .continuous)
                            .stroke(Brand.cardBorder, lineWidth: 0.5)
                    )

                    Spacer(minLength: Brand.spacing40)
                }
                .padding(.horizontal, Brand.spacing20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Saved Clips View
private struct SavedClipsView: View {
    var body: some View {
        ZStack {
            Brand.ink.ignoresSafeArea()
            VStack(spacing: Brand.spacing16) {
                Image(systemName: "bookmark.slash")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Brand.textTertiary)
                Text("No saved clips yet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                Text("Bookmark clips while you watch and they'll appear here.")
                    .font(Brand.bodyFont)
                    .foregroundStyle(Brand.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Brand.spacing40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Web video wrapper
private struct WebVideoView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView()
        web.scrollView.isScrollEnabled = false
        web.load(URLRequest(url: url))
        return web
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Clip models (unchanged)
fileprivate struct Clip: Identifiable, Hashable {
    enum Source: Hashable {
        case local(name: String, ext: String)
        case web(url: String)
    }
    let id: String
    let title: String
    let subtitle: String
    let duration: String
    let explanation: String
    let source: Source
}

fileprivate enum WatchClips {
    static let whatJustHappened: [Clip] = [
        Clip(id: "w1", title: "Big Run", subtitle: "Why it broke open", duration: "0:20",
             explanation: "A big run happens when the offense creates a clear lane with strong blocking, and the runner hits the gap before the defense can fill it.",
             source: .local(name: "RPReplay_Final1729980166", ext: "MOV")),
        Clip(id: "w2", title: "Blitz Pressure", subtitle: "Why the QB had no time", duration: "0:20",
             explanation: "A blitz sends extra defenders to rush the QB. It creates fast pressure but can leave fewer players in coverage.",
             source: .local(name: "RPReplay_Final1729980250", ext: "MOV")),
        Clip(id: "w3", title: "Down & Distance", subtitle: "Why the playcall changed", duration: "0:20",
             explanation: "Down and distance shapes every play call. 3rd and long almost always means a pass; short yardage keeps both options open.",
             source: .local(name: "RPReplay_Final1731430616", ext: "mov"))
    ]
}