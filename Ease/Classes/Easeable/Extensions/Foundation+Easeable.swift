import Foundation
import SceneKit.SceneKitTypes

extension Int: Easeable {
    
    public typealias F = Float
    
    public static var zero: Int = 0
    
    public var values: [Float] {
        get { return [Float(self)] }
        set { self = Int(with: newValue) }
    }
    
    public init(with values: [Float]) {
        self.init(Int(values[0]))
    }
    
    public static func float(from timeInterval: TimeInterval) -> Float {
        return Float(timeInterval)
    }
}

extension Float: Easeable {
    
    public typealias F = Float
    
    public static var zero: Float = 0
    
    public var values: [Float] {
        get { return [self] }
        set { self = Float(with: newValue) }
    }
    
    public init(with values: [Float]) {
        self.init(values[0])
    }
    
    public static func float(from timeInterval: TimeInterval) -> Float {
        return Float(timeInterval)
    }
}

extension Double: Easeable {
    
    public typealias F = Double
    
    public static var zero: Double = 0
    
    public var values: [Double] {
        get { return [self] }
        set { self = Double(with: newValue) }
    }
    
    public init(with values: [Double]) {
        self.init(values[0])
    }
    
    public static func float(from timeInterval: TimeInterval) -> Double {
        return Double(timeInterval)
    }
}
