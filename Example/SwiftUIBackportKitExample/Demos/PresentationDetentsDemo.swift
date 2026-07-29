import SwiftUI
import SwiftUIBackportKit

/// `PresentationDetent` itself doesn't exist before iOS 16.4, so the backport
/// bridges through its own `PresentationDetentCompat` enum. On iOS 16.4+ the
/// sheet honors the detents below; on earlier versions it's a no-op and the
/// sheet just renders at its default size.
struct PresentationDetentsDemo: View {
    @State private var showingSheet = false

    var body: some View {
        VStack {
            Button("Show Sheet") { showingSheet = true }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("presentationDetents")
        .sheet(isPresented: $showingSheet) {
            VStack(spacing: 16) {
                Text("Drag the grabber")
                    .font(.headline)
                Text("On iOS 16.4+, this sheet supports .medium, .large, and a custom .fraction detent. On earlier versions it just renders at the default size — no crash.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .padding()
            .backport.presentationDetents([.medium, .large, .fraction(0.25)])
        }
    }
}

#Preview {
    PresentationDetentsDemo()
}
