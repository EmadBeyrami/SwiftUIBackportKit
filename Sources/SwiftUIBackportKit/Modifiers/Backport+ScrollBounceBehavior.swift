import SwiftUI

public extension Backport where Content: View {
    /// Backport of `.scrollBounceBehavior(.basedOnSize, axes:)`, added in
    /// iOS 16.4. A no-op before that — the scroll view simply keeps its
    /// default bounce behavior, which is the safe fallback.
    @ViewBuilder
    func scrollBounceBehaviorBasedOnSize(axes: Axis.Set = .vertical) -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            content.scrollBounceBehavior(.basedOnSize, axes: axes)
        } else {
            content
        }
    }
}
