import SwiftUI

public extension View {
    /// Wraps `self` in a closure so it can be branched on (typically with
    /// `#available`) without breaking the surrounding modifier chain.
    ///
    /// A modifier chain is one continuous expression: every modifier returns a
    /// new view that feeds the next one. An `if` statement dropped into the
    /// middle of that chain breaks it, forcing you to either duplicate the
    /// whole view or restructure it around the check. `modify` keeps the
    /// chain intact by moving the branch inside a `@ViewBuilder` closure:
    ///
    ///     Text("Hello")
    ///         .font(.title)
    ///         .modify {
    ///             if #available(iOS 17, *) {
    ///                 $0.contentTransition(.numericText())
    ///             } else {
    ///                 $0
    ///             }
    ///         }
    ///         .padding()
    ///
    /// The `else` branch must still return `$0` (or an equivalent view) -
    /// dropping it silently removes the view on older OS versions.
    @ViewBuilder
    func modify<Result: View>(@ViewBuilder _ transform: (Self) -> Result) -> some View {
        transform(self)
    }
}
