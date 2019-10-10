import Foundation
import QuartzCore

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
        
        public init(t: T.F, d: T.F, m: T.F) {
            tension = t
            damping = d
            mass = m
        }
    }
    
    public struct Range {
        let min: T
        let max: T
        
        var closedRanges: [ClosedRange<T.F>] {
            return min.values.enumeratedMap { $1 ... max.values[$0] }
        }
        
        public init(min: T, max: T) {
            self.min = min
            self.max = max
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
    
    public func addSpring(_ spring: Spring, clampRange: Range? = nil, rubberBandingRange: Range? = nil, rubberBandingStiffness: T.F? = nil, queue: DispatchQueue? = nil, closure: @escaping EaseClosure, completion: EaseCompletion? = nil) -> EaseDisposable {
        return addSpring(tension: spring.tension, damping: spring.damping, mass: spring.mass, clampRange: clampRange, rubberBandingRange: rubberBandingRange, rubberBandingStiffness: rubberBandingStiffness, queue: queue, closure: closure, completion: completion)
    }
    
    public func addSpring(tension: T.F, damping: T.F, mass: T.F, clampRange: Range? = nil, rubberBandingRange: Range? = nil, rubberBandingStiffness: T.F? = nil, queue: DispatchQueue? = nil, closure: @escaping EaseClosure, completion: EaseCompletion? = nil) -> EaseDisposable {
        lock.lock(); defer { lock.unlock() }
        
        let key = nextKey
        
        observers[key] = (EaseObserver(value: value, tension: tension, damping: damping, mass: mass, clampRange: clampRange, rubberBandingRange: rubberBandingRange, rubberBandingStiffness: rubberBandingStiffness, closure: closure, completion: completion), queue)
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
        
        observers.values.forEach { observer, _ in
            guard !observer.isPaused else { return }
            observer.interpolate(to: targetValue, duration: frameDuration)
            observer.rubberBand()
            observer.clamp()
            observer.closure(observer.value, nil)
            
            let velocityTooHigh = (observer.velocity < -minimumStep || observer.velocity > minimumStep) || (observer.previousVelocity < -minimumStep || observer.previousVelocity > minimumStep)
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

internal extension EaseObserver {
    
    func interpolate(to targetValue: T, duration: T.F) {
        let distance = value - targetValue
        let kx = distance * tension
        let bv = velocity * damping
        let acceleration = (kx + bv) / mass
        
        previousVelocity = velocity
        velocity = velocity - (acceleration * duration)
        value = value + (velocity * duration)
    }
    
    func rubberBand() {
        if let range = rubberBandingRange, let stiffness = rubberBandingStiffness {
            let rubberBandedValues: [T.F] = value.values.enumeratedMap {
                if let rubberBandedValue = value.rubberBanding(value: $1, range: range.closedRanges[$0], stiffness: stiffness) {
                    return rubberBandedValue
                } else {
                    return $1
                }
            }
            
            value.values = rubberBandedValues
        }
    }
    
    func clamp() {
        if let range = clampRange {
            let clampedValues: [T.F] = value.values.enumeratedMap {
                if let clampedValue = value.clamp(value: $1, range: range.closedRanges[$0]) {
                    self.velocity.values[$0] = self.velocity.values[$0] * -1
                    return clampedValue
                } else {
                    return $1
                }
            }
            
            value.values = clampedValues
        }
    }
}

internal extension Easeable {
    
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
    
    static func < (lhs: Self, rhs: Self.F) -> Bool {
        return lhs.values < rhs
    }
    
    static func > (lhs: Self, rhs: Self.F) -> Bool {
        return lhs.values > rhs
    }
    
    func clamp(value: Self.F, range: ClosedRange<Self.F>) -> Self.F? {
        
        if value < range.lowerBound {
            return range.lowerBound
        } else if value > range.upperBound {
            return range.upperBound
        }
        
        return nil
    }
    
    func rubberBanding(value: Self.F, range: ClosedRange<Self.F>, stiffness: Self.F) -> Self.F? {
        
        if value > range.upperBound {
            let offset = abs(range.upperBound - value) / stiffness
            return range.upperBound + offset
        } else if value < range.lowerBound {
            let offset = abs(range.lowerBound - value) / stiffness
            return range.lowerBound - offset
        }
        
        return nil
    }
    
    func set(_ value: Self.F) -> Self {
        return Self(with: values.map { _ in value })
    }
}

internal extension Array where Element: FloatingPoint {
    
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
    
    static func < (lhs: Self, rhs: Element) -> Bool {
        for value in lhs {
            if value < rhs {
                return true
            }
        }
        
        return false
    }
    
    static func > (lhs: Self, rhs: Element) -> Bool {
        for value in lhs {
            if value > rhs {
                return true
            }
        }
        
        return false
    }
}
