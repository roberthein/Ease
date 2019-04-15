import Foundation
import UIKit
import Ease

class GesturesViewController: UIViewController, ExampleViewController {
    
    var disposal = EaseDisposal()
    private lazy var ease: Ease<CGPoint> = Ease(view.center, minimumStep: 0.001)
    private lazy var circles = createCircles(color: .tintColor3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .tintColor2
        
        for (i, circle) in circles.enumerated() {
            view.addSubview(circle)
            
            let tension = 500 + (CGFloat(i) * 50)
            let damping = 100 - (CGFloat(i) * 10)
            let mass = 8 - (CGFloat(i) * 0.5)
            
            ease.addSpring(tension: tension, damping: damping, mass: mass, closure: { position, _ in
                circle.center = position
            }).add(to: &disposal)
        }
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pan(_:)))
        gestureRecognizer.minimumPressDuration = 0
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func pan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .possible, .began, .changed:
            ease.targetValue = gestureRecognizer.location(in: view)
        case .ended, .cancelled, .failed:
            ease.targetValue = view.center
        @unknown default:
            fatalError()
        }
    }
}
