import Foundation
import CoreGraphics

public protocol Easeable: Equatable {
    static var zero: Self { get }
    static func -(lhs: Self, rhs: Self) -> Self
    static func +(lhs: Self, rhs: Self) -> Self
    static func -=(lhs: inout Self, rhs: Self)
    static func +=(lhs: inout Self, rhs: Self)
    static func /(lhs: Self, rhs: CGFloat) -> Self
    static func *(lhs: Self, rhs: CGFloat) -> Self
    func distance(to rhs: Self) -> CGFloat
}
