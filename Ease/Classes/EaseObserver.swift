import Foundation
import CoreGraphics

public final class EaseObserver<T: Easeable> {
    
    typealias Closure = (T) -> Void
    
    var value: T
    var velocity: T = .zero
    
    let tension: CGFloat
    let damping: CGFloat
    let mass: CGFloat
    let closure: Closure
    
    init(value: T, tension: CGFloat, damping: CGFloat, mass: CGFloat, closure: @escaping Closure) {
        self.value = value
        self.tension = tension
        self.damping = damping
        self.mass = mass
        self.closure = closure
    }
}
