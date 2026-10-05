//
//  RandomPatchGenerator.swift
//  JX8PSysExStudio
//
//  Generates fully-randomized JX-8P patches from raw random numbers, and
//  assembles them into a 32-patch bank.
//

import Foundation

enum RandomPatchGenerator {

    /// One patch with every real (non-name, non-reserved) parameter set to
    /// a uniformly random value in 0...127.
    static func randomPatch(named name: String? = nil) -> JX8PPatch {
        var params = [UInt8](repeating: 0, count: JX8PPatch.parameterCount)
        for index in 0..<JX8PPatch.parameterCount {
            if JX8PPatch.nameRange.contains(index) || JX8PPatch.undefinedIndices.contains(index) {
                continue
            }
            params[index] = UInt8.random(in: 0...127)
        }
        var patch = JX8PPatch(parameters: params)
        patch.name = name ?? RandomNameGenerator.patchName()
        return patch
    }

    /// A full 32-patch bank of randomized patches.
    static func randomBank() -> JX8PBank {
        let patches = (0..<JX8PBank.slotCount).map { _ in randomPatch() }
        return JX8PBank(patches: patches)
    }
}
