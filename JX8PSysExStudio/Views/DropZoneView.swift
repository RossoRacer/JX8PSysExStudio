//
//  DropZoneView.swift
//  JX8PSysExStudio
//
//  A drag-and-drop target that accepts a .syx file. If the file contains a
//  single patch, it's loaded directly. If it contains a full 32-patch bank
//  (like the factory ROM dump), the user is asked which patch to use.
//

import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    let title: String
    @Binding var slot: PatchSlot?

    @State private var isTargeted = false
    @State private var bankChoices: [JX8PPatch]?
    @State private var bankFileName = ""
    @State private var loadError: String?

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [7]))
                    .foregroundStyle(isTargeted ? Color.accentColor : Color.secondary.opacity(0.4))
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.secondary.opacity(isTargeted ? 0.10 : 0.05))
                    )

                if let slot {
                    VStack(spacing: 6) {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.accentColor)
                        Text(slot.patch.name.trimmingCharacters(in: .whitespaces))
                            .font(.system(.body, design: .monospaced).bold())
                        Text(slot.sourceFileName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .padding()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.down.doc")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                        Text("Drop a .syx patch here")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(height: 160)
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                handleDrop(providers)
                return true
            }

            HStack {
                Button("Choose File…") {
                    FilePanel.open { url in
                        if let url { load(url: url) }
                    }
                }
                if slot != nil {
                    Button("Clear", role: .destructive) { slot = nil }
                }
            }

            if let loadError {
                Text(loadError)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
        .confirmationDialog(
            "\(bankFileName) contains multiple patches. Choose one:",
            isPresented: Binding(
                get: { bankChoices != nil },
                set: { if !$0 { bankChoices = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let bankChoices {
                ForEach(Array(bankChoices.enumerated()), id: \.offset) { index, patch in
                    Button("\(index + 1). \(patch.name.trimmingCharacters(in: .whitespaces))") {
                        slot = PatchSlot(patch: patch, sourceFileName: "\(bankFileName) (#\(index + 1))")
                        self.bankChoices = nil
                    }
                }
                Button("Cancel", role: .cancel) { self.bankChoices = nil }
            }
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        _ = provider.loadObject(ofClass: URL.self) { url, _ in
            guard let url else { return }
            DispatchQueue.main.async { load(url: url) }
        }
    }

    private func load(url: URL) {
        loadError = nil
        guard let data = try? Data(contentsOf: url) else {
            loadError = "Couldn't read that file."
            return
        }
        let patches = JX8PBank.parsePatches(from: data)
        guard !patches.isEmpty else {
            loadError = JX8PBank.rejectionReason(for: data)
            return
        }
        if patches.count == 1 {
            slot = PatchSlot(patch: patches[0], sourceFileName: url.lastPathComponent)
        } else {
            bankFileName = url.lastPathComponent
            bankChoices = patches
        }
    }
}
