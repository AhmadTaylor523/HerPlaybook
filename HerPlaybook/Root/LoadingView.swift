//
//  LoadingView.swift
//  HerPlaybook
//

import SwiftUI

struct LoadingView: View {
    @State private var bob = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            Brand.ink.ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Brand.spark.opacity(0.12))
                        .frame(width: 110, height: 110)

                    Image("PlaybookLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                }
                .scaleEffect(bob ? 1.04 : 0.96)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: bob
                )

                Text("HerPlaybook")
                    .font(Brand.titleFont)
                    .foregroundStyle(.white)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.4).delay(0.2), value: appeared)
            }
        }
        .onAppear {
            bob = true
            appeared = true
        }
    }
}
