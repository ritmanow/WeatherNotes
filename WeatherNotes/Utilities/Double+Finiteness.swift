import Foundation

extension Double {
    /// Use before passing values to Core Data, `String(format:)`, or layout-related APIs.
    var finiteOrZero: Double { isFinite ? self : 0 }
}

extension Float {
    var finiteOrZero: Float { isFinite ? self : 0 }
}
