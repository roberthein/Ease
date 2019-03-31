import Foundation

public final class Ease<T: Easeable> {
    
    public typealias Closure = (T, T?) -> Void
    
    private var observers: [Int: (EaseObserver<T>, DispatchQueue?)] = [:]
    private var keys = (0...).makeIterator()
    
    public var minimumStep: T.F
    public let manualUpdate: Bool
    
    fileprivate let lock: Lock = Mutex()
    
    public let projection: Projection<T>?
    
    public struct Spring {
        let tension: T.F
        let damping: T.F
        let mass: T.F
        
        public init(tension: T.F, damping: T.F, mass: T.F) {
            self.tension = tension
            self.damping = damping
            self.mass = mass
        }
    }
    
    public var value: T {
        get {
            return _value
        } set {
            lock.lock(); defer { lock.unlock() }
            _value = newValue
        }
    }
    
    fileprivate var _value: T {
        didSet {
            observers.values.forEach { observer, dispatchQueue in
                if let dispatchQueue = dispatchQueue {
                    dispatchQueue.async {
                        observer.setInitialValue(self.value)
                    }
                } else {
                    observer.setInitialValue(value)
                }
            }
        }
    }
    
    public var velocity: T = .zero {
        didSet {
            observers.values.forEach { observer, dispatchQueue in
                observer.setInitialVelocity(velocity)
            }
        }
    }
    
    public var isPaused: Bool = true {
        didSet {
            guard isPaused != oldValue else {
                return
            }
            
            if !manualUpdate {
                displayLink.isPaused = isPaused
            }
        }
    }
    
    private var nextKey: Int {
        guard let key = keys.next() else {
            return 0
        }
        
        return key
    }
    
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateFromDisplayLink(_:)))
        displayLink.add(to: .current, forMode: .common)
        displayLink.isPaused = true
        
        return displayLink
    }()
    
    public var targetValue: T? = nil {
        didSet {
            isPaused = false
        }
    }
    
    public var shouldNeverPause: Bool = false
    
    public init(_ value: T, manualUpdate: Bool = false, minimumStep: T.F, targets projectionTargets: [T]? = nil) {
        self._value = value
        self.minimumStep = minimumStep
        self.manualUpdate = manualUpdate
        
        if let targets = projectionTargets {
            projection = Projection(targets: targets)
        } else {
            projection = nil
        }
    }
    
    public func addSpring(_ spring: Spring, queue: DispatchQueue? = nil, closure: @escaping Closure) -> EaseDisposable {
        return addSpring(tension: spring.tension, damping: spring.damping, mass: spring.mass, queue: queue, closure: closure)
    }
    
    public func addSpring(tension: T.F, damping: T.F, mass: T.F, queue: DispatchQueue? = nil, closure: @escaping Closure) -> EaseDisposable {
        lock.lock(); defer { lock.unlock() }
        
        let key = nextKey
        
        observers[key] = (EaseObserver(value: value, tension: tension, damping: damping, mass: mass, closure: closure), queue)
        closure(value, nil)
        
        let disposable = EaseDisposable { [weak self] in
            self?.observers[key] = nil
        }
        
        return disposable
    }
    
    public func removeAllObservers() {
        observers.removeAll()
    }
    
    @objc func updateFromDisplayLink(_ displayLink: CADisplayLink) {
        update(for: T.float(from: displayLink.duration))
    }
    
    public func update(for frameDuration: T.F) {
        guard let targetValue = targetValue, !isPaused else {
            return
        }
        
        var shouldPause = true
        
        observers.values.forEach { _observer, dispatchQueue in
            var observer = _observer
            interpolate(&observer, to: targetValue, duration: frameDuration)
            observer.closure(observer.value, nil)
            
            let velocityIsBigger = isBigger(observer.velocity.values, minimumStep)
            let previousVelocityIsBigger = isBigger(observer.previousVelocity.values, minimumStep)
            
            if abs(observer.value.getDistance(to: targetValue)) > minimumStep || velocityIsBigger || previousVelocityIsBigger || shouldNeverPause {
                shouldPause = false
            } else {
                // handle completion here
            }
        }
        
        isPaused = shouldPause
        
        if isPaused {
            observers.values.forEach { observer, dispatchQueue in
                observer.closure(targetValue, nil)
            }
        }
    }
    
    private func interpolate(_ observer: inout EaseObserver<T>, to targetValue: T, duration: T.F) {
        let displacement = subtract(observer.value.values, targetValue.values)
        let kx = multiply(displacement, observer.tension)
        let bv = multiply(observer.velocity.values, observer.damping)
        let acceleration = divide(sum(kx, bv), observer.mass)
        
        observer.previousVelocity = observer.velocity
        observer.velocity = T(with: subtract(observer.velocity.values, multiply(acceleration, duration)))
        observer.value = T(with: sum(observer.value.values, multiply(observer.velocity.values, duration)))
    }
    
    func isBigger(_ lhs: [T.F], _ rhs: T.F) -> Bool {
        
        for value in lhs {
            if abs(value) > rhs {
                return true
            }
        }
        
        return false
    }
    
    func subtract(_ lhs: [T.F], _ rhs: [T.F]) -> [T.F] {
        return lhs.enumeratedMap {
            $1 - rhs[$0]
        }
    }
    
    func sum(_ lhs: [T.F], _ rhs: [T.F]) -> [T.F] {
        return lhs.enumeratedMap {
            $1 + rhs[$0]
        }
    }
    
    func multiply(_ lhs: [T.F], _ rhs: T.F) -> [T.F] {
        return lhs.map {
            $0 * rhs
        }
    }
    
    func divide(_ lhs: [T.F], _ rhs: T.F) -> [T.F] {
        return lhs.map {
            $0 / rhs
        }
    }
}

internal extension Array {
    
    func enumeratedMap<T>(_ transform: (Int, Element) -> T) -> [T] {
        var result: [T] = []
        result.reserveCapacity(count)
        
        for (index, element) in enumerated() {
            result.append(transform(index, element))
        }
        
        return result
    }
}
