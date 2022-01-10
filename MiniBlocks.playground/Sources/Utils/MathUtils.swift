extension SignedInteger {
    /// Performs floor division with another integer.
    func floorDiv(_ rhs: Self) -> Self {
        assert(rhs > 0)
        return self >= 0 ? (self / rhs) : ((self - rhs + 1) / rhs)
    }
    
    /// Performs floor (clocklike) modulo with another integer.
    func floorMod(_ rhs: Self) -> Self {
        self - floorDiv(rhs) * rhs
    }
}
