# SwiftUIBackportKit Example

A small iOS app that depends on `SwiftUIBackportKit` as a local Swift Package
and demonstrates each of its APIs.

## Run it

Open `SwiftUIBackportKitExample.xcodeproj` in Xcode and run the
`SwiftUIBackportKitExample` scheme on any iOS 15+ simulator or device.

The project file is generated from `project.yml` with
[XcodeGen](https://github.com/yonaskolb/XcodeGen). You only need XcodeGen if
you change `project.yml` and want to regenerate the project:

```
brew install xcodegen
xcodegen generate
```

## What's in it

`ContentView.swift` lists five demos, each in `SwiftUIBackportKitExample/Demos/`:

| Demo | Shows |
|---|---|
| `ModifyDemo` | `.modify { }` gating an iOS 17 `.symbolEffect` inside a chain |
| `PlatformValueDemo` | `platformValue(_:ifAtLeast:else:)` picking a corner radius by OS version |
| `OnChangeDemo` | `.backport.onChange(of:_:)` — two-value onChange back to iOS 15 |
| `ScrollBehaviorDemo` | `.backport.scrollBounceBehaviorBasedOnSize()` / `.backport.scrollClipDisabled()` |
| `PresentationDetentsDemo` | `.backport.presentationDetents(_:)` on a sheet |

Every demo runs unmodified across iOS versions — the whole point of the
package is that you don't write two versions of the view.
