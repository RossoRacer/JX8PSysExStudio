//
//  JX8PPatch.swift
//  JX8PSysExStudio
//
//  A single Roland JX-8P "Tone" (patch), represented exactly the way the
//  synth transmits it over MIDI SysEx: 59 sequential 7-bit parameter values
//  (0...127), where parameters 0-9 are the ASCII name, parameter 10 and
//  23-25 and 57 are unused/reserved, and the rest are the real tone
//  parameters (DCO, mixer, filter, envelopes, LFO, chorus...).
//
//  Verified against a factory ROM bank dump: each patch in a genuine
//  Roland bank is an "APR" (All Parameters) message:
//
//      F0 41 35 <channel> 21 20 01  <59 parameter bytes>  F7
//
//  i.e. a 7-byte header, 59 data bytes, and a single F7 terminator - 67
//  bytes total. That's exactly what this type produces and parses.
//

import Foundation

struct JX8PPatch: Identifiable, Equatable {
    let id = UUID()

    /// Always exactly 59 values, each 0...127.
    var parameters: [UInt8]

    static let parameterCount = 59
    static let nameRange = 0..<10
    /// Parameter numbers the JX-8P manual marks as unused/reserved.
    static let undefinedIndices: Set<Int> = [10, 23, 24, 25, 57]

    init(parameters: [UInt8]) {
        precondition(parameters.count == JX8PPatch.parameterCount, "JX-8P patches must have exactly 59 parameters")
        self.parameters = parameters.map { $0 & 0x7F }
    }

    /// A patch with every real parameter at zero (a quiet, but validly-formed, starting point).
    static func blank(name: String = "INIT") -> JX8PPatch {
        var patch = JX8PPatch(parameters: [UInt8](repeating: 0, count: parameterCount))
        patch.name = name
        return patch
    }

    /// The patch name, stored as parameters 0-9 (ASCII, space-padded to 10 characters).
    var name: String {
        get {
            let scalars = parameters[JX8PPatch.nameRange].map { byte -> Character in
                let v = Int(byte)
                return (32...126).contains(v) ? Character(UnicodeScalar(UInt8(v))) : " "
            }
            return String(scalars)
        }
        set {
            var chars = Array(newValue.uppercased().unicodeScalars.map { UInt8($0.value & 0x7F) })
            if chars.count < 10 {
                chars.append(contentsOf: [UInt8](repeating: 0x20, count: 10 - chars.count))
            } else if chars.count > 10 {
                chars = Array(chars.prefix(10))
            }
            for i in 0..<10 { parameters[i] = chars[i] }
        }
    }

    /// The 67-byte "APR" SysEx message for this single patch.
    func aprMessage(channel: UInt8 = 0) -> [UInt8] {
        var msg: [UInt8] = [0xF0, 0x41, 0x35, channel & 0x0F, 0x21, 0x20, 0x01]
        msg.append(contentsOf: parameters)
        msg.append(0xF7)
        return msg
    }

    /// The 11-byte "slot" trailer message that follows each patch inside a
    /// genuine 32-patch factory bank dump, addressing it to memory slot
    /// `slotIndex` (0-31).
    func slotMessage(slotIndex: Int, channel: UInt8 = 0) -> [UInt8] {
        [0xF0, 0x41, 0x34, channel & 0x0F, 0x21, 0x20, 0x01, 0x00, UInt8(slotIndex & 0x7F), 0x02, 0xF7]
    }

    /// Parses one SysEx message holding a single tone into a patch, or returns
    /// nil if the bytes don't look like one. Accepted layouts:
    ///
    ///   JX-8P APR:                F0 41 35 <ch> 21 20 01  <59 bytes>  F7             (67 bytes)
    ///   JX-10/MKS-70 APR:         F0 41 35 <ch> 24 20 0g  <59 bytes>  F7             (67 bytes)
    ///   JX-10/MKS-70 Bulk Dump:   F0 41 37 <ch> 24 20 0g  00 <tone#>  <59 bytes>  F7 (69 bytes)
    ///
    /// The 59 bytes (10-character name + 49 parameters) are laid out the same
    /// way on all of these, so JX-10/MKS-70 tones are simply re-wrapped as JX-8P patches.
    static func parseTone(_ bytes: [UInt8]) -> JX8PPatch? {
        guard bytes.count > 8,
              bytes.first == 0xF0, bytes.last == 0xF7,
              bytes[1] == 0x41,
              bytes[5] == 0x20            // level 0x20 = single tone (0x30 = two-tone JX-10 patch)
        else { return nil }

        let params: [UInt8]
        switch (bytes[2], bytes[4]) {
        case (0x35, 0x21), (0x35, 0x24):
            guard bytes.count == 67 else { return nil }
            params = Array(bytes[7..<66])
        case (0x37, 0x24):
            guard bytes.count == 69, bytes[7] == 0x00 else { return nil }
            params = Array(bytes[9..<68])         // skip the 00 and tone-number bytes
        default:
            return nil
        }
        guard params.count == parameterCount, params.allSatisfy({ $0 < 0x80 }) else { return nil }
        return JX8PPatch(parameters: params)
    }

    /// Kept for compatibility; now accepts JX-10/MKS-70 tone messages too.
    static func parseAPR(_ bytes: [UInt8]) -> JX8PPatch? {
        parseTone(bytes)
    }
}
