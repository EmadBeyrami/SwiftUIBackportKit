import Foundation

/// A minimal OS version, comparable at runtime - unlike `#available`, which
/// only accepts a version literal baked in at compile time.
public struct OSVersion {
    let systemVersion: OperatingSystemVersion

    public init(_ major: Int, _ minor: Int = 0, _ patch: Int = 0) {
        systemVersion = OperatingSystemVersion(majorVersion: major, minorVersion: minor, patchVersion: patch)
    }
}

public enum OS {
    /// Whether the current device is running at least `version`.
    ///
    /// This is a runtime check, not a compile-time one: it's the right tool
    /// for picking between two already-available *values* (a `CGFloat`, a
    /// `Color`, a case of an enum that exists on every deployment target you
    /// support). It does **not** teach the compiler anything about API
    /// availability - if the branches reference a type or method that only
    /// exists on newer OS versions, you still need `#available` (see
    /// `View.modify` and `Backport`) so the compiler can verify it.
    public static func isAtLeast(_ version: OSVersion) -> Bool {
        ProcessInfo.processInfo.isOperatingSystemAtLeast(version.systemVersion)
    }
}

/// Picks between two plain values depending on OS version, so call sites
/// don't need a one-off `if #available(iOS X, *) { new } else { old }`
/// (and a new function per version pair) every time a constant needs to
/// change between OS releases.
///
///     .cornerRadius(platformValue(20, ifAtLeast: OSVersion(17), else: 12))
///     .font(.system(size: platformValue(34, ifAtLeast: OSVersion(26), else: 28)))
public func platformValue<T>(_ new: T, ifAtLeast version: OSVersion, else old: T) -> T {
    OS.isAtLeast(version) ? new : old
}
