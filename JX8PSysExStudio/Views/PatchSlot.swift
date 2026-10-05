//
//  PatchSlot.swift
//  JX8PSysExStudio
//

import Foundation

struct PatchSlot: Identifiable, Equatable {
    let id = UUID()
    var patch: JX8PPatch
    var sourceFileName: String

    static func == (lhs: PatchSlot, rhs: PatchSlot) -> Bool {
        lhs.id == rhs.id
    }
}
