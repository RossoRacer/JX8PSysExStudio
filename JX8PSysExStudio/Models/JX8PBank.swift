//
//  JX8PBank.swift
//  JX8PSysExStudio
//
//  A 32-patch JX-8P SysEx bank, matching the exact byte-for-byte structure
//  of a genuine factory ROM dump: for each of the 32 patches, a 67-byte APR
//  (tone parameter) message immediately followed by an 11-byte slot-address
//  message. That's 78 bytes per patch, 2496 bytes total for a full bank -
//  which matches the FACTORY_BANK_1-32.syx reference file exactly.
//

import Foundation

struct JX8PBank {
    var patches: [JX8PPatch]

    static let slotCount = 32

    /// Builds the full bank SysEx data, ready to write to a .syx file or
    /// send to a JX-8P / JX-10 / MKS-70.
    func sysexData(channel: UInt8 = 0) -> Data {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(patches.count * 78)
        for (index, patch) in patches.enumerated() {
            bytes.append(contentsOf: patch.aprMessage(channel: channel))
            bytes.append(contentsOf: patch.slotMessage(slotIndex: index, channel: channel))
        }
        return Data(bytes)
    }

    /// Splits raw SysEx data into its individual F0...F7 messages.
    static func messages(in data: Data) -> [[UInt8]] {
        var result: [[UInt8]] = []
        var current: [UInt8] = []
        var inMessage = false

        for byte in data {
            if byte == 0xF0 {
                current = [byte]
                inMessage = true
            } else if inMessage {
                current.append(byte)
                if byte == 0xF7 {
                    inMessage = false
                    result.append(current)
                    current = []
                }
            }
        }
        return result
    }

    /// Scans arbitrary SysEx data for every F0...F7 message and returns the
    /// single-tone patches found among them. Single-patch files yield one
    /// patch, full banks yield up to 32. JX-8P and JX-10/MKS-70 tone
    /// messages are both understood.
    static func parsePatches(from data: Data) -> [JX8PPatch] {
        messages(in: data).compactMap { JX8PPatch.parseTone($0) }
    }

    /// A human-readable reason for why a file produced no patches.
    static func rejectionReason(for data: Data) -> String {
        let hasJX10Patch = messages(in: data).contains {
            $0.count > 5 && $0[1] == 0x41 && $0[2] == 0x37 && $0[4] == 0x24 && $0[5] == 0x30
        }
        if hasJX10Patch {
            return "That file holds JX-10/MKS-70 patches (two-tone performances), not single tones, so it can't be used here."
        }
        return "No JX-8P or JX-10/MKS-70 tone data found in that file."
    }
}
