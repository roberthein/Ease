import Foundation
import CoreGraphics

extension CGFloat: Easeable {
    
    public static var zero: CGFloat = 0
    
    public func distance(to rhs: CGFloat) -> CGFloat {
        return abs(self - rhs)
    }
}

extension CGPoint: Easeable {
    public static func +=(lhs: inout CGPoint, rhs: CGPoint) { lhs = lhs + rhs }
    public static func -=(lhs: inout CGPoint, rhs: CGPoint) { lhs = lhs - rhs }
    public static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
    public static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
    public static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint { return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs) }
    public static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint { return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs) }
    
    public func distance(to rhs: CGPoint) -> CGFloat {
        let distance = CGPoint(x: rhs.x - x, y: rhs.y - y)
        return abs((pow(distance.x, 2) + pow(distance.y, 2)).squareRoot())
    }
}

extension CGSize: Easeable {
    public static func +=(lhs: inout CGSize, rhs: CGSize) { lhs = lhs + rhs }
    public static func -=(lhs: inout CGSize, rhs: CGSize) { lhs = lhs - rhs }
    public static func +(lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height) }
    public static func -(lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height) }
    public static func /(lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width / rhs, height: lhs.height / rhs) }
    public static func *(lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width * rhs, height: lhs.height * rhs) }
    
    public func distance(to rhs: CGSize) -> CGFloat {
        let distance = CGSize(width: rhs.width - width, height: rhs.height - height)
        return abs((pow(distance.width, 2) + pow(distance.height, 2)).squareRoot())
    }
}

extension CGVector: Easeable {
    public static func +=(lhs: inout CGVector, rhs: CGVector) { lhs = lhs + rhs }
    public static func -=(lhs: inout CGVector, rhs: CGVector) { lhs = lhs - rhs }
    public static func +(lhs: CGVector, rhs: CGVector) -> CGVector { return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy) }
    public static func -(lhs: CGVector, rhs: CGVector) -> CGVector { return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy) }
    public static func /(lhs: CGVector, rhs: CGFloat) -> CGVector { return CGVector(dx: lhs.dx / rhs, dy: lhs.dy / rhs) }
    public static func *(lhs: CGVector, rhs: CGFloat) -> CGVector { return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs) }
    
    public func distance(to rhs: CGVector) -> CGFloat {
        let distance = CGVector(dx: rhs.dx - dx, dy: rhs.dy - dy)
        return abs((pow(distance.dx, 2) + pow(distance.dy, 2)).squareRoot())
    }
}
