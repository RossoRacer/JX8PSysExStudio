
# JX-8P SysEx Studio

A small macOS app for the Roland JX-8P with two tools, chosen on launch:

1. **Random Bank** — generates 32 brand-new patches from random numbers and
   saves them as one factory-format 32-patch SysEx bank file.
2. **Morph Presets** — drag and drop two JX-8P/JX-10/MKS-70 patches, blend them together with a slider, and
   save the result as a new single patch.

Both tools save with an auto-generated random filename (e.g.
`Solar-Drift-4821.syx`), via a normal macOS save panel so you can pick where
it goes.

<img width="968" height="620" alt="Image2" src="https://github.com/user-attachments/assets/5b7f933f-4e63-40b8-af57-ba0b6ff3bcbc" />

## Opening the project

1. Unzip and open `JX8PSysExStudio.xcodeproj` in Xcode (15 or later; macOS 13+ deployment target).
2. Select the `JX8PSysExStudio` scheme and press **Run** (⌘R).

There are no external dependencies — it's pure SwiftUI + AppKit (for the
save/open panels) and a few hundred lines of hand-written code.

The app is not sandboxed (no entitlements file), so it can write your saved
`.syx` files anywhere you choose in the save panel with no extra setup.

## How the SysEx format was derived

Roland's JX-8P transmits a patch as an "APR" (All Parameters) SysEx message:

```
F0 41 35 <channel> 21 20 01  <59 parameter bytes>  F7
```

— a 7-byte header, 59 sequential 7-bit parameter values (0–127), and a
single F7 terminator (67 bytes total). Parameters 0–9 are the patch's
10-character ASCII name; parameters 10, 23–25, and 57 are unused; the rest
are the real DCO / mixer / filter / envelope / LFO / chorus parameters.

A full 32-patch bank dump (like your attached `FACTORY_BANK_1-32.syx`) is
simply 32 of those APR messages, each immediately followed by an 11-byte
"slot address" message that tells the synth which of its 32 memory slots to
store that patch in:

```
F0 41 34 <channel> 21 20 01 00 <slot 0-31> 02 F7
```

That's 78 bytes per patch × 32 = 2496 bytes — exactly the size of your
attached factory bank. The app's `JX8PBank.sysexData()` was checked by
reconstructing your factory bank from its own parsed output and confirming
it matches your original file byte-for-byte.

Sources used to confirm the byte layout and parameter meanings: the JX-8P
owner's manual MIDI implementation chapter, and Dylan Knuth's open-source
`jx8p_patcher` Python module (which independently documents the same 59
parameters and does its own "lerp" morph between two patches — this app's
`PatchMorpher` uses the same linear-interpolation approach, adapted to
Swift).

## Files

```
JX8PSysExStudio/
  App/                     App entry point + root view (mode chooser)
  Models/
    JX8PPatch.swift        Single-patch model, SysEx encode/decode
    JX8PBank.swift         32-patch bank assembly + generic SysEx scanner
  Generators/
    RandomPatchGenerator   Random single patch / random 32-patch bank
    RandomNameGenerator    Random names for patches and save files
    PatchMorpher           Parameter-by-parameter interpolation
  Utilities/
    FilePanel.swift        NSSavePanel / NSOpenPanel wrappers
  Views/                   SwiftUI screens (mode picker, random bank,
                            morph, drag-and-drop zone)
```
## 🚀 Getting Started

### How to Clone and Run
1. Clone the repository:
   ```bash
   git clone [https://github.com/RossoRacer/JX8PSysExStudio.git](https://github.com/RossoRacer/JX8PSysExStudio.git)
   
## Notes / possible next steps

- Random patches are uniform-random across the full 0–127 range for every
  real parameter, which is true to the brief ("from random numbers") but
  will produce a lot of harsh/extreme sounds along with some good
  surprises — that's the nature of fully random synth patches. If you'd
  rather bias randomization toward more "musical" ranges (e.g. keep
  envelope releases short, keep resonance out of self-oscillation, etc.),
  that's a small change to `RandomPatchGenerator`.
- `DropZoneView` accepts either a single-patch `.syx` or a full bank file
  (including your factory bank) and, for a bank, asks which of the 32
  patches to use.
- If you'd like the app to also talk to a MIDI interface directly (send a
  generated/morphed patch straight to your JX-8P instead of just saving a
  file), that would be a follow-up step using CoreMIDI.
