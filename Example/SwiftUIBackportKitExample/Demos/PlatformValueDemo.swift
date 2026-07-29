import SwiftUI
import SwiftUIBackportKit

/// `platformValue` and `OS.isAtLeast` are for picking between plain values —
/// no `#available` needed because neither branch references an unavailable
/// type or API.
struct PlatformValueDemo: View {
    private var cornerRadius: CGFloat {
        platformValue(28, ifAtLeast: OSVersion(17), else: 12)
    }

    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.tint)
                .frame(width: 160, height: 100)

            Text("Corner radius: \(Int(cornerRadius))pt")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(OS.isAtLeast(OSVersion(17)) ? "Running on iOS 17+" : "Running on iOS < 17")
                .font(.subheadline.bold())
        }
        .padding()
        .navigationTitle("platformValue")
    }
}

#Preview {
    PlatformValueDemo()
}
