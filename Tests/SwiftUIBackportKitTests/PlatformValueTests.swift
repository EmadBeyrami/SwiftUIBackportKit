import XCTest
@testable import SwiftUIBackportKit

final class PlatformValueTests: XCTestCase {
    func testIsAtLeastIsTrueForAnAncientVersion() {
        XCTAssertTrue(OS.isAtLeast(OSVersion(1)))
    }

    func testIsAtLeastIsFalseForAnUnreleasedVersion() {
        XCTAssertFalse(OS.isAtLeast(OSVersion(9999)))
    }

    func testPlatformValuePicksNewForAnAncientVersion() {
        XCTAssertEqual(platformValue("new", ifAtLeast: OSVersion(1), else: "old"), "new")
    }

    func testPlatformValuePicksOldForAnUnreleasedVersion() {
        XCTAssertEqual(platformValue("new", ifAtLeast: OSVersion(9999), else: "old"), "old")
    }

    func testPlatformValueWorksWithNonStringTypes() {
        let radius = platformValue(20.0, ifAtLeast: OSVersion(1), else: 12.0)
        XCTAssertEqual(radius, 20.0)
    }
}
