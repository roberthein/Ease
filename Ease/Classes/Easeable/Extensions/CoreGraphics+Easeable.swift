import Foundation
import CoreGraphics


extension CGFloat: Easeable {
    
    public typealias F = CGFloat
    
    public static var zero: CGFloat {
        return 0
    }
    
    public var values: [CGFloat] {
        return [self]
    }
    
    public init(with values: [CGFloat]) {
        self.init(values[0])
    }
    
    public func distance(to target: CGFloat) -> CGFloat {
        return abs(self - target)
    }
    
    public static func float(from timeInterval: TimeInterval) -> CGFloat {
        return CGFloat(timeInterval)
    }
}

extension CGPoint: Easeable {
    
    public typealias F = CGFloat
    
    public var values: [CGFloat] {
        return [x, y]
    }
    
    public init(with values: [CGFloat]) {
        self.init(x: values[0], y: values[1])
    }
    
    public func distance(to target: CGPoint) -> CGFloat {
        let distance = CGPoint(x: target.x - x, y: target.y - y)
        return abs((pow(distance.x, 2) + pow(distance.y, 2)).squareRoot())
    }
    
    public static func float(from timeInterval: TimeInterval) -> CGFloat {
        return CGFloat(timeInterval)
    }
}

extension CGSize: Easeable {
    
    public typealias F = CGFloat
    
    public var values: [CGFloat] {
        return [width, height]
    }
    
    public init(with values: [CGFloat]) {
        self.init(width: values[0], height: values[1])
    }
    
    public func distance(to target: CGSize) -> CGFloat {
        let distance = CGSize(width: target.width - width, height: target.height - height)
        return abs((pow(distance.width, 2) + pow(distance.height, 2)).squareRoot())
    }
    
    public static func float(from timeInterval: TimeInterval) -> CGFloat {
        return CGFloat(timeInterval)
    }
}

extension CGVector: Easeable {
    
    public typealias F = CGFloat
    
    public var values: [CGFloat] {
        return [dx, dy]
    }
    
    public init(with values: [CGFloat]) {
        self.init(dx: values[0], dy: values[1])
    }
    
    public func distance(to target: CGVector) -> CGFloat {
        let distance = CGVector(dx: target.dx - dx, dy: target.dy - dy)
        return abs((pow(distance.dx, 2) + pow(distance.dy, 2)).squareRoot())
    }
    
    public static func float(from timeInterval: TimeInterval) -> CGFloat {
        return CGFloat(timeInterval)
    }
}
