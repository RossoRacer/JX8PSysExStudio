//
//  RandomNameGenerator.swift
//  JX8PSysExStudio
//

import Foundation

enum RandomNameGenerator {

    private static let adjectives = [
        "NEON", "SOLAR", "LUNAR", "GLASS", "IRON", "VELVET", "CHROME", "ARCTIC",
        "EMBER", "MIST", "AZURE", "GOLDEN", "SILENT", "WILD", "ROGUE", "FAINT",
        "VIVID", "SHADOW", "CRIMSON", "PALE", "FERAL", "AMBER", "COBALT", "HOLLOW"
    ]

    private static let nouns = [
        "DRIFT", "PULSE", "ECHO", "STORM", "WAVE", "BLOOM", "CIRCUIT", "SPARK",
        "FOG", "TIDE", "ORBIT", "FLARE", "DUST", "GLOW", "RIFT", "HAZE",
        "BEAM", "CORE", "VOID", "PEAK", "FRACTURE", "NEBULA", "QUARTZ", "SIGNAL"
    ]

    /// A fun name, 10 characters or fewer, suitable for storing inside a
    /// patch's own name field (uppercase ASCII, JX-8P style).
    static func patchName() -> String {
        let adj = adjectives.randomElement()!.prefix(4)
        let noun = nouns.randomElement()!.prefix(5)
        return "\(adj) \(noun)".uppercased()
    }

    /// A fun, filesystem-safe base filename (no extension), e.g. "Solar-Drift-4821".
    static func fileBaseName() -> String {
        let adj = adjectives.randomElement()!.capitalized
        let noun = nouns.randomElement()!.capitalized
        let number = Int.random(in: 100...9999)
        return "\(adj)-\(noun)-\(number)"
    }
}
