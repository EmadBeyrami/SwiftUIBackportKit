import SwiftUI
import SwiftUIBackportKit

/// `.modify { }` lets a version check live *inside* a modifier chain instead
/// of breaking it. Here `.symbolEffect` — an iOS 17 API — only applies on
/// iOS 17+; earlier versions just get the image back unchanged.
struct ModifyDemo: View {
    @State private var isOn = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: isOn ? "star.fill" : "star")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)
                .modify {
                    if #available(iOS 17, *) {
                        $0.symbolEffect(.bounce, value: isOn)
                    } else {
                        $0
                    }
                }

            Toggle("Favorite", isOn: $isOn)
                .padding(.horizontal, 40)

            Text("On iOS 17+, toggling this makes the star bounce via .symbolEffect. On earlier versions, .modify returns the image unchanged — no crash, no missing symbol.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .navigationTitle("modify { }")
    }
}

#Preview {
    ModifyDemo()
}
