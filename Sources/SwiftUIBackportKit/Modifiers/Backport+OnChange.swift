import SwiftUI

public extension Backport where Content: View {
    /// Backport of the iOS 17 two-value `onChange(of:initial:_:)`.
    ///
    /// On iOS 17+ this forwards straight to the system API. On earlier
    /// versions there is no two-value `onChange` at all, so this modifier
    /// caches the previous value itself and synthesizes the same
    /// `(oldValue, newValue)` callback on top of the single-value API that's
    /// always been available.
    ///
    ///     content
    ///         .backport.onChange(of: selectedTab) { old, new in
    ///             analytics.track(from: old, to: new)
    ///         }
    @ViewBuilder
    func onChange<V: Equatable>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void
    ) -> some View {
        if #available(iOS 17, macOS 14, *) {
            content.onChange(of: value, initial: initial) { old, new in
                action(old, new)
            }
        } else {
            content.modifier(LegacyOnChange(value: value, initial: initial, action: action))
        }
    }
}

private struct LegacyOnChange<V: Equatable>: ViewModifier {
    let value: V
    let initial: Bool
    let action: (_ oldValue: V, _ newValue: V) -> Void

    @State private var oldValue: V?
    @State private var firedInitial = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard oldValue == nil else { return }
                oldValue = value
                if initial, !firedInitial {
                    firedInitial = true
                    action(value, value)
                }
            }
            .onChange(of: value) { newValue in
                let previous = oldValue ?? newValue
                oldValue = newValue
                action(previous, newValue)
            }
    }
}
