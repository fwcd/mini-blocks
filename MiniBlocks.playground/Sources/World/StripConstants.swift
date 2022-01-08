enum StripConstants {
    /// y = 0 is at index 64.
    static let offset: Int = 64
    /// Each strip is 128 blocks high.
    static let totalHeight: Int = 128
    /// The range of valid y-values.
    static let range: Range<Int> = (-offset..<(totalHeight - offset))
}
