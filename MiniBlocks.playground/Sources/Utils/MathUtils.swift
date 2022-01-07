extension SignedInteger {
    /// Performs division with another integer.
    func floorDiv(_ rhs: Self) -> Self {
        assert(rhs > 0)
        return self >= 0 ? (self / rhs) : ((self - rhs + 1) / rhs)
    }
}
