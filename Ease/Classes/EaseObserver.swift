import Foundation

public final class EaseObserver<T: Easeable> {
    
    typealias Closure = (T) -> Void
    
    var value: T
    var velocity: T = .zero
    
    let tension: T.F
    let damping: T.F
    let mass: T.F
    let closure: Closure
    
    init(value: T, tension: T.F, damping: T.F, mass: T.F, closure: @escaping Closure) {
        self.value = value
        self.tension = tension
        self.damping = damping
        self.mass = mass
        self.closure = closure
    }
    
    func setInitialValue(_ value: T) {
        self.value = value
    }
    
    func setInitialVelocity(_ velocity: T) {
        self.velocity = velocity
    }
}
