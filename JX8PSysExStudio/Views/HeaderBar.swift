//
//  HeaderBar.swift
//  JX8PSysExStudio
//

import SwiftUI

struct HeaderBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
            .help("Back to mode selection")

            Text(title)
                .font(.title2.bold())

            Spacer()
        }
    }
}
