import SwiftUI

public extension Backport where Content: View {
    /// Backport of `.scrollClipDisabled(_:)`, added in iOS 17. A no-op
    /// before that - content stays clipped to the scroll view's bounds,
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
