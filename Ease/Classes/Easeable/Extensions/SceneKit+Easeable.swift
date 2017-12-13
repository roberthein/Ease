import Foundation
import CoreGraphics
import SceneKit

extension SCNVector3: Easeable {
    public static var zero = SCNVector3(x: 0, y: 0, z: 0)
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool { return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z}
    public static func +=(lhs: inout SCNVector3, rhs: SCNVector3) { lhs = lhs + rhs }
    public static func -=(lhs: inout SCNVector3, rhs: SCNVector3) { lhs = lhs - rhs }
    public static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 { return SCNVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z) }
    public static func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 { return SCNVector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z) }
    public static func /(lhs: SCNVector3, rhs: CGFloat) -> SCNVector3 { return SCNVector3(x: lhs.x / Float(rhs), y: lhs.y / Float(rhs), z: lhs.z / Float(rhs)) }
    public static func *(lhs: SCNVector3, rhs: CGFloat) -> SCNVector3 { return SCNVector3(x: lhs.x * Float(rhs), y: lhs.y * Float(rhs), z: lhs.z * Float(rhs)) }
    
    public func distance(to rhs: SCNVector3) -> CGFloat {
        let distance = SCNVector3(x: rhs.x - x, y: rhs.y - y, z: rhs.z - z)
        return CGFloat(abs((pow(distance.x, 2) + pow(distance.y, 2) + pow(distance.z, 2)).squareRoot()))
    }
}

