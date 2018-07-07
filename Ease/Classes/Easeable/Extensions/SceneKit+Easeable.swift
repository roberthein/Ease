import Foundation
import SceneKit

extension SCNVector3: Easeable {
    
    public typealias F = Float
    
    public static var zero: SCNVector3 = SCNVector3Zero
    
    public var values: [Float] {
        return [x, y, z]
    }
    
    public init(with values: [Float]) {
        self.init(values[0], values[1], values[2])
    }
    
    public func distance(to target: SCNVector3) -> Float {
        let distance = SCNVector3(x: target.x - x, y: target.y - y, z: target.z - z)
        return abs((pow(distance.x, 2) + pow(distance.y, 2) + pow(distance.z, 2)).squareRoot())
    }
    
    public static func float(from timeInterval: TimeInterval) -> Float {
        return Float(timeInterval)
    }
}
