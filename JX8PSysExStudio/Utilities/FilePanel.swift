//
//  FilePanel.swift
//  JX8PSysExStudio
//
//  Thin wrappers around NSSavePanel / NSOpenPanel for reading and writing
//  .syx SysEx files.
//

import AppKit
import UniformTypeIdentifiers

enum FilePanel {

    private static var syxType: UTType {
        UTType(filenameExtension: "syx") ?? .data
    }

    /// Presents a save panel pre-filled with `suggestedName`, then writes
    /// `data` to wherever the user chooses.
    static func save(data: Data, suggestedName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let panel = NSSavePanel()
        panel.title = "Save JX-8P SysEx File"
        panel.nameFieldStringValue = suggestedName
        panel.allowedContentTypes = [syxType]
        panel.canCreateDirectories = true

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            do {
                try data.write(to: url, options: .atomic)
                completion(.success(url))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Presents an open panel for picking a single .syx file.
    static func open(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.title = "Choose a JX-8P SysEx File"
        panel.allowedContentTypes = [syxType, .data]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        panel.begin { response in
            completion(response == .OK ? panel.url : nil)
        }
    }
}
