import Foundation
import SceneKit.SceneKitTypes

public protocol Easeable {
    
    associatedtype F: FloatingPoint
    
    static var zero: Self { get }
    
    var values: [F] { get }
    
    init(with values: [F])
    
    static func float(from timeInterval: TimeInterval) -> F
    
    func rotation(for axis: SCNVector3) -> Float
    
    func position(for axis: SCNVector3) -> Float
}

internal extension Easeable {
    
    private func sq(_ value: F) -> F {
        return value * value
    }
    
    func getDistance(to target: Self) -> F {
        return sqrt(values.enumeratedMap { i, value in
            sq(value - target.values[i])
            }.reduce(0, +))
    }
}
