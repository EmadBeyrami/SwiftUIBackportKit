import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Core") {
                    NavigationLink("modify { } - branch inside a chain") {
                        ModifyDemo()
                    }
                    NavigationLink("platformValue - version-based constants") {
                        PlatformValueDemo()
                    }
                }
                Section("Backport") {
                    NavigationLink("backport.onChange - two-value onChange") {
                        OnChangeDemo()
                    }
                    NavigationLink("backport scroll behavior") {
                        ScrollBehaviorDemo()
                    }
                    NavigationLink("backport.presentationDetents") {
                        PresentationDetentsDemo()
                    }
                }
            }
            .navigationTitle("SwiftUIBackportKit")
        }
    }
}

#Preview {
    ContentView()
}
