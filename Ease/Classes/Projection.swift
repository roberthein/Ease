import Foundation

public struct Projection<P: Easeable> {
    
    public let targets: [P]
    
    public init(targets: [P]) {
        self.targets = targets
    }
    
    public func target(for start: P, with velocity: P, scalar: P.F, decelerationRate: P.F) -> P {
        let projection = P(with: start.values.enumeratedMap { i, value in
            value + project(velocity: velocity.values[i], scalar: scalar, decelerationRate: decelerationRate)
        })
        
        return nearest(to: projection) ?? projection
    }
    
    private func project(velocity: P.F, scalar: P.F, decelerationRate: P.F) -> P.F {
        return (velocity / scalar) * decelerationRate / (1 - decelerationRate)
    }
    
    private func nearest(to projection: P) -> P? {
        return targets.min(by: {
            $0.getDistance(to: projection) < $1.getDistance(to: projection)
        })
    }
}
