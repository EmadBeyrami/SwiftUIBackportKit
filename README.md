# SwiftUIBackportKit

A tiny, dependency-free Swift Package for supporting multiple iOS versions in
SwiftUI — without breaking modifier chains, duplicating whole views, or
scattering `if #available` checks across a codebase.

It implements the patterns from two articles as a real, tested API instead of
helpers you copy-paste into every project:

- [Supporting Multiple iOS Versions in SwiftUI Without Turning Your Views Into a Mess](https://dev.to/emadbeyrami/supporting-multiple-ios-versions-in-swiftui-without-turning-your-views-into-a-mess-52oc)
- [Handling different iOS versions in a View body](https://swiftui-garden.com/Articles/Handling-different-iOS-versions-in-a-View-body)

## Table of contents

- [The problem](#the-problem)
- [Install](#install)
- [Quick start](#quick-start)
- [API](#api)
  - [`.modify { }`](#1-modify----keep-the-chain-intact)
  - [`.backport`](#2-backport--a-namespace-for-version-gated-apis)
  - [`platformValue(_:ifAtLeast:else:)`](#3-platformvalue_ifatleastelse--for-plain-values)
- [Which one do I use?](#which-one-do-i-use)
- [Writing your own backport](#writing-your-own-backport)
- [Full example](#full-example)
- [Requirements](#requirements)
- [Project layout](#project-layout)
- [Tests](#tests)
- [Example app](#example-app)

## The problem

A SwiftUI modifier chain is one continuous expression — every modifier
returns a new view that becomes the input to the next one:

```swift
Text("Hi")
    .font(.title)
    .foregroundStyle(.primary)
    .padding()
```

Dropping an `if #available` into the middle of that breaks it — an `if`
statement isn't a modifier and can't be chained:

```swift
// Does not compile.
Text("Hi")
    .font(.title)
    if #available(iOS 17, *) {
        .contentTransition(.numericText())
    }
    .padding()
```

So teams end up either duplicating the entire view per OS-version branch:

```swift
// Works, but now every future change to this view has to happen twice.
if #available(iOS 17, *) {
    Text("Hi")
        .font(.title)
        .foregroundStyle(.primary)
        .contentTransition(.numericText())
        .padding()
} else {
    Text("Hi")
        .font(.title)
        .foregroundStyle(.primary)
        .padding()
}
```

or restructuring the whole view around the check, which gets worse every
time a new OS version adds one more thing that needs gating. SwiftUIBackportKit
exists so neither of those has to happen.

## Install

**Xcode:** File → Add Package Dependencies… and enter the repository URL.

**Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/EmadBeyrami/SwiftUIBackportKit.git", from: "1.0.0")
]
```

```swift
.target(
    name: "YourApp",
    dependencies: ["SwiftUIBackportKit"]
)
```

Then in any file:

```swift
import SwiftUIBackportKit
```

## Quick start

```swift
import SwiftUI
import SwiftUIBackportKit

struct RowView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .modify {
                if #available(iOS 17, *) {
                    $0.contentTransition(.numericText())
                } else {
                    $0
                }
            }
            .padding(.vertical, platformValue(12, ifAtLeast: OSVersion(17), else: 8))
    }
}
```

## API

### 1. `.modify { }` — keep the chain intact

The core building block every other API in this package is built on. It
wraps `self` in a `@ViewBuilder` closure, so the branch happens *inside* the
chain instead of breaking it:

```swift
Text("Hi")
    .font(.title)
    .modify {
        if #available(iOS 17, *) {
            $0.contentTransition(.numericText())
        } else {
            $0
        }
    }
    .padding()
```

It composes anywhere a modifier would — mid-chain, nested, repeated:

```swift
VStack {
    Text("Total")
    Text(amount, format: .currency(code: "USD"))
}
.modify {
    if #available(iOS 17, *) {
        $0.symbolEffect(.bounce, value: amount)
    } else {
        $0
    }
}
.modify {
    if #available(iOS 16, *) {
        $0.scrollBounceBehavior(.basedOnSize)
    } else {
        $0
    }
}
```

It also works for more than two branches:

```swift
Image(systemName: "star")
    .modify {
        if #available(iOS 18, *) {
            $0.symbolEffect(.wiggle)
        } else if #available(iOS 17, *) {
            $0.symbolEffect(.bounce)
        } else {
            $0
        }
    }
```

**The one rule:** every branch must return a view, including `else`.
Omitting `else` — or forgetting to return `$0` — silently removes the view on
whichever OS versions take that branch:

```swift
// Bug: renders nothing at all pre-iOS 17.
.modify {
    if #available(iOS 17, *) {
        $0.contentTransition(.numericText())
    }
}
```

### 2. `.backport` — a namespace for version-gated APIs

`.modify` is great for a one-off check. Once the same `#available` branch
starts showing up in more than one place, promote it into `.backport` — a
namespace that reads exactly like the real SwiftUI API and hides the
branching entirely:

```swift
List(items) { item in
    Row(item)
}
.backport.scrollBounceBehaviorBasedOnSize()
.backport.scrollClipDisabled()
.backport.presentationDetents([.medium, .large])
.backport.onChange(of: selectedTab, initial: true) { old, new in
    analytics.track(from: old, to: new)
}
```

Every member of `Backport` is responsible for its own availability check and
its own pre-availability fallback — call sites never think about `#available`
at all.

#### Built in

| API | Backports | Pre-availability behavior |
|---|---|---|
| `.backport.onChange(of:initial:_:)` | iOS 17's two-value `onChange` | Synthesizes `(old, new)` on top of the single-value `onChange` that's always existed |
| `.backport.scrollBounceBehaviorBasedOnSize(axes:)` | iOS 16.4's `scrollBounceBehavior(_:axes:)` | No-op — keeps the default bounce behavior |
| `.backport.scrollClipDisabled(_:)` | iOS 17's `scrollClipDisabled(_:)` | No-op — content stays clipped, the universal pre-17 default |
| `.backport.presentationDetents(_:)` | iOS 16.4's `presentationDetents(_:)` | No-op — sheet renders at its default size |

**`onChange` — the one every app hits.** Before iOS 17, `onChange` only
handed you the new value; getting the old one meant hand-rolling your own
`@State` cache at every call site:

```swift
// Before — repeated at every call site that needs the old value.
struct SearchView: View {
    @State private var query = ""
    @State private var previousQuery = ""

    var body: some View {
        TextField("Search", text: $query)
            .onChange(of: query) { newValue in
                logSearch(from: previousQuery, to: newValue)
                previousQuery = newValue
            }
    }
}
```

```swift
// After.
struct SearchView: View {
    @State private var query = ""

    var body: some View {
        TextField("Search", text: $query)
            .backport.onChange(of: query) { old, new in
                logSearch(from: old, to: new)
            }
    }
}
```

On iOS 17+ this forwards straight to the system API (including `initial:`).
Below that, it caches the previous value internally and calls your closure
with `(old, new)` — you never see the difference.

**`presentationDetents` — bridging a type that doesn't exist pre-16.4.**
`PresentationDetent` itself isn't available before iOS 16.4, so the backport
defines its own `PresentationDetentCompat` enum that mirrors the real cases
without ever naming the unavailable type outside an `#available`-guarded
context:

```swift
.sheet(isPresented: $showingSheet) {
    DetailView()
        .backport.presentationDetents([.medium, .large, .fraction(0.4), .height(220)])
}
```

Pre-16.4, the sheet just renders at its default size — there's no equivalent
API to fall back to, so this is a no-op rather than an approximation.

**`scrollBounceBehaviorBasedOnSize` / `scrollClipDisabled` — the common
case.** No new type appears in either signature, so the shim is a plain
`#available` branch with a no-op fallback:

```swift
ScrollView {
    content
}
.backport.scrollBounceBehaviorBasedOnSize()
.backport.scrollClipDisabled()
```

### 3. `platformValue(_:ifAtLeast:else:)` — for plain values

Sometimes the only thing that changes between OS versions is a constant — a
corner radius, a font size, a spacing value. `#available` is overkill here,
and the naive fix (a hardcoded function per version pair, e.g.
`func value(new: T, old: T) -> T { if #available(iOS 26, *) { new } else { old } }`)
means writing a brand-new function every time a new OS version needs a new
threshold. `platformValue` uses a runtime version check instead, so any
version works without a new declaration:

```swift
.cornerRadius(platformValue(20, ifAtLeast: OSVersion(17), else: 12))
.font(.system(size: platformValue(34, ifAtLeast: OSVersion(26), else: 28)))
.padding(platformValue(16, ifAtLeast: OSVersion(16, 4), else: 12))
```

`OSVersion` takes `major`, `minor`, and `patch`, so precise thresholds like
"iOS 16.4" are just `OSVersion(16, 4)`.

You can also call the underlying check directly when you just need a
`Bool`:

```swift
if OS.isAtLeast(OSVersion(17)) {
    startNewOnboardingFlow()
} else {
    startLegacyOnboardingFlow()
}
```

**Important caveat:** this is a *runtime* check, not a compile-time one.
It's only safe for choosing between two already-available **values** — two
`CGFloat`s, two `Color`s, two cases of an enum that exists on every
deployment target you support. It does not teach the compiler anything about
API availability. This will not compile, and shouldn't — the compiler can't
verify a runtime condition:

```swift
// Won't compile: `ScrollBounceBehavior` isn't available pre-iOS 16.4,
// and `platformValue` can't tell the compiler otherwise.
let behavior = platformValue(ScrollBounceBehavior.basedOnSize, ifAtLeast: OSVersion(16, 4), else: .automatic)
```

For anything that references a version-gated type or method, use
`.modify` or `.backport` so `#available` does the real compile-time check.

## Which one do I use?

| Situation | Use |
|---|---|
| One-off check, used in a single place | `.modify { }` |
| Same check reused across multiple views | `.backport`, with a new extension on `Backport where Content: View` |
| Only a constant changes between OS versions | `platformValue(_:ifAtLeast:else:)` |
| Need a plain `Bool` for non-view logic (e.g. picking an onboarding flow) | `OS.isAtLeast(_:)` |

## Writing your own backport

Every built-in shim follows the same shape, so adding one is mechanical.
Here's the actual source for `scrollClipDisabled`, included in this package,
as a template:

```swift
import SwiftUI

public extension Backport where Content: View {
    /// Backport of `.scrollClipDisabled(_:)`, added in iOS 17. A no-op
    /// before that — content stays clipped to the scroll view's bounds,
    /// which is the pre-17 default everywhere.
    @ViewBuilder
    func scrollClipDisabled(_ disabled: Bool = true) -> some View {
        if #available(iOS 17, macOS 14, *) {
            content.scrollClipDisabled(disabled)
        } else {
            content
        }
    }
}
```

The recipe:

1. `extension Backport where Content: View { ... }` — this is what makes
   `.backport.yourMethod()` resolve.
2. `@ViewBuilder func yourMethod(...) -> some View` — mirror the real API's
   parameter list as closely as you can, *except* drop any parameter whose
   type doesn't exist pre-availability (see the next point).
3. Inside, branch on `#available` and call the real API on `content` in the
   `true` branch; return `content` unmodified (or the closest equivalent) in
   the `else`.
4. **If the real API takes a type that doesn't exist on older OS versions**
   (like `PresentationDetent`), don't put that type in your signature —
   define your own compat enum/struct with the same cases, and convert to
   the real type only inside an `@available`-guarded computed property. See
   `Sources/SwiftUIBackportKit/Modifiers/Backport+PresentationDetents.swift` for the
   full pattern.
5. Add a compile-smoke test in `Tests/SwiftUIBackportKitTests/CompileSmokeTests.swift`
   that calls the new method — SwiftUI view trees aren't easily inspectable
   without a hosting environment, so these tests exist to catch signature
   drift, not to assert on pixels.

## Full example

A settings row that uses all three APIs together:

```swift
import SwiftUI
import SwiftUIBackportKit

struct SettingsRow: View {
    @State private var isEnabled = true
    @State private var selectedTheme = "System"

    var body: some View {
        VStack(alignment: .leading, spacing: platformValue(12, ifAtLeast: OSVersion(17), else: 8)) {
            Toggle("Enable Notifications", isOn: $isEnabled)
                .modify {
                    if #available(iOS 17, *) {
                        $0.symbolEffect(.bounce, value: isEnabled)
                    } else {
                        $0
                    }
                }

            Picker("Theme", selection: $selectedTheme) {
                Text("System").tag("System")
                Text("Light").tag("Light")
                Text("Dark").tag("Dark")
            }
            .backport.onChange(of: selectedTheme) { old, new in
                applyTheme(from: old, to: new)
            }
        }
        .padding(platformValue(16, ifAtLeast: OSVersion(16, 4), else: 12))
        .backport.scrollBounceBehaviorBasedOnSize()
    }

    private func applyTheme(from old: String, to new: String) {
        // ...
    }
}
```

## Requirements

iOS 15+. macOS 12+ is also declared in `Package.swift` — not because this is
a macOS-focused package, but so the package (and its test suite) builds and
runs via plain `swift build` / `swift test` on a Mac without needing an iOS
simulator. Every backport checks both platforms' actual minimum OS version
(e.g. `#available(iOS 17, macOS 14, *)`), so behavior on each platform
matches that platform's real API availability.

## Project layout

```
Sources/SwiftUIBackportKit/
  Core/
    View+Modify.swift              — .modify { }
    Backport.swift                 — the Backport<Content> namespace + .backport
    PlatformValue.swift            — OSVersion, OS.isAtLeast, platformValue
  Modifiers/
    Backport+OnChange.swift        — .backport.onChange(of:initial:_:)
    Backport+ScrollBounceBehavior.swift
    Backport+ScrollClipDisabled.swift
    Backport+PresentationDetents.swift
Tests/SwiftUIBackportKitTests/
  PlatformValueTests.swift         — logic tests for OS.isAtLeast / platformValue
  CompileSmokeTests.swift          — signature/composition tests for every public API
Example/
  SwiftUIBackportKitExample.xcodeproj — depends on this package via a local path
  SwiftUIBackportKitExample/Demos/     — one SwiftUI view per API, see Example/README.md
```

## Tests

```
swift test
```

## Example app

`Example/` is a runnable iOS app that depends on this package locally and has
one screen per API — see [`Example/README.md`](Example/README.md) for what's
in it. Open `Example/SwiftUIBackportKitExample.xcodeproj` in Xcode and run it
on any iOS 15+ simulator or device.

If your command-line toolchain doesn't include XCTest (only Command Line
Tools installed, no Xcode), point at an installed Xcode for just this
command:

```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```
