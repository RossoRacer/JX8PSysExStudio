//
//  PatchMorpher.swift
//  JX8PSysExStudio
//
//  Morphs (linearly interpolates) between two JX-8P patches, parameter by
//  parameter, to create a new hybrid patch.
//

import Foundation

enum PatchMorpher {

    /// Morphs patch A toward patch B.
    /// - Parameter amount: 0.0 = identical to A, 1.0 = identical to B, 0.5 = halfway between.
    static func morph(_ a: JX8PPatch, _ b: JX8PPatch, amount: Double) -> JX8PPatch {
        let t = max(0, min(1, amount))
        var params = [UInt8](repeating: 0, count: JX8PPatch.parameterCount)

        for i in 0..<JX8PPatch.parameterCount {
            if JX8PPatch.undefinedIndices.contains(i) || JX8PPatch.nameRange.contains(i) {
                continue // name is set separately below; reserved slots stay 0
            }
            let va = Double(a.parameters[i])
            let vb = Double(b.parameters[i])
            let blended = ((1 - t) * va) + (t * vb)
            params[i] = UInt8(max(0, min(127, blended.rounded())))
        }

        var patch = JX8PPatch(parameters: params)
        patch.name = blendedName(a.name, b.name, amount: t)
        return patch
    }

    /// Builds a 10-character name that hints at both source patches, biased
    /// toward whichever one dominates the morph.
    private static func blendedName(_ a: String, _ b: String, amount: Double) -> String {
        let aTrim = a.trimmingCharacters(in: .whitespaces)
        let bTrim = b.trimmingCharacters(in: .whitespaces)
        let aLen = amount < 0.5 ? 6 : 4
        let bLen = 10 - aLen - 1
        let aPart = aTrim.prefix(aLen)
        let bPart = bTrim.prefix(bLen)
        return "\(aPart) \(bPart)".uppercased()
    }
}
