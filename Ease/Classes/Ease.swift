import UIKit

public extension Notification.Name {
    static let easeStarted = Notification.Name("EaseStarted")
    static let easeCompleted = Notification.Name("EaseCompleted")
}

public final class Ease<T: Easeable> {
    
    public typealias EaseClosure = (T, T?) -> Void
    public typealias EaseCompletion = () -> Void
    
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
            let newValue = _value
            observers.values.forEach { observer, dispatchQueue in
                if let dispatchQueue = dispatchQueue {
                    dispatchQueue.async {
                        observer.setInitialValue(newValue)
                    }
                } else {
                    observer.setInitialValue(newValue)
                }
            }
        }
    }
    
    public var velocity: T = .zero {
        didSet {
            observers.values.forEach { observer, _ in
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
            
            NotificationCenter.default.post(name: isPaused ? .easeCompleted : .easeStarted, object: self)
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
            
            observers.values.forEach { _observer, _ in
                _observer.isPaused = false
            }
        }
    }
    
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
    
    public func addSpring(_ spring: Spring, queue: DispatchQueue? = nil, closure: @escaping EaseClosure, completion: EaseCompletion? = nil) -> EaseDisposable {
        return addSpring(tension: spring.tension, damping: spring.damping, mass: spring.mass, queue: queue, closure: closure, completion: completion)
    }
    
    public func addSpring(tension: T.F, damping: T.F, mass: T.F, queue: DispatchQueue? = nil, closure: @escaping EaseClosure, completion: EaseCompletion? = nil) -> EaseDisposable {
        lock.lock(); defer { lock.unlock() }
        
        let key = nextKey
        
        observers[key] = (EaseObserver(value: value, tension: tension, damping: damping, mass: mass, closure: closure, completion: completion), queue)
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
        guard !isPaused, let targetValue = targetValue else {
            return
        }
        
        var shouldPause = true
        
        observers.values.forEach { _observer, _ in
            guard !_observer.isPaused else { return }
            
            var observer = _observer
            interpolate(&observer, to: targetValue, duration: frameDuration)
            observer.closure(observer.value, nil)
            
            let velocityTooHigh = observer.velocity > minimumStep || observer.previousVelocity > minimumStep
            let notCloseToTarget = abs(observer.value.getDistance(to: targetValue)) > minimumStep
            
            if notCloseToTarget || velocityTooHigh {
                shouldPause = false
            } else {
                observer.isPaused = true
                observer.completion?()
            }
        }
        
        isPaused = shouldPause
        
        if isPaused {
            observers.values.forEach { observer, _ in
                observer.closure(targetValue, nil)
            }
        }
    }
    
    private func interpolate(_ observer: inout EaseObserver<T>, to targetValue: T, duration: T.F) {
        let distance = observer.value - targetValue
        let kx = distance * observer.tension
        let bv = observer.velocity * observer.damping
        let acceleration = (kx + bv) / observer.mass
        
        observer.previousVelocity = observer.velocity
        observer.velocity = observer.velocity - (acceleration * duration)
        observer.value = observer.value + (observer.velocity * duration)
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

extension Easeable {
    
    static func - (lhs: Self, rhs: Self) -> Self {
        return Self(with: lhs.values - rhs.values)
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        return Self(with: lhs.values + rhs.values)
    }
    
    static func * (lhs: Self, rhs: Self.F) -> Self {
        return Self(with: lhs.values * rhs)
    }
    
    static func / (lhs: Self, rhs: Self.F) -> Self {
        return Self(with: lhs.values / rhs)
    }
    
    static func > (lhs: Self, rhs: Self.F) -> Bool {
        return lhs.values > rhs
    }
}

extension Array where Element: FloatingPoint {
    
    static func - (lhs: Self, rhs: Self) -> Self {
        return lhs.enumeratedMap {
            $1 - rhs[$0]
        }
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        return lhs.enumeratedMap {
            $1 + rhs[$0]
        }
    }
    
    static func * (lhs: Self, rhs: Element) -> Self {
        return lhs.map {
            $0 * rhs
        }
    }
    
    static func / (lhs: Self, rhs: Element) -> Self {
        return lhs.map {
            $0 / rhs
        }
    }
    
    static func > (lhs: Self, rhs: Element) -> Bool {
        for value in lhs {
            if abs(value) > rhs {
                return true
            }
        }
        
        return false
    }
}
