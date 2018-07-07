import Foundation

public protocol Easeable {
    
    associatedtype F: FloatingPoint
    
    static var zero: Self { get }
    
    var values: [F] { get }
    
    init(with values: [F])
    
    func distance(to target: Self) -> F
    
    static func float(from timeInterval: TimeInterval) -> F
}
