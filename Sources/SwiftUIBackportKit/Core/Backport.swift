import SwiftUI

/// Namespace that hosts version-gated shims for View (and friends).
///
/// Rather than scattering `if #available` checks — or a growing pile of
/// ad-hoc `modify { }` calls — across your views, backported APIs live here
/// and read at the call site exactly like the real thing:
///
///     List(items) { item in
///         Row(item)
///     }
///     .backport.scrollBounceBehaviorBasedOnSize()
///     .backport.onChange(of: selection) { old, new in
///         track(old, new)
///     }
///
/// Each member is responsible for checking availability itself and falling
/// back to sensible pre-availability behavior — callers never need to think
/// about which OS introduced the underlying API.
public struct Backport<Content> {
    public let content: Content

    init(_ content: Content) {
        self.content = content
    }
}

public extension View {
    /// Entry point into the `Backport` namespace.
    var backport: Backport<Self> { Backport(self) }
}
