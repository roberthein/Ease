import Foundation
import UIKit
import CoreMotion
import Ease

class GyroscopeViewController: UIViewController, ExampleViewController {
    
    var disposal = EaseDisposal()
    private lazy var ease = Ease(initialValue: CGVector.zero)
    private lazy var circles = createCircles()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .tintColor3
        
        for (i, circle) in circles.enumerated() {
            view.addSubview(circle)
            
            let tension = 1000 - (CGFloat(i) * 100)
            let damping = 30 - CGFloat(i * 5)
            let mass = 10 - (CGFloat(i))
            
            ease.addSpring(tension: tension, damping: damping, mass: mass) { [weak self] vector in
                guard let strongSelf = self else { return }
                circle.center = CGPoint(x: strongSelf.view.center.x - vector.dx, y: strongSelf.view.center.y - vector.dy)
                }.add(to: &disposal)
        }
        
        Gyro.observe { [weak self] vector in
            self?.ease.targetValue = vector
        }
    }
}

let Gyro = GyroManager.shared

class GyroManager: CMMotionManager {
    
    static let shared = GyroManager()
    private let queue = OperationQueue()
    
    func observe(_ observer: @escaping (_ gyro: CGVector) -> Void) {
        startAccelerometerUpdates(to: queue) { data, error in
            guard let data = data else { return }
            
            DispatchQueue.main.sync {
                observer(CGVector(dx: CGFloat(data.acceleration.x) * -150, dy: CGFloat(data.acceleration.y) * 150))
            }
        }
    }
}
