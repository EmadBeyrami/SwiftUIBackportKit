import SwiftUI
import SwiftUIBackportKit

/// Both of these are iOS 17/16.4 APIs with no parameter that references a
/// type unavailable pre-availability, so the backport is a plain no-op
/// fallback - the scroll view just keeps its default behavior on older OS
/// versions.
struct ScrollBehaviorDemo: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(1...8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.tint.opacity(0.15))
                        .frame(height: 80)
                        .overlay(Text("Row \(index)"))
                }
            }
            .padding()
        }
        .backport.scrollBounceBehaviorBasedOnSize()
        .backport.scrollClipDisabled()
        .navigationTitle("backport scroll")
    }
}

#Preview {
    ScrollBehaviorDemo()
}
