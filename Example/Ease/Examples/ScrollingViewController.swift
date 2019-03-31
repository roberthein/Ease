import Foundation
import UIKit
import Ease

class ScrollingViewController: UIViewController, ExampleViewController {
    
    var disposal = EaseDisposal()
    private lazy var ease: Ease<CGPoint> = Ease(view.center, minimumStep: 0.001)
    private lazy var circles = createCircles(color: .tintColor3)
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        view.alwaysBounceHorizontal = true
        view.alwaysBounceVertical = true
        view.isDirectionalLockEnabled = true
        view.delegate = self
        
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .tintColor1
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])
        
        for (i, circle) in circles.enumerated() {
            circle.center = view.center
            view.addSubview(circle)

            let tension = 1000 + (CGFloat(i) * 50)
            let damping = 80 - (CGFloat(i) * 10)
            let mass = 8 - (CGFloat(i) * 0.5)

            ease.addSpring(tension: tension, damping: damping, mass: mass) { [weak self] offset, _ in
                guard let strongSelf = self else { return }
                circle.center.x = strongSelf.view.bounds.width - ((strongSelf.view.bounds.width / 4) + (offset.x / 4))
                circle.center.y = strongSelf.view.bounds.height - ((strongSelf.view.bounds.width / 4) + (offset.y / 4))
                }.add(to: &disposal)
        }
        
        view.layoutIfNeeded()
        scrollView.contentSize = CGSize(width: scrollView.frame.width * 3, height: scrollView.frame.height * 3)
        scrollView.contentOffset = CGPoint(x: scrollView.frame.width, y: scrollView.frame.height)
    }
}

extension ScrollingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ease.targetValue = scrollView.contentOffset
    }
}
