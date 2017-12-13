import Foundation
import CoreGraphics

extension Int: Easeable {
    public static var zero: Int = 0
    public static func /(lhs: Int, rhs: CGFloat) -> Int { return lhs / rhs }
    public static func *(lhs: Int, rhs: CGFloat) -> Int { return lhs * rhs }
    
    public func distance(to rhs: Int) -> CGFloat {
        return CGFloat(abs(self - rhs))
    }
}

extension Float: Easeable {
    public static var zero: Float = 0
    public static func /(lhs: Float, rhs: CGFloat) -> Float { return lhs / rhs }
    public static func *(lhs: Float, rhs: CGFloat) -> Float { return lhs * rhs }
    
    public func distance(to rhs: Float) -> CGFloat {
        return CGFloat(abs(self - rhs))
    }
}

extension Double: Easeable {
    public static var zero: Double = 0
    public static func /(lhs: Double, rhs: CGFloat) -> Double { return lhs / rhs }
    public static func *(lhs: Double, rhs: CGFloat) -> Double { return lhs * rhs }
    
    public func distance(to rhs: Double) -> CGFloat {
        return CGFloat(abs(self - rhs))
    }
}
