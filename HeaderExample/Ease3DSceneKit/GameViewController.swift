import Foundation
import UIKit
import SceneKit
import Ease

final class GameViewController: UIViewController {
    
    private var initialLocation: CGPoint = .zero
    private var disposal = EaseDisposal()
    private var ease: Ease<CGPoint> = Ease(.zero, minimumStep: 0.001)
    
    private lazy var cameraNode: SCNNode = {
        let node = SCNNode()
        node.camera = SCNCamera()
        node.position = SCNVector3(x: 0, y: 0, z: 2)
        
        return node
    }()
    
    private lazy var scene: SCNScene = {
        guard let scene = SCNScene(named: "art.scnassets/EaseScene.scn") else {
            fatalError("Couldn't load scene.")
        }
        
        return scene
    }()
    
    private var scnView: SCNView {
        guard let scnView = view as? SCNView else {
            fatalError("View is not a SCNView.")
        }
        
        return scnView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "ease_texture")
        
        for (i, childNode) in scene.rootNode.childNodes.enumerated() {
            childNode.geometry?.materials = [material]
            
            let tension = 1000 - (CGFloat(i) * 200)
            let damping = 75 + (CGFloat(i) * 25)
            let mass = 5 + (CGFloat(i) * 5)
            
            ease.addSpring(tension: tension, damping: damping, mass: mass) { point in
                childNode.runAction(SCNAction.rotateTo(x: point.y / 35, y: point.x / 250, z: 0, duration: 0))
                }.add(to: &disposal)
        }
        
        scene.rootNode.addChildNode(cameraNode)
        
        scnView.scene = scene
        scnView.backgroundColor = UIColor(red: 60/255, green: 10/255, blue: 240/255, alpha: 1)
        scnView.gestureRecognizers = [UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))]
        scnView.antialiasingMode = .multisampling4X
    }
    
    @objc func pan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        
        switch gestureRecognizer.state {
        case .possible, .began:
            initialLocation = location
        case .changed:
            var targetValue = gestureRecognizer.location(in: gestureRecognizer.view)
            targetValue.x -= initialLocation.x
            targetValue.y -= initialLocation.y
            ease.targetValue = targetValue
        case .ended, .cancelled, .failed:
            ease.targetValue = .zero
        }
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
}
