import Foundation

internal final class EaseObserver<T: Easeable> {
    
    public typealias EaseClosure = (T, T?) -> Void
    public typealias EaseCompletion = () -> Void
    
    var value: T
    var velocity: T = .zero
    var previousVelocity: T = .zero
    var isPaused: Bool = false
    
    let tension: T.F
    let damping: T.F
    let mass: T.F
    let closure: EaseClosure
    let completion: EaseCompletion?
    
    let clampRange: Ease<T>.Range?
    let rubberBandingRange: Ease<T>.Range?
    let rubberBandingStiffness: T.F?
    
    required init(value: T, tension: T.F, damping: T.F, mass: T.F, clampRange: Ease<T>.Range? = nil, rubberBandingRange: Ease<T>.Range? = nil, rubberBandingStiffness: T.F? = nil, closure: @escaping EaseClosure, completion: EaseCompletion?) {
        self.value = value
        self.tension = tension
        self.damping = damping
        self.mass = mass
        self.clampRange = clampRange
        self.rubberBandingRange = rubberBandingRange
        self.rubberBandingStiffness = rubberBandingStiffness
        self.closure = closure
        self.completion = completion
    }
    
    func setInitialValue(_ value: T) {
        self.value = value
    }
    
    func setInitialVelocity(_ velocity: T) {
        self.velocity = velocity
    }
}
