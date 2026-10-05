//
//  ContentView.swift
//  JX8PSysExStudio
//
//  On launch, lets the user choose which of the two tools they want, then
//  shows that tool. A back button returns to the chooser.
//

import SwiftUI

enum AppMode {
    case chooser
    case randomBank
    case morph
}

struct ContentView: View {
    @State private var mode: AppMode = .chooser

    var body: some View {
        Group {
            switch mode {
            case .chooser:
                ModeSelectionView { selected in
                    mode = selected
                }
            case .randomBank:
                RandomBankView(onBack: { mode = .chooser })
            case .morph:
                MorphView(onBack: { mode = .chooser })
            }
        }
        .animation(.easeInOut(duration: 0.2), value: mode)
    }
}

#Preview {
    ContentView()
}
