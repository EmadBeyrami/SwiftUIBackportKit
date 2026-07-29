import XCTest
import SwiftUI
@testable import SwiftUIBackportKit

/// These don't render or assert on pixels - SwiftUI view trees aren't easily
/// inspectable without a hosting environment. They exist to lock down that
/// every public API in this package actually type-checks and composes the
/// way the README says it does; a signature change that breaks a call site
/// below fails the build, which is the failure mode that matters most here.
final class CompileSmokeTests: XCTestCase {
    func testModifyKeepsTheChainIntact() {
        let view = Text("Hi")
            .font(.title)
            .modify {
                if #available(iOS 17, *) {
                    $0.opacity(1)
                } else {
                    $0
                }
            }
            .padding()

        XCTAssertNotNil(AnyView(view))
    }

    func testBackportScrollBounceBehavior() {
        let view = List {
            Text("Row")
        }
        .backport.scrollBounceBehaviorBasedOnSize()

        XCTAssertNotNil(AnyView(view))
    }

    func testBackportPresentationDetents() {
        let view = Text("Sheet")
            .backport.presentationDetents([.medium, .large, .fraction(0.4), .height(200)])

        XCTAssertNotNil(AnyView(view))
    }

    func testBackportScrollClipDisabled() {
        let view = ScrollView {
            Text("Overflowing content")
        }
        .backport.scrollClipDisabled()

        XCTAssertNotNil(AnyView(view))
    }

    func testBackportOnChangeCompiles() {
        let counter = 0
        let view = Text("Watched")
            .backport.onChange(of: counter, initial: true) { old, new in
                _ = (old, new)
            }

        XCTAssertNotNil(AnyView(view))
    }
}
