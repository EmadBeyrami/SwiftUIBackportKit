import SwiftUI

public extension Backport where Content: View {
    /// Mirrors the cases of `PresentationDetent` (iOS 16.4+) without
    /// referencing that type directly, so this enum - and the modifier
    /// below - stay usable all the way back to this package's iOS 15
    /// minimum deployment target.
    enum PresentationDetentCompat: Hashable {
        case medium
        case large
        case fraction(CGFloat)
        case height(CGFloat)

        @available(iOS 16.4, macOS 13.0, *)
        var systemValue: PresentationDetent {
            switch self {
            case .medium: return .medium
            case .large: return .large
            case .fraction(let value): return .fraction(value)
            case .height(let value): return .height(value)
            }
        }
    }

    /// Backport of `.presentationDetents(_:)`, added in iOS 16.4. Sheets on
    /// earlier versions simply render at their default size - there's no
    /// equivalent API to fall back to, so this is a no-op pre-16.4.
    @ViewBuilder
    func presentationDetents(_ detents: Set<PresentationDetentCompat>) -> some View {
        if #available(iOS 16.4, macOS 13.0, *) {
            content.presentationDetents(Set(detents.map { $0.systemValue }))
        } else {
            content
        }
    }
}
