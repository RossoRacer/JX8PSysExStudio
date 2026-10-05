//
//  ModeSelectionView.swift
//  JX8PSysExStudio
//
//  The first screen the user sees: a choice between the app's two
//  functions.
//

import SwiftUI

struct ModeSelectionView: View {
    let onSelect: (AppMode) -> Void

    var body: some View {
        VStack(spacing: 36) {
            VStack(spacing: 6) {
                Text("JX-8P SysEx Studio")
                    .font(.largeTitle.bold())
                Text("Tools for the Roland JX-8P")
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 30)

            HStack(spacing: 24) {
                ModeCard(
                    icon: "dice",
                    title: "Random Bank",
                    subtitle: "Generate 32 brand-new JX-8P patches from random numbers and save them as one factory-format SysEx bank.",
                    action: { onSelect(.randomBank) }
                )
                ModeCard(
                    icon: "arrow.triangle.merge",
                    title: "Morph Presets",
                    subtitle: "Drag and drop two JX-8P/JX-10/MKS-70 patches, blend them together, and save the result as a new patch.",
                    action: { onSelect(.morph) }
                )
            }

            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.accentColor)
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .frame(width: 230, height: 210)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondary.opacity(isHovering ? 0.14 : 0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
