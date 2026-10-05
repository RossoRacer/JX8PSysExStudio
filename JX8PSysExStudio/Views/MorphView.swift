//
//  MorphView.swift
//  JX8PSysExStudio
//

import SwiftUI

struct MorphView: View {
    let onBack: () -> Void

    @State private var slotA: PatchSlot?
    @State private var slotB: PatchSlot?
    @State private var amount: Double = 0.5
    @State private var statusMessage: String?
    @State private var isError = false

    var body: some View {
        VStack(spacing: 22) {
            HeaderBar(title: "Morph Presets", onBack: onBack)

            Text("Drag two JX-8P/JX-10/MKS-70 patches below, choose a blend, and save the result as a new patch.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)

            HStack(spacing: 24) {
                DropZoneView(title: "Patch A", slot: $slotA)
                DropZoneView(title: "Patch B", slot: $slotB)
            }

            VStack(spacing: 6) {
                Text("Morph amount — \(Int(amount * 100))% toward Patch B")
                    .font(.subheadline)
                Slider(value: $amount, in: 0...1)
            }
            .padding(.horizontal, 30)

            Button(action: generateAndSave) {
                Label("Generate Morphed Preset & Save…", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 40)
            .disabled(slotA == nil || slotB == nil)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(isError ? .red : .secondary)
            }

            Spacer(minLength: 10)
        }
        .padding(28)
    }

    private func generateAndSave() {
        guard let a = slotA?.patch, let b = slotB?.patch else { return }
        let morphed = PatchMorpher.morph(a, b, amount: amount)

        let filename = "\(RandomNameGenerator.fileBaseName()).syx"
        let data = Data(morphed.aprMessage())

        FilePanel.save(data: data, suggestedName: filename) { result in
            switch result {
            case .success(let url):
                isError = false
                statusMessage = "Saved morphed patch “\(morphed.name.trimmingCharacters(in: .whitespaces))” as \(url.lastPathComponent)"
            case .failure(let error):
                isError = true
                statusMessage = "Couldn't save file: \(error.localizedDescription)"
            }
        }
    }
}
