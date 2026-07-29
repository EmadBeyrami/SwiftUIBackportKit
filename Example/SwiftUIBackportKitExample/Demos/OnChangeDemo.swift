import SwiftUI
import SwiftUIBackportKit

/// `.backport.onChange` gives you the iOS 17 two-value `onChange` closure
/// everywhere back to this package's iOS 15 minimum — on older versions it
/// synthesizes `oldValue` for you.
struct OnChangeDemo: View {
    @State private var query = ""
    @State private var log: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Type something…", text: $query)
                .textFieldStyle(.roundedBorder)
                .backport.onChange(of: query) { old, new in
                    log.insert("\"\(old)\" \u{2192} \"\(new)\"", at: 0)
                }

            Text("Change log (oldValue \u{2192} newValue):")
                .font(.subheadline.bold())

            List(log, id: \.self) { entry in
                Text(entry).font(.system(.body, design: .monospaced))
            }
            .listStyle(.plain)
        }
        .padding()
        .navigationTitle("backport.onChange")
    }
}

#Preview {
    OnChangeDemo()
}
