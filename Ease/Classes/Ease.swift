import Foundation

public final class Ease<T: Easeable> {
    
    public typealias Closure = (T) -> Void
    
    private var observers: [Int: EaseObserver<T>] = [:]
    private var keys = (0...).makeIterator()
    
    public var minimumStep: T.F
    public let manualUpdate: Bool
    
    public var value: T {
        didSet {
            observers.forEach {
                $0.value.setInitialValue(value)
            }
        }
    }
    
    public var velocity: T = .zero {
        didSet {
            observers.forEach {
                $0.value.setInitialVelocity(velocity)
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
        displayLink.add(to: .current, forMode: RunLoop.Mode.common)
        displayLink.isPaused = true
        
        return displayLink
    }()
    
    public var targetValue: T? = nil {
        didSet {
            isPaused = false
        }
    }
    
    public init(_ value: T, manualUpdate: Bool = false, minimumStep: T.F) {
        self.value = value
        self.minimumStep = minimumStep
        self.manualUpdate = manualUpdate
    }
    
    public func addSpring(tension: T.F, damping: T.F, mass: T.F, closure: @escaping Closure) -> EaseDisposable {
        let key = nextKey
        
        observers[key] = EaseObserver(value: value, tension: tension, damping: damping, mass: mass, closure: closure)
        closure(value)
        
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
        
        observers.values.forEach {
            var observer = $0
            interpolate(&observer, to: targetValue, duration: frameDuration)
            observer.closure(observer.value)
            
            if abs(observer.value.distance(to: targetValue)) > minimumStep {
                shouldPause = false
            }
        }
        
        isPaused = shouldPause
        
        if isPaused {
            observers.values.forEach {
                $0.closure(targetValue)
            }
        }
    }
    
    private func interpolate(_ observer: inout EaseObserver<T>, to targetValue: T, duration: T.F) {
        let displacement = subtract(observer.value.values, targetValue.values)
        let kx = multiply(displacement, observer.tension)
        let bv = multiply(observer.velocity.values, observer.damping)
        let acceleration = divide(sum(kx, bv), observer.mass)
        
        observer.velocity = T(with: subtract(observer.velocity.values, multiply(acceleration, duration)))
        observer.value = T(with: sum(observer.value.values, multiply(observer.velocity.values, duration)))
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

private extension Array {
    
    func enumeratedMap<T>(_ transform: (Int, Element) -> T) -> [T] {
        var result: [T] = []
        result.reserveCapacity(count)
        
        for (index, element) in enumerated() {
            result.append(transform(index, element))
        }
        
        return result
    }
}
