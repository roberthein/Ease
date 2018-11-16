import Foundation
import SceneKit.SceneKitTypes

extension Int: Easeable {
    
    public typealias F = Float
    
    public static var zero: Int = 0
    
    public var values: [Float] {
        return [Float(self)]
    }
    
    public init(with values: [Float]) {
        self.init(Int(values[0]))
    }
    
    public static func float(from timeInterval: TimeInterval) -> Float {
        return Float(timeInterval)
    }
    
    public func rotation(for axis: SCNVector3) -> Float {
        return Float(self)
    }
    
    public func position(for axis: SCNVector3) -> Float {
        return Float(self)
    }
}

extension Float: Easeable {
    
    public typealias F = Float
    
    public static var zero: Float = 0
    
    public var values: [Float] {
        return [self]
    }
    
    public init(with values: [Float]) {
        self.init(values[0])
    }
    
    public static func float(from timeInterval: TimeInterval) -> Float {
        return Float(timeInterval)
    }
    
    public func rotation(for axis: SCNVector3) -> Float {
        return Float(self)
    }
    
    public func position(for axis: SCNVector3) -> Float {
        return Float(self)
    }
}

extension Double: Easeable {
    
    public typealias F = Double
    
    public static var zero: Double = 0
    
    public var values: [Double] {
        return [self]
    }
    
    public init(with values: [Double]) {
        self.init(values[0])
    }
    
    public static func float(from timeInterval: TimeInterval) -> Double {
        return Double(timeInterval)
    }
    
    public func rotation(for axis: SCNVector3) -> Float {
        return Float(self)
    }
    
    public func position(for axis: SCNVector3) -> Float {
        return Float(self)
    }
}
