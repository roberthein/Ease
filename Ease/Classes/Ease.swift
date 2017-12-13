import Foundation
import CoreGraphics
import UIKit

public final class Ease<T: Easeable> {
    
    public typealias Closure = (T) -> Void
    
    private var observers: [Int: EaseObserver<T>] = [:]
    private var keys = (0...).makeIterator()
    private let initialValue: T
    public var minimumStep: CGFloat = 0.0001
    
    private var nextKey: Int {
        guard let key = keys.next() else { fatalError("There will always be a next key.") }
        return key
    }
    
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(update(_:)))
        displayLink.add(to: .current, forMode: .commonModes)
        displayLink.isPaused = true
        
        return displayLink
    }()
    
    public var targetValue: T? = nil {
        didSet {
            displayLink.isPaused = false
        }
    }
    
    public init(initialValue: T) {
        self.initialValue = initialValue
    }
    
    public func addSpring(tension: CGFloat, damping: CGFloat, mass: CGFloat, closure: @escaping Closure) -> EaseDisposable {
        let key = nextKey
        
        observers[key] = EaseObserver(value: initialValue, tension: tension, damping: damping, mass: mass, closure: closure)
        closure(initialValue)
        
        let disposable = EaseDisposable { [weak self] in
            self?.observers[key] = nil
        }
        
        return disposable
    }
    
    public func removeAllObservers() {
        observers.removeAll()
    }
    
    @objc func update(_ displayLink: CADisplayLink) {
        guard let targetValue = targetValue else { return }
        var isPaused = true
        
        observers.values.forEach {
            var observer = $0
            interpolate(to: targetValue, with: &observer, duration: displayLink.duration)
            observer.closure(observer.value)
            
            if observer.value.distance(to: targetValue) > minimumStep {
                isPaused = false
            }
        }
        
        displayLink.isPaused = isPaused
        
        if displayLink.isPaused {
            observers.values.forEach {
                $0.closure(targetValue)
            }
        }
    }
    
    private func interpolate(to targetValue: T, with observer: inout EaseObserver<T>, duration: TimeInterval) {
        let displacement = observer.value - targetValue
        let kx = displacement * observer.tension
        let bv = observer.velocity * observer.damping
        let acceleration = (kx + bv) / observer.mass
        
        observer.velocity -= acceleration * CGFloat(duration)
        observer.value += observer.velocity * CGFloat(duration)
    }
}
