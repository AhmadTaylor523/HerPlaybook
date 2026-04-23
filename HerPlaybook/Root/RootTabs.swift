//
//  RootTabs.swift
//  HerPlaybook
//
//  Floating pill tab bar — sits above content, not in system toolbar.
//

import SwiftUI

struct RootTabs: View {
    @State private var selected: Tab = .home

    enum Tab: Int, CaseIterable {
        case home, basics, watch, iq

        var label: String {
            switch self {
            case .home:   return "Home"
            case .basics: return "Basics"
            case .watch:  return "Watch"
            case .iq:     return "IQ"
            }
        }

        var icon: String {
            switch self {
            case .home:   return "house.fill"
            case .basics: return "book.pages.fill"
            case .watch:  return "play.rectangle.fill"
            case .iq:     return "bolt.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content — use ZStack so tab switches don't re-create nav stacks
            Group {
                HomeView().opacity(selected == .home ? 1 : 0)
                BasicsHubView().opacity(selected == .basics ? 1 : 0)
                WatchHubView().opacity(selected == .watch ? 1 : 0)
                IQHubView().opacity(selected == .iq ? 1 : 0)
            }

            // Floating tab bar
            floatingTabBar
                .padding(.horizontal, Brand.spacing20)
                .padding(.bottom, Brand.spacing20)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selected = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: selected == tab ? 16 : 14, weight: .semibold))
                            .foregroundStyle(selected == tab ? Brand.spark : Brand.textTertiary)
                            .scaleEffect(selected == tab ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selected)

                        Text(tab.label)
                            .font(.system(size: 10, weight: selected == tab ? .semibold : .medium))
                            .foregroundStyle(selected == tab ? .white : Brand.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Brand.spacing10)
                    .background(
                        RoundedRectangle(cornerRadius: Brand.radiusLG, style: .continuous)
                            .fill(selected == tab ? Brand.cardFillHover : Color.clear)
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selected)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Brand.spacing8)
        .padding(.vertical, Brand.spacing6)
        .background(
            RoundedRectangle(cornerRadius: Brand.radiusXL + 4, style: .continuous)
                .fill(Color(hex: "#1A1A1A"))
                .overlay(
                    RoundedRectangle(cornerRadius: Brand.radiusXL + 4, style: .continuous)
                        .stroke(Brand.cardBorder, lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 8)
    }
}