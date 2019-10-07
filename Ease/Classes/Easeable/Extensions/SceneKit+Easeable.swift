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
    
    public static func float(from timeInterval: TimeInterval) -> Float {
        return Float(timeInterval)
    }
}
