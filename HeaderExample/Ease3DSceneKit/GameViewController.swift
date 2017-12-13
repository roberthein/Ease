import Foundation
import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import Ease

final class GameViewController: UIViewController {
    
    private var initialLocation: CGPoint = .zero
    private var disposal = EaseDisposal()
    private var ease = Ease(initialValue: CGPoint.zero)
    
    private lazy var scene: SCNScene = {
        guard let scene = SCNScene(named: "art.scnassets/EaseScene.scn") else { fatalError("Scene does not exist.") }
        return scene
    }()
    
    private var scnView: SCNView {
        guard let view = view as? SCNView else { fatalError("View is not a SCNView.") }
        return view
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
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
        scene.rootNode.addChildNode(cameraNode)
        
        scnView.scene = scene
        scnView.backgroundColor = UIColor(red: 0/255, green: 255/255, blue: 218/255, alpha: 1)
        scnView.gestureRecognizers = [UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))]
        scnView.antialiasingMode = .multisampling4X
    }
    
    @objc func pan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .possible, .began:
            initialLocation = gestureRecognizer.location(in: view)
        case .changed:
            ease.targetValue = gestureRecognizer.location(in: view) - initialLocation
        case .ended, .cancelled, .failed:
            ease.targetValue = .zero
        }
    }
}
