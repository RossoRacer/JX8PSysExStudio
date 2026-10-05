//
//  RandomBankView.swift
//  JX8PSysExStudio
//

import SwiftUI

struct RandomBankView: View {
    let onBack: () -> Void

    @State private var previewNames: [String] = []
    @State private var statusMessage: String?
    @State private var isError = false

    var body: some View {
        VStack(spacing: 20) {
            HeaderBar(title: "Random Bank", onBack: onBack)

            Text("Creates 32 fully-randomized JX-8P tone patches and saves them as a single factory-format SysEx bank, ready to send to a JX-8P, JX-10, or MKS-70.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 30)

            if previewNames.isEmpty {
                Spacer()
                Image(systemName: "square.grid.4x3.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(.secondary.opacity(0.4))
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], spacing: 8) {
                        ForEach(Array(previewNames.enumerated()), id: \.offset) { index, name in
                            HStack {
                                Text(String(format: "%02d", index + 1))
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                Text(name)
                                    .font(.system(.caption, design: .monospaced))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.secondary.opacity(0.08)))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 220)
            }

            Button(action: generateAndSave) {
                Label("Generate Random Bank & Save…", systemImage: "shuffle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 40)

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
        let bank = RandomPatchGenerator.randomBank()
        previewNames = bank.patches.map { $0.name }

        let filename = "\(RandomNameGenerator.fileBaseName()).syx"
        let data = bank.sysexData()

        FilePanel.save(data: data, suggestedName: filename) { result in
            switch result {
            case .success(let url):
                isError = false
                statusMessage = "Saved 32-patch bank as \(url.lastPathComponent)"
            case .failure(let error):
                isError = true
                statusMessage = "Couldn't save file: \(error.localizedDescription)"
            }
        }
    }
}
