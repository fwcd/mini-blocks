import CoreGraphics

extension CGPoint {
    static func +(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func +(lhs: Self, rhs: CGSize) -> Self {
        Self(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    
    static func -(lhs: Self, rhs: CGSize) -> Self {
        Self(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
}

extension CGSize {
    static func *(lhs: Self, rhs: CGFloat) -> Self {
        Self(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func /(lhs: Self, rhs: CGFloat) -> Self {
        Self(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(origin: center - (size / 2), size: size)
    }
}
